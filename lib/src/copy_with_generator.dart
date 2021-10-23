import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:boilerplate_generators/src/annotations.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

const String _value = '_value';
const String _callback = '_callback';

class CopyWithGenerator extends GeneratorForAnnotation<CopyWith> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@CopyWith can only be applied on classes. Failing element: ${element.name}',
        element: element,
      );
    }
    final copyWithNull = annotation.read('copyWithNull').boolValue;
    final String generics = _genericTypes(element, fullName: false);
    final String fullGenerics = _genericTypes(element, fullName: true);
    final className = '${element.name}$generics';
    final parameters = _parseParameters(element);

    return '''
/// @nodoc    
class \$${element.name}CopyWith$fullGenerics {

final $className $_value;
final $className Function($className) $_callback;

\$${element.name}CopyWith(this.$_value, this.$_callback);

${copyWithNull ? _copyWithNull(className, parameters) : ''}
}
''';
  }
}

String _genericTypes(ClassElement classElement, {required bool fullName}) =>
    classElement.typeParameters.isNotEmpty
        ? '<${classElement.typeParameters.map((e) => fullName ? e.getDisplayString(withNullability: true) : e.name).join(',')}>'
        : '';

_Parameters _parseParameters(ClassElement classElement) {
  _Parameter _parseParameter(ParameterElement element) => _Parameter(
        name: element.name,
        type: element.type.getDisplayString(withNullability: true),
        nullable: element.type.nullabilitySuffix == NullabilitySuffix.question,
        ignore: _isFieldIgnored(element),
        copyWithAnnotated: _isFieldCopyWithAnnotated(element),
      );

  final constructor = classElement.unnamedConstructor;
  if (constructor is! ConstructorElement) {
    throw '${classElement.name} unnamed constructor required';
  }

  final parameters = constructor.parameters;
  if (parameters.isEmpty) {
    throw 'No parameters in ${classElement.name} unnamed constructor';
  }
  return _Parameters(
    named: parameters.where((p) => p.isNamed).map(_parseParameter).toList(),
    optionalPositional: parameters
        .where((p) => p.isOptionalPositional)
        .map(_parseParameter)
        .toList(),
    requiredPositional: parameters
        .where((p) => p.isRequiredPositional)
        .map(_parseParameter)
        .toList(),
  );
}

bool _isFieldIgnored(ParameterElement element) =>
    const TypeChecker.fromRuntime(CopyWithIgnore).hasAnnotationOf(element);

bool _isFieldCopyWithAnnotated(ParameterElement element) =>
    const TypeChecker.fromRuntime(CopyWith).hasAnnotationOf(element);

String _copyWithNull(String className, _Parameters parameters) {
  String _parameterToValue(_Parameter parameter) {
    var value =
        '${parameter.name} == copyWithIgnore ? $_value.${parameter.name} : ${parameter.name} ';
    if (parameter.type != 'Object?') {
      value += 'as ${parameter.type}';
    }
    return '$value,';
  }

  final namedNullable = parameters.named.where((element) => element.nullable);
  final requiredPositionalNullable =
      parameters.requiredPositional.where((element) => element.nullable);
  final optionalPositionalNullable =
      parameters.optionalPositional.where((element) => element.nullable);
  if (namedNullable.isNotEmpty ||
      requiredPositionalNullable.isNotEmpty ||
      optionalPositionalNullable.isNotEmpty) {
    return '''
$className copyWithNull({${[
      ...requiredPositionalNullable,
      ...optionalPositionalNullable,
      ...namedNullable
    ].map((e) => 'Object? ${e.name} = copyWithIgnore,').join()}
  }) => $_callback($className(${[
      ...[
        ...requiredPositionalNullable,
        ...optionalPositionalNullable,
      ].map(_parameterToValue),
      ...namedNullable.map((e) => '${e.name} : ${_parameterToValue(e)}')
    ].join()}
));    
''';
  } else {
    return '';
  }
}

class _Parameters {
  final List<_Parameter> named;
  final List<_Parameter> optionalPositional;
  final List<_Parameter> requiredPositional;
  _Parameters({
    required this.named,
    required this.optionalPositional,
    required this.requiredPositional,
  });
}

class _Parameter {
  final bool copyWithAnnotated;
  final bool ignore;
  final String name;
  final bool nullable;
  final String type;
  _Parameter({
    required this.copyWithAnnotated,
    required this.ignore,
    required this.name,
    required this.nullable,
    required this.type,
  });
}

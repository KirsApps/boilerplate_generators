import 'dart:math';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:boilerplate_generators/src/annotations.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

const String _value = '_value';
const String _callback = '_callback';
const String _return = '\$Return';

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
    final typeParameters = element.typeParameters;
    final String generics = _genericTypes(
      typeParameters,
      fullName: false,
    );
    final className = '${element.name}$generics';
    final copyWithGenerics = _genericTypes(
      typeParameters,
      fullName: false,
      additionalGeneric: className,
    );
    final String fullGenerics = _genericTypes(
      typeParameters,
      fullName: true,
    );
    final String fullCopyWithGenerics = _genericTypes(
      typeParameters,
      fullName: true,
      additionalGeneric: _return,
    );
    final parameters = _parseParameters(element);

    return '''
/// @nodoc     
extension \$${element.name}CopyWithExtension$fullGenerics on $className {

\$${element.name}CopyWith$copyWithGenerics get copyWith => \$${element.name}CopyWith$copyWithGenerics(this, (value)=> value);

${copyWithNull ? '\$${element.name}CopyWithNull$copyWithGenerics get copyWithNull => \$${element.name}CopyWithNull$copyWithGenerics(this, (value)=> value);' : ''}
}  
    
/// @nodoc    
class \$${element.name}CopyWith$fullCopyWithGenerics {

final $className $_value;

final $_return Function($className) $_callback;

\$${element.name}CopyWith(this.$_value, this.$_callback);

${_callCopyWith(className, parameters)}
}

${copyWithNull ? '''
/// @nodoc    
class \$${element.name}CopyWithNull$fullCopyWithGenerics {

final $className  $_value;

final $_return  Function($className) $_callback;

\$${element.name}CopyWithNull(this.$_value, this.$_callback);

${_deepCopyWithNull(parameters)}

${_callCopyWithNull(className, parameters)}
}
''' : ''}
''';
  }
}

String _genericTypes(
  List<TypeParameterElement> typeParameters, {
  required bool fullName,
  String additionalGeneric = '',
}) =>
    typeParameters.isNotEmpty
        ? '<${typeParameters.map((e) => fullName ? e.getDisplayString(withNullability: true) : e.name).join(',')}${additionalGeneric.isNotEmpty ? ', $additionalGeneric' : ''}>'
        : '';

_Parameters _parseParameters(ClassElement classElement) {
  CopyWith? _copyWithAnnotation(
    ClassElement classElement,
  ) {
    final annotation =
        const TypeChecker.fromRuntime(CopyWith).firstAnnotationOf(classElement);
    if (annotation != null) {
      final reader = ConstantReader(annotation);
      final copyWithNull = reader.read('copyWithNull').literalValue as bool?;

      return CopyWith(copyWithNull: copyWithNull!);
    }
  }

  _Parameter _parseParameter(ParameterElement parameterElement) {
    final parameterTypeElement = parameterElement.type.element;
    final fieldElement =
        _classOrSuperClassField(classElement, parameterElement.name);
    final type = parameterElement.type.getDisplayString(withNullability: true);
    if (parameterTypeElement is ClassElement) {
      return _ClassParameter(
        name: parameterElement.name,
        type: type,
        nullable: parameterElement.type.nullabilitySuffix ==
            NullabilitySuffix.question,
        ignored: _isFieldIgnored(fieldElement!),
        className: parameterTypeElement.name,
        copyWithAnnotation: _copyWithAnnotation(parameterTypeElement),
      );
    } else {
      return _Parameter(
        name: parameterElement.name,
        type: type,
        nullable: parameterElement.type.nullabilitySuffix ==
            NullabilitySuffix.question,
        ignored: _isFieldIgnored(fieldElement!),
      );
    }
  }

  final constructor = classElement.unnamedConstructor;
  if (constructor is! ConstructorElement) {
    throw '${classElement.name} unnamed constructor required';
  }
  final parameters = constructor.parameters;
  final nonFieldParameters = _nonFieldParameters(classElement, parameters);
  if (nonFieldParameters.isNotEmpty) {
    throw InvalidGenerationSourceError(
      'In ${classElement.name} unnamed constructor founded parameters that are '
      'not class fields - ${nonFieldParameters.join(', ')}. This parameters are not supported',
      element: classElement,
    );
  }
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

bool _isFieldIgnored(FieldElement element) =>
    const TypeChecker.fromRuntime(CopyWithIgnore).hasAnnotationOf(element);

String _callCopyWith(String className, _Parameters parameters) {
  String _parameterToValue(_Parameter parameter) {
    String value;
    if (parameter.ignored) {
      value = '$_value.${parameter.name}';
    } else {
      value = '${parameter.name} ?? $_value.${parameter.name}';
    }
    return '$value,';
  }

  return '''
$_return call({${[
    ...parameters.requiredPositional,
    ...parameters.optionalPositional,
    ...parameters.named
  ].where((element) => !element.ignored).map((e) => '${e.type.endsWith('?') ? e.type : '${e.type}?'} ${e.name},').join()}
  }) => $_callback($className(${[
    ...[
      ...parameters.requiredPositional,
      ...parameters.optionalPositional,
    ].map(_parameterToValue),
    ...parameters.named.map((e) => '${e.name} : ${_parameterToValue(e)}')
  ].join()}
));    
''';
}

String _callCopyWithNull(String className, _Parameters parameters) {
  String _parameterToValue(_Parameter parameter) {
    String value;
    if (parameter.ignored || !parameter.nullable) {
      value = '$_value.${parameter.name}';
    } else {
      value =
          '${parameter.name} == copyWithIgnore ? $_value.${parameter.name} : ${parameter.name} ';
      if (parameter.type != 'Object?') {
        value += 'as ${parameter.type}';
      }
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
$_return call({${[
      ...requiredPositionalNullable,
      ...optionalPositionalNullable,
      ...namedNullable
    ].where((element) => !element.ignored).map((e) => 'Object? ${e.name} = copyWithIgnore,').join()}
  }) => $_callback($className(${[
      ...[
        ...parameters.requiredPositional,
        ...parameters.optionalPositional,
      ].map(_parameterToValue),
      ...parameters.named.map((e) => '${e.name} : ${_parameterToValue(e)}')
    ].join()}
));    
''';
  } else {
    return '';
  }
}

String _deepCopyWithNull(_Parameters parameters) {
  final _parameters = parameters.allParameters.where(
    (element) =>
        element is _ClassParameter &&
        element.nullable &&
        !element.ignored &&
        element.copyWithAnnotation != null &&
        element.copyWithAnnotation!.copyWithNull,
  );

  if (_parameters.isNotEmpty) {
    return _parameters.map(
      (e) {
        final generics = (e as _ClassParameter).generics;
        return '''
\$${e.className}CopyWithNull$generics? get ${e.name} {
    if ($_value.${e.name} != null) {
    return \$${e.className}CopyWithNull$generics($_value.${e.name}!, 
    (value) => $_callback($_value.copyWith(${e.name}:  value)));
  }
}''';
      },
    ).join();
  } else {
    return '';
  }
}

List<ParameterElement> _nonFieldParameters(
  ClassElement classElement,
  List<ParameterElement> parameters,
) {
  bool _superClassHasField(InterfaceType? interfaceType, String fieldName) {
    if (interfaceType != null) {
      return interfaceType.element.getField(fieldName) != null ||
          _superClassHasField(interfaceType.superclass, fieldName);
    } else {
      return false;
    }
  }

  return parameters
      .where(
        (element) =>
            classElement.getField(element.name) == null &&
            !_superClassHasField(classElement.supertype, element.name),
      )
      .toList();
}

FieldElement? _classOrSuperClassField(
  ClassElement classElement,
  String fieldName,
) {
  final fieldElement = classElement.getField(fieldName);
  if (fieldElement == null && classElement.supertype != null) {
    return _classOrSuperClassField(
      classElement.supertype!.element,
      fieldName,
    );
  } else {
    return fieldElement;
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

  List<_Parameter> get allParameters => [
        ...requiredPositional,
        ...optionalPositional,
        ...named,
      ];
}

class _Parameter {
  final bool ignored;
  final String name;
  final bool nullable;
  final String type;
  _Parameter({
    required this.ignored,
    required this.name,
    required this.nullable,
    required this.type,
  });
}

class _ClassParameter extends _Parameter {
  final String className;
  final CopyWith? copyWithAnnotation;
  _ClassParameter({
    required bool ignored,
    required String name,
    required bool nullable,
    required String type,
    required this.copyWithAnnotation,
    required this.className,
  }) : super(ignored: ignored, name: name, nullable: nullable, type: type);

  String get generics {
    final result = RegExp('<.+?>').firstMatch(type)?.group(0);
    if (copyWithAnnotation != null) {
      return result?.replaceFirst('>', ', $_return>') ?? '<$_return>';
    } else {
      return result ?? '';
    }
  }
}

import 'package:analyzer/dart/element/element.dart';
import 'package:boilerplate_generators/src/annotations.dart';
import 'package:boilerplate_generators/src/utils.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class PropsGenerator extends GeneratorForAnnotation<Props> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@Props can only be applied on classes. Failing element: ${element.name}',
        element: element,
      );
    }
    if (!element.allSupertypes.any((element) {
      final name = element.getDisplayString(withNullability: false);
      return name == 'Equatable' || name == 'EquatableMixin';
    })) {
      throw InvalidGenerationSourceError(
        '@Props can only be applied on classes that extends Equatable or uses EquatableMixin. Failing element: ${element.name}',
        element: element,
      );
    }
    final generics = genericTypes(element.typeParameters, fullName: false);
    final fields =
        element.fields.where((element) => !_isFieldExcluded(element));

    return '''
    /// @nodoc
    List<Object?> _\$${element.name}Props$generics(${element.name}$generics instance) => 
        [${fields.map((e) => 'instance.${e.name}').join(',')}];
        ''';
  }
}

bool _isFieldExcluded(FieldElement element) =>
    const TypeChecker.fromRuntime(ExcludeFromProps).hasAnnotationOf(element);

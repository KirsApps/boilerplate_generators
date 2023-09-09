import 'package:analyzer/dart/element/element.dart';
import 'package:boilerplate_annotations/boilerplate_annotations.dart';
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
        '@Props can only be applied on classes that extends Equatable or uses EquatableMixin.',
        element: element,
      );
    }
    final fullGenerics = genericTypes(element.typeParameters, fullName: true);
    final generics = genericTypes(element.typeParameters, fullName: false);
    final fields = element.fields.where(
      (element) => element.isFinal && !_isFieldExcluded(element),
    );

    return '''
// coverage:ignore-start      
    /// @nodoc
    List<Object?> _\$${element.name}Props$fullGenerics(${element.name}$generics instance,{List<Object?>? superProps}) => 
        [${fields.map((e) => 'instance.${e.name},').join()} ...?superProps];
// coverage:ignore-end
        ''';
  }
}

// TODO late, static
bool _isFieldExcluded(FieldElement element) =>
    element.isStatic ||
    element.isLate ||
    const TypeChecker.fromRuntime(PropsExclude).hasAnnotationOf(element);

import 'package:analyzer/dart/element/element.dart';
import 'package:boilerplate_generators/src/annotations.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class UnionGenerator extends GeneratorForAnnotation<Union> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@Union can only be applied on classes. Failing element: ${element.name}',
        element: element,
      );
    }
    final subTypes = element.library.units
        .expand((cu) => cu.classes)
        .where((classElement) => classElement.supertype == element.thisType)
        .toList();
    print("${element.thisType} ${element.toString()}  subtypes: $subTypes");
    return '';
  }
}

import 'package:boilerplate_generators/src/copy_with_generator.dart';
import 'package:boilerplate_generators/src/props_generator.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

/// Builds generator for Equatable props generation
Builder propsGenerator(BuilderOptions options) =>
    SharedPartBuilder([PropsGenerator()], 'props');

/// Builds generator for copyWith and copyWithNull methods generation
Builder copyWithGenerator(BuilderOptions options) =>
    SharedPartBuilder([CopyWithGenerator()], 'copy_with');

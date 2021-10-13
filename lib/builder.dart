
import 'package:boilerplate_generators/src/copy_with_generator.dart';
import 'package:boilerplate_generators/src/union_generator.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
export 'src/annotations.dart';
/// Builds generators for `build_runner` to run
Builder unionGenerator(BuilderOptions options) =>
    SharedPartBuilder([UnionGenerator()], 'union');

Builder copyWithGenerator(BuilderOptions options) =>
    SharedPartBuilder([CopyWithGenerator()], 'copy_with');

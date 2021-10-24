import 'package:boilerplate_generators/src/copy_with_generator.dart';
import 'package:boilerplate_generators/src/props_generator.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

export 'src/annotations.dart';

/// Builds generators for `build_runner` to run
Builder propsGenerator(BuilderOptions options) =>
    SharedPartBuilder([PropsGenerator()], 'props');

Builder copyWithGenerator(BuilderOptions options) =>
    SharedPartBuilder([CopyWithGenerator()], 'copy_with');

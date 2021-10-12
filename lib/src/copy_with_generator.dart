import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class CopyWithGenerator extends Generator {
  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    return '''
// Source library: ${library.element.source.uri}
const copy = 1;
''';
  }
}

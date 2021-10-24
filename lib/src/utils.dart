import 'package:analyzer/dart/element/element.dart';

String genericTypes(
  List<TypeParameterElement> typeParameters, {
  required bool fullName,
  String additionalGeneric = '',
}) =>
    typeParameters.isNotEmpty
        ? '<${typeParameters.map((e) => fullName ? e.getDisplayString(withNullability: true) : e.name).join(',')}${additionalGeneric.isNotEmpty ? ', $additionalGeneric' : ''}>'
        : additionalGeneric.isNotEmpty
            ? '<$additionalGeneric>'
            : '';

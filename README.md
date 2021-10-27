[![Build Status](https://github.com/KirsApps/boilerplate_generators/workflows/build/badge.svg)](https://github.com/KirsApps/boilerplate_generators/actions?query=workflow%3A"build"+branch%3Amaster)
[![pub](https://img.shields.io/pub/v/boilerplate_generators.svg)](https://pub.dev/packages/boilerplate_generators)
[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)

Set of code generators for reduce boilerplate code writing.

# Generators
* [CopyWith](#CopyWith)
* [Props](#Props)

# CopyWith
Code generator for copyWith and copyWithNull methods generation with deep copy support.
## Usage
Annotate class with @copyWith annotation, add part file - part 'your_file_name.g.dart', and run build_runner.
Methods copyWith and copyWithNull will be generated.
  ```dart
part 'address.g.dart';

@copyWith
class Address  {
  final String? street;
  final int? home;
  const Address({this.street, this.home});
}
  ```
If you want to disable copyWithNull method generation, you need to pass copyWithNull = false to CopyWith annotation.
  ```dart
part 'address.g.dart';

@CopyWith(copyWithNull: false)
class Address  {
final String? street;
final int? home;
const Address({this.street, this.home});
}
  ```

## copyWith and copyWithNull difference

Method copyWith refuses null.
  ```dart
@copyWith
class Payment {
final int id;
final String? description;
const Payment({required this.id, this.description});
}

const payment = Payment(id: 4, description: 'test',);

print(payment.copyWith(description: null)); // Payment(id:4, description: test)
  ```
Method copyWithNull allow copy with null value.
  ```dart
@copyWith
class Payment {
final int id;
final String? description;
const Payment({required this.id, this.description});
}

const payment = Payment(id: 4, description: 'test',);

print(payment.copyWithNull(description: null)); // Payment(id:4, description: null)
  ```

## Deep copy


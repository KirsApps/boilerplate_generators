[![Build Status](https://github.com/KirsApps/boilerplate_generators/workflows/build/badge.svg)](https://github.com/KirsApps/boilerplate_generators/actions?query=workflow%3A"build"+branch%3Amaster)
[![pub](https://img.shields.io/pub/v/boilerplate_generators.svg)](https://pub.dev/packages/boilerplate_generators)
[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)

Set of code generators for reduce boilerplate code writing.

# Generators
* [CopyWith](#CopyWith)
* [Props](#Props)

# CopyWith
Code generator for copyWith and copyWithNull methods generation with deep copy and field ignore support.
## Usage
* Annotate class with @copyWith annotation
* Add part file - part 'your_file_name.g.dart'
* Run build_runner.

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
@CopyWith(copyWithNull: false)
class Address  {
    final String? street;
    final int? home;
    const Address({this.street, this.home});
}
  ```

## copyWith and copyWithNull difference

Method copyWith rejects null.
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
With deep copy support you can call copyWith methods of objects that class contains and get a new instance of a class with updated object. 
Class and objects that the class contains must be annotated with @copyWith.

  ```dart
@copyWith
class Payment {
  final int id;
  final String? description;
  final Customer? customer;
  const Payment({required this.id, this.customer, this.description});
}

@copyWith
class Customer {
  final int id;
  final String name;
  final String surname;
  final String? patronymic;
  const Customer({
    required this.id,
    required this.name,
    required this.surname,
    this.patronymic,
  });
}

const payment = Payment(
  id: 4,
  customer: Customer(
    id: 1,
    name: 'John',
    surname: 'Dou',
  ),
);

print(payment.copyWith.customer!(name: 'Bob')); // Payment(id: 4, customer: Customer(id: 1,name: 'Bob',surname: 'Dou'))
  ```

## Ignore field
If you want a class field to be excluded from copyWith and copyWithNull methods generation, you need to annotate the field with @copyWithExclude.
In this case, it will be impossible to change the field with these methods.
  ```dart
@copyWith
class Payment {
  @copyWithExclude
  final int id;
  final String? description;
  final Customer? customer;
  const Payment({required this.id, this.customer, this.description});
}
  ```

# Props
Code generator for [equatable](https://pub.dev/packages/equatable) props generation.

## Usage
* Annotate class with @props
* Add part file - part 'your_file_name.g.dart'
* Override props getter to return _${your class name}Props(this);
* run build_runner.

```dart
part 'address.g.dart';

@props
class Address extends Equatable {
    final String? street;
    final int? home;
    const Address({this.street, this.home});
}
  @override
  List<Object?> get props => _$AddressProps(this);
}
  ```

## Super class props
If your class extends from another class that uses Equatable you need to add props from the super class. 
You need to pass super class props to *superProps* parameter.

```dart
@props
class First extends Equatable {
  final String data;
  First(this.data);

  @override
  List<Object?> get props => _$FirstProps(this);
}

@props
class Second extends First {
  final String second;
  Second(this.second, String data) : super(data);

  @override
  List<Object?> get props => _$SecondProps(this, superProps: super.props);
}
  ```

## Ignore field
If you want a class field to be excluded from props generation, you need to annotate the field with @propsExclude.
In this case, props will not contain this field.
```dart
@props
class Address extends Equatable {
    @propsExclude
    final String? street;
    final int? home;
    const Address({this.street, this.home});
}
  @override
  List<Object?> get props => _$AddressProps(this);
}
  ```
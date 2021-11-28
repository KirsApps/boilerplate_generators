import 'package:boilerplate_annotations/boilerplate_annotations.dart';
import 'package:equatable/equatable.dart';

part 'main.g.dart';

@props
@copyWith
class Payment extends Equatable {
  final int id;
  final String? description;
  final Customer? customer;
  const Payment({required this.id, this.customer, this.description});

  @override
  List<Object?> get props => _$PaymentProps(this);
}

@props
@copyWith
class Customer extends Equatable {
  final int id;
  final String name;
  final String surname;
  final String? patronymic;
  final Address? address;
  const Customer({
    required this.id,
    required this.name,
    required this.surname,
    this.patronymic,
    this.address,
  });

  @override
  List<Object?> get props => _$CustomerProps(this);
}

@props
@copyWith
class Address extends Equatable {
  final String? street;
  final int? home;
  const Address({this.street, this.home});

  @override
  List<Object?> get props => _$AddressProps(this);
}

void main(List<String> arguments) {
  const payment = Payment(
    id: 4,
    description: 'test',
    customer: Customer(id: 1, name: 'John', surname: 'Dou', patronymic: 'test'),
  );

  payment.copyWith(
    description: null,
  ); // == Payment(id: 4,description: 'test',customer:Customer(id: 1, name: 'John', surname: 'Dou', patronymic: 'test'),),),);
}

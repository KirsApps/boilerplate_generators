import 'package:boilerplate_annotations/boilerplate_annotations.dart';
import 'package:equatable/equatable.dart';
import 'package:test/test.dart';

part 'boilerplate_generators_test.g.dart';

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

void main() {
  test('copyWith', () {
    const payment = Payment(id: 4);
    expect(
      payment.copyWith(
        customer: const Customer(id: 1, name: 'John', surname: 'Dou'),
      ),
      equals(
        const Payment(
          id: 4,
          customer: Customer(id: 1, name: 'John', surname: 'Dou'),
        ),
      ),
    );
    expect(
      payment.copyWith(
        id: 6,
      ),
      equals(
        const Payment(
          id: 6,
        ),
      ),
    );
  });
  test('copyWith rejects null', () {
    const payment = Payment(
      id: 4,
      description: 'test',
      customer:
          Customer(id: 1, name: 'John', surname: 'Dou', patronymic: 'test'),
    );
    expect(
      payment.copyWith(
        description: null,
      ),
      equals(
        const Payment(
          id: 4,
          description: 'test',
          customer:
              Customer(id: 1, name: 'John', surname: 'Dou', patronymic: 'test'),
        ),
      ),
    );
    expect(
      payment.copyWith.customer!(patronymic: null),
      equals(
        const Payment(
          id: 4,
          description: 'test',
          customer:
              Customer(id: 1, name: 'John', surname: 'Dou', patronymic: 'test'),
        ),
      ),
    );
  });
  test('deep copyWith', () {
    const payment = Payment(
      id: 4,
      customer: Customer(
        id: 1,
        name: 'John',
        surname: 'Dou',
        address: Address(street: 'string'),
      ),
    );
    expect(
      payment.copyWith.customer!(address: const Address(street: 'test')),
      equals(
        const Payment(
          id: 4,
          customer: Customer(
            id: 1,
            name: 'John',
            surname: 'Dou',
            address: Address(street: 'test'),
          ),
        ),
      ),
    );
    expect(
      payment.copyWith.customer!.address!(street: 'new street'),
      equals(
        const Payment(
          id: 4,
          customer: Customer(
            id: 1,
            name: 'John',
            surname: 'Dou',
            address: Address(street: 'new street'),
          ),
        ),
      ),
    );
  });
  test('copyWithNull', () {
    const payment = Payment(
      id: 4,
      description: 'test',
      customer: Customer(
        id: 1,
        name: 'John',
        surname: 'Dou',
        patronymic: 'patronymic',
        address: Address(street: 'new street'),
      ),
    );
    expect(
      payment.copyWithNull(
        description: null,
      ),
      equals(
        const Payment(
          id: 4,
          customer: Customer(
            id: 1,
            name: 'John',
            surname: 'Dou',
            patronymic: 'patronymic',
            address: Address(street: 'new street'),
          ),
        ),
      ),
    );
    expect(
      payment.copyWithNull(
        customer: null,
      ),
      equals(
        const Payment(
          id: 4,
          description: 'test',
        ),
      ),
    );
  });
  test('deep copyWithNull', () {
    const payment = Payment(
      id: 4,
      description: 'test',
      customer: Customer(
        id: 1,
        name: 'John',
        surname: 'Dou',
        patronymic: 'patronymic',
        address: Address(street: 'new street'),
      ),
    );
    expect(
      payment.copyWithNull.customer!(patronymic: null),
      equals(
        const Payment(
          id: 4,
          description: 'test',
          customer: Customer(
            id: 1,
            name: 'John',
            surname: 'Dou',
            address: Address(street: 'new street'),
          ),
        ),
      ),
    );
    expect(
      payment.copyWithNull.customer!.address!(street: null),
      equals(
        const Payment(
          id: 4,
          description: 'test',
          customer: Customer(
            id: 1,
            name: 'John',
            surname: 'Dou',
            patronymic: 'patronymic',
            address: Address(),
          ),
        ),
      ),
    );
  });
}

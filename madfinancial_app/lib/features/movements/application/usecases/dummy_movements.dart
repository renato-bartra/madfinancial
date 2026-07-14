import '../../domain/entities/account.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/movement.dart';
import '../../domain/entities/movement_type.dart';

List<Movement> buildDummyMovements(DateTime month) {
  final baseDate = DateTime(
    month.year,
    month.month,
    DateTime.now().day.clamp(1, 25),
  );
  const income = MovementType(id: 1, description: 'Ingreso');
  const expense = MovementType(id: 2, description: 'Gasto');
  const cash = Account(id: 1, description: 'Efectivo');
  const salary = Account(id: 2, description: 'Sueldo');
  const card = Account(id: 3, description: 'Tarjeta');

  return [
    Movement(
      id: 1,
      userId: 0,
      title: 'Compras supermercado',
      description: 'Plaza Vea',
      amount: 150,
      accountingDate: baseDate,
      type: expense,
      category: const Category(
        id: 3,
        isExpenseCategory: true,
        description: 'Supermercado',
        iconName: 'shopping_cart_rounded',
      ),
      account: card,
      tags: const [],
      submovements: const [],
    ),
    Movement(
      id: 2,
      userId: 0,
      title: 'Sueldo mensual',
      description: 'Planilla mensual',
      amount: 3500,
      accountingDate: baseDate.subtract(const Duration(days: 1)),
      type: income,
      category: const Category(
        id: 4,
        isExpenseCategory: false,
        description: 'Sueldo',
        iconName: 'payments_rounded',
      ),
      account: salary,
      tags: const [],
      submovements: const [],
    ),
    Movement(
      id: 3,
      userId: 0,
      title: 'Cena con amigos',
      description: 'Restaurante',
      amount: 85.50,
      accountingDate: baseDate.subtract(const Duration(days: 2)),
      type: expense,
      category: const Category(
        id: 5,
        isExpenseCategory: true,
        description: 'Restaurante',
        iconName: 'restaurant_rounded',
      ),
      account: cash,
      tags: const [],
      submovements: const [],
    ),
    Movement(
      id: 4,
      userId: 0,
      title: 'Gasolina',
      description: 'Transporte',
      amount: 60,
      accountingDate: baseDate.subtract(const Duration(days: 3)),
      type: expense,
      category: const Category(
        id: 6,
        isExpenseCategory: true,
        description: 'Transporte',
        iconName: 'local_taxi_rounded',
      ),
      account: card,
      tags: const [],
      submovements: const [],
    ),
    Movement(
      id: 5,
      userId: 0,
      title: 'Netflix',
      description: 'Suscripción mensual',
      amount: 39.90,
      accountingDate: baseDate.subtract(const Duration(days: 4)),
      type: expense,
      category: const Category(
        id: 7,
        isExpenseCategory: true,
        description: 'Entretenimiento',
        iconName: 'subscriptions_rounded',
      ),
      account: card,
      tags: const [],
      submovements: const [],
    ),
  ];
}

import 'package:hive/hive.dart';

part 'budget_entry.g.dart';

@HiveType(typeId: 0)
class BudgetEntry extends HiveObject {
  @HiveField(0)
  late String description;

  @HiveField(1)
  late double amount;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late bool isExpense;

  BudgetEntry({
    required this.description,
    required this.amount,
    required this.date,
    required this.isExpense,
  });
}

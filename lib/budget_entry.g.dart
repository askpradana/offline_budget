// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetEntryAdapter extends TypeAdapter<BudgetEntry> {
  @override
  final int typeId = 0;

  @override
  BudgetEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetEntry(
      description: fields[0] as String,
      amount: fields[1] as double,
      date: fields[2] as DateTime,
      isExpense: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.description)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.isExpense);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

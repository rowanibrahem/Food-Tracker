// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealAdapter extends TypeAdapter<Meal> {
  @override
  final int typeId = 1;

  @override
  Meal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Meal(
      name: fields[0] as String,
      details: fields[1] as String,
      time: fields[2] as String,
      type: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Meal obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.details)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DrinkAdapter extends TypeAdapter<Drink> {
  @override
  final int typeId = 3;

  @override
  Drink read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Drink(
      name: fields[0] as String,
      sugarSpoons: fields[1] as int,
      time: fields[2] as String,
      afterMeal: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Drink obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.sugarSpoons)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.afterMeal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrinkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DayModelAdapter extends TypeAdapter<DayModel> {
  @override
  final int typeId = 2;

  @override
  DayModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayModel(
      date: fields[0] as String,
      meals: (fields[1] as List).cast<Meal>(),
      waterCups: fields[2] as int,
      drinks: (fields[3] as List?)?.cast<Drink>(),
    );
  }

  @override
  void write(BinaryWriter writer, DayModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.meals)
      ..writeByte(2)
      ..write(obj.waterCups)
      ..writeByte(3)
      ..write(obj.drinks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

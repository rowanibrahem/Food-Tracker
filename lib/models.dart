import 'package:hive_flutter/hive_flutter.dart';

part 'models.g.dart';

// -------------------- MODELS --------------------
@HiveType(typeId: 1)
class Meal extends HiveObject {
  @HiveField(0)
  String name;
  
  @HiveField(1)
  String details;
  
  @HiveField(2)
  String time;
  
  @HiveField(3)
  String type; // 'main' or 'snack'

  Meal({
    required this.name,
    required this.details,
    required this.time,
    required this.type,
  });
}

@HiveType(typeId: 2)
class DayModel extends HiveObject {
  @HiveField(0)
  String date;
  
  @HiveField(1)
  List<Meal> meals;
  
  @HiveField(2)
  int waterCups;

  DayModel({
    required this.date,
    required this.meals,
    this.waterCups = 0,
  });
}
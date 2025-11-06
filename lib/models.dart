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
@HiveType(typeId: 3) // نوع جديد للمشروبات
class Drink extends HiveObject {
  @HiveField(0)
  String name;
  
  @HiveField(1)
  int sugarSpoons; // عدد ملاعق السكر
  
  @HiveField(2)
  String time;
  
  @HiveField(3)
  String? afterMeal; // بعد أي وجبة (اسم الوجبة)

  Drink({
    required this.name,
    required this.sugarSpoons,
    required this.time,
    this.afterMeal,
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
  
   @HiveField(3) // حقل جديد للمشروبات
  List<Drink> drinks;

  DayModel({
    required this.date,
    required this.meals,
    this.waterCups = 0,
    List<Drink>? drinks,
  }) : drinks = drinks ?? [];
}
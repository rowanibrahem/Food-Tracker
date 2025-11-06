import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:my_food_tracker/cubit_state.dart';
import 'package:my_food_tracker/models.dart';

class DayCubit extends Cubit<DayState> {
  DayCubit() : super(DayInitial());

  Box<DayModel>? box;

  Future init() async {
    box = await Hive.openBox<DayModel>('daysBox');
    loadDays();
  }

  void loadDays() {
    if (box != null) {
      emit(DayLoaded(box!.values.toList()));
    }
  }

  Future addDay(String date) async {
    await box!.add(DayModel(date: date, meals: [], waterCups: 0));
    loadDays();
  }

  Future addMeal(int dayIndex, Meal meal) async {
    final day = box!.getAt(dayIndex);
    day!.meals.add(meal);
    await day.save();
    loadDays();
  }

  Future editMeal(int dayIndex, int mealIndex, Meal updatedMeal) async {
    final day = box!.getAt(dayIndex);
    day!.meals[mealIndex] = updatedMeal;
    await day.save();
    loadDays();
  }

  Future deleteMeal(int dayIndex, int mealIndex) async {
    final day = box!.getAt(dayIndex);
    day!.meals.removeAt(mealIndex);
    await day.save();
    loadDays();
  }

  Future updateWater(int dayIndex, int amount) async {
    final day = box!.getAt(dayIndex);
    day!.waterCups = amount;
    await day.save();
    loadDays();
  }
Future addDrink(int dayIndex, Drink drink) async {
    final day = box!.getAt(dayIndex);
    day!.drinks.add(drink);
    await day.save();
    loadDays();
  }

  Future editDrink(int dayIndex, int drinkIndex, Drink updatedDrink) async {
    final day = box!.getAt(dayIndex);
    day!.drinks[drinkIndex] = updatedDrink;
    await day.save();
    loadDays();
  }

  Future deleteDrink(int dayIndex, int drinkIndex) async {
    final day = box!.getAt(dayIndex);
    day!.drinks.removeAt(drinkIndex);
    await day.save();
    loadDays();
  }
}
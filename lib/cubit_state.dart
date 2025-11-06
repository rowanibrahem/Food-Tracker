import 'package:my_food_tracker/models.dart';

abstract class DayState {}
class DayInitial extends DayState {}
class DayLoaded extends DayState {
  final List<DayModel> days;
  DayLoaded(this.days);
}

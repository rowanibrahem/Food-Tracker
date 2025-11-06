import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_food_tracker/add_day_page.dart';
import 'package:my_food_tracker/cubit.dart';
import 'package:my_food_tracker/cubit_state.dart';
import 'package:my_food_tracker/day_details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rowan Health Tracker 🩷', textAlign: TextAlign.center),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddDayPage()),
          );
        },
      ),
      body: BlocBuilder<DayCubit, DayState>(
        builder: (context, state) {
          if (state is DayLoaded) {
            if (state.days.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fastfood, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No days added yet!',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    Text(
                      'Tap + to add your first day',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "You Can Do it , Just Believe in Your Self 🩷✨",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.days.length,
                    itemBuilder: (context, index) {
                      final day = state.days[index];
                      // استخراج اسم اليوم من النص إذا كان موجود
                      String displayDate = day.date;
                      String dayName = '';

                      if (day.date.contains('(')) {
                        final parts = day.date.split('(');
                        displayDate = parts[0].trim();
                        dayName = parts[1].replaceAll(')', '').trim();
                      }

                      return Card(
                        margin: EdgeInsets.all(12),
                        child: ListTile(
                          title: Row(
                            children: [
                              Text(
                                displayDate,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              if (dayName.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    dayName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.teal,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            'Meals: ${day.meals.length}   •   Water: ${day.waterCups} cups',
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DayDetailsPage(dayIndex: index),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

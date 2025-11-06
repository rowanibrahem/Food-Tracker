import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_food_tracker/add_meal.dart';
import 'package:my_food_tracker/addd_drink_page.dart';
import 'package:my_food_tracker/cubit.dart';
import 'package:my_food_tracker/cubit_state.dart';
import 'package:my_food_tracker/edit_meal.dart';

class DayDetailsPage extends StatelessWidget {
  final int dayIndex;
  const DayDetailsPage({super.key, required this.dayIndex});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DayCubit, DayState>(
      builder: (context, state) {
        if (state is! DayLoaded)
          return Center(child: CircularProgressIndicator());

        final cubit = context.read<DayCubit>();
        final day = state.days[dayIndex];

        return Scaffold(
          appBar: AppBar(title: Text(day.date)),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // زر إضافة مشروب
              FloatingActionButton(
                heroTag: 'add_drink', // مهم علشان متكنش في مشاكل مع الأنيشيشن
                mini: true,
                child: Icon(Icons.local_drink, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => AddDrinkPage(
                            dayIndex: dayIndex,
                            meals: day.meals,
                          ),
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              // زر إضافة وجبة
              FloatingActionButton(
                heroTag: 'add_meal',
                child: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddMealPage(dayIndex: dayIndex),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Water Tracker
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Water Tracker 💧',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.blue),
                            onPressed: () {
                              if (day.waterCups > 0)
                                cubit.updateWater(dayIndex, day.waterCups - 1);
                            },
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${day.waterCups} Bottles',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle, color: Colors.blue),
                            onPressed: () {
                              cubit.updateWater(dayIndex, day.waterCups + 1);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // -------------------- DRINKS SECTION --------------------
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.local_drink,
                                color: Colors.purple[700],
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Drinks Today ☕',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple[700],
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            icon: Icon(Icons.add, size: 16),
                            label: Text('Add Drink'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => AddDrinkPage(
                                        dayIndex: dayIndex,
                                        meals: day.meals,
                                      ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      if (day.drinks.isNotEmpty)
                        Column(
                          children:
                              day.drinks.asMap().entries.map((entry) {
                                final index = entry.key;
                                final drink = entry.value;
                                return Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    leading: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            drink.sugarSpoons == 0
                                                ? Colors.green[100]
                                                : drink.sugarSpoons <= 2
                                                ? Colors.orange[100]
                                                : Colors.red[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.local_drink,
                                        color:
                                            drink.sugarSpoons == 0
                                                ? Colors.green
                                                : drink.sugarSpoons <= 2
                                                ? Colors.orange
                                                : Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      drink.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${drink.sugarSpoons} sugar spoon${drink.sugarSpoons == 1 ? '' : 's'} 🥄',
                                        ),
                                        if (drink.afterMeal != null)
                                          Text(
                                            'After ${drink.afterMeal}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: Text(
                                      drink.time,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    onTap: () {
                                      // ممكن نضيف تعديل للمشروب في المستقبل
                                    },
                                    onLongPress: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: Text('Delete Drink?'),
                                              content: Text(
                                                'Are you sure you want to delete "${drink.name}"?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    cubit.deleteDrink(
                                                      dayIndex,
                                                      index,
                                                    );
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                        )
                      else
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.local_drink,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No drinks added yet',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                'Tap + to add your first drink',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Divider(),

                // Meals List
                Container(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.restaurant, color: Colors.teal[700]),
                          SizedBox(width: 8),
                          Text(
                            'Meals Today 🍽️',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      if (day.meals.isEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 8),
                              Center(
                                child: Text(
                                  'No meals added yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Text(
                                'Tap + to add your first meal',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children:
                              day.meals.asMap().entries.map((entry) {
                                final index = entry.key;
                                final meal = entry.value;
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 6),
                                  child: ListTile(
                                    leading: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            meal.type == 'main'
                                                ? Colors.teal[100]
                                                : Colors.orange[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        meal.type == 'main' ? '🍽️' : '🍎',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    title: Text(
                                      meal.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(meal.details),
                                        SizedBox(height: 4),
                                        Text(
                                          '⏰ ${meal.time}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: PopupMenuButton(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => EditMealPage(
                                                    dayIndex: dayIndex,
                                                    mealIndex: index,
                                                    meal: meal,
                                                  ),
                                            ),
                                          );
                                        } else if (value == 'delete') {
                                          showDialog(
                                            context: context,
                                            builder:
                                                (context) => AlertDialog(
                                                  title: Text('Delete Meal?'),
                                                  content: Text(
                                                    'Are you sure you want to delete "${meal.name}"?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                          ),
                                                      child: Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        cubit.deleteMeal(
                                                          dayIndex,
                                                          index,
                                                        );
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );
                                        }
                                      },
                                      itemBuilder:
                                          (context) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Edit'),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            ),
                                          ],
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

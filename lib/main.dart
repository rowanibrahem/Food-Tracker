import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_food_tracker/models.dart';


// -------------------- CUBIT STATE --------------------
abstract class DayState {}
class DayInitial extends DayState {}
class DayLoaded extends DayState {
  final List<DayModel> days;
  DayLoaded(this.days);
}

// -------------------- CUBIT --------------------
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

// -------------------- MAIN APP --------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  Hive.registerAdapter(MealAdapter());
  Hive.registerAdapter(DayModelAdapter());
  Hive.registerAdapter(DrinkAdapter());
  

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DayCubit()..init(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
        theme: ThemeData(primarySwatch: Colors.teal),
      ),
    );
  }
}

// -------------------- HOME PAGE --------------------
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Food Diary 💚')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddDayPage()));
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
            
            return ListView.builder(
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
                        Text(displayDate, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        if (dayName.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.teal,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text('Meals: ${day.meals.length}   •   Water: ${day.waterCups} cups'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => DayDetailsPage(dayIndex: index),
                      ));
                    },
                  ),
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

// -------------------- ADD DAY --------------------
class AddDayPage extends StatelessWidget {
  final dateCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Day')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: dateCtrl,
              decoration: InputDecoration(
                labelText: 'Pick Date',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                   final dayName = _getDayName(date.weekday);
                  // Format date as yyyy-mm-dd
                  dateCtrl.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ($dayName)";
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (dateCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please pick a date')),
                  );
                  return;
                }
                context.read<DayCubit>().addDay(dateCtrl.text);
                Navigator.pop(context);
              },
              child: Text('Save Day'),
            )
          ],
        ),
      ),
    );
  }
String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }
}

// -------------------- DAY DETAILS --------------------
class DayDetailsPage extends StatelessWidget {
  final int dayIndex;
  DayDetailsPage({required this.dayIndex});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DayCubit, DayState>(
      builder: (context, state) {
        if (state is! DayLoaded) return Center(child: CircularProgressIndicator());
        
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
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => AddDrinkPage(
                      dayIndex: dayIndex,
                      meals: day.meals,
                    )
                  ));
                },
              ),
              SizedBox(height: 10),
              // زر إضافة وجبة
              FloatingActionButton(
                heroTag: 'add_meal',
                child: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => AddMealPage(dayIndex: dayIndex)
                  ));
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
                      Text('Water Tracker 💧', style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700]
                      )),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.blue),
                            onPressed: () {
                              if (day.waterCups > 0) cubit.updateWater(dayIndex, day.waterCups - 1);
                            },
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${day.waterCups} cups', style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold
                            )),
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
                              Icon(Icons.local_drink, color: Colors.purple[700]),
                              SizedBox(width: 8),
                              Text(
                                'Drinks Today ☕',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple[700]
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
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => AddDrinkPage(
                                  dayIndex: dayIndex,
                                  meals: day.meals,
                                )
                              ));
                            },
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 12),
                      
                      if (day.drinks.isNotEmpty) 
                        Column(
                          children: day.drinks.asMap().entries.map((entry) {
                            final index = entry.key;
                            final drink = entry.value;
                            return Container(
                              margin: EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                leading: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: drink.sugarSpoons == 0 ? Colors.green[100] : 
                                           drink.sugarSpoons <= 2 ? Colors.orange[100] : Colors.red[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.local_drink,
                                    color: drink.sugarSpoons == 0 ? Colors.green : 
                                           drink.sugarSpoons <= 2 ? Colors.orange : Colors.red,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  drink.name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${drink.sugarSpoons} sugar spoon${drink.sugarSpoons == 1 ? '' : 's'} 🥄'),
                                    if (drink.afterMeal != null)
                                      Text(
                                        'After ${drink.afterMeal}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                  ],
                                ),
                                trailing: Text(
                                  drink.time,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                onTap: () {
                                  // ممكن نضيف تعديل للمشروب في المستقبل
                                },
                                onLongPress: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Delete Drink?'),
                                      content: Text('Are you sure you want to delete "${drink.name}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            cubit.deleteDrink(dayIndex, index);
                                            Navigator.pop(context);
                                          },
                                          child: Text('Delete', style: TextStyle(color: Colors.red)),
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
                              Icon(Icons.local_drink, size: 40, color: Colors.grey[400]),
                              SizedBox(height: 8),
                              Text(
                                'No drinks added yet',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                'Tap + to add your first drink',
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
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
                              color: Colors.teal[700]
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      
                      if (day.meals.isEmpty) 
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(Icons.restaurant, size: 50, color: Colors.grey[400]),
                              SizedBox(height: 8),
                              Text(
                                'No meals added yet',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
                          children: day.meals.asMap().entries.map((entry) {
                            final index = entry.key;
                            final meal = entry.value;
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: meal.type == 'main' ? Colors.teal[100] : Colors.orange[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    meal.type == 'main' ? '🍽️' : '🍎',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                title: Text(meal.name, style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(meal.details),
                                    SizedBox(height: 4),
                                    Text('⏰ ${meal.time}', style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600]
                                    )),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (_) => EditMealPage(
                                          dayIndex: dayIndex, 
                                          mealIndex: index, 
                                          meal: meal
                                        ),
                                      ));
                                    } else if (value == 'delete') {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Delete Meal?'),
                                          content: Text('Are you sure you want to delete "${meal.name}"?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                cubit.deleteMeal(dayIndex, index);
                                                Navigator.pop(context);
                                              },
                                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                                    PopupMenuItem(value: 'delete', child: Text('Delete')),
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

// -------------------- ADD MEAL --------------------
class AddMealPage extends StatefulWidget {
  final int dayIndex;
  AddMealPage({required this.dayIndex});

  @override
  _AddMealPageState createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  final nameCtrl = TextEditingController();
  final detailsCtrl = TextEditingController();
  final timeCtrl = TextEditingController();
  String selectedType = 'main';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Meal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Meal Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: detailsCtrl,
              decoration: InputDecoration(
                labelText: 'Details (Ingredients, Notes...)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: timeCtrl,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Pick Time',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    timeCtrl.text = time.format(context);
                  });
                }
              },
            ),
            SizedBox(height: 16),
            // Meal Type Selection
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedType,
                  items: [
                    DropdownMenuItem(
                      value: 'main',
                      child: Row(
                        children: [
                          Icon(Icons.restaurant, color: Colors.teal),
                          SizedBox(width: 8),
                          Text('Main Meal'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'snack',
                      child: Row(
                        children: [
                          Icon(Icons.local_cafe, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Snack'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty || timeCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }
                context.read<DayCubit>().addMeal(
                  widget.dayIndex,
                  Meal(
                    name: nameCtrl.text,
                    details: detailsCtrl.text,
                    time: timeCtrl.text,
                    type: selectedType,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Save Meal', style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}

// -------------------- EDIT MEAL --------------------
class EditMealPage extends StatefulWidget {
  final int dayIndex;
  final int mealIndex;
  final Meal meal;

  EditMealPage({
    required this.dayIndex,
    required this.mealIndex,
    required this.meal,
  });

  @override
  _EditMealPageState createState() => _EditMealPageState();
}

class _EditMealPageState extends State<EditMealPage> {
  late TextEditingController nameCtrl;
  late TextEditingController detailsCtrl;
  late TextEditingController timeCtrl;
  late String selectedType;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.meal.name);
    detailsCtrl = TextEditingController(text: widget.meal.details);
    timeCtrl = TextEditingController(text: widget.meal.time);
    selectedType = widget.meal.type;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Meal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Meal Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: detailsCtrl,
              decoration: InputDecoration(
                labelText: 'Details',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: timeCtrl,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Pick Time',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    timeCtrl.text = time.format(context);
                  });
                }
              },
            ),
            SizedBox(height: 16),
            // Meal Type Selection
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedType,
                  items: [
                    DropdownMenuItem(
                      value: 'main',
                      child: Row(
                        children: [
                          Icon(Icons.restaurant, color: Colors.teal),
                          SizedBox(width: 8),
                          Text('Main Meal'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'snack',
                      child: Row(
                        children: [
                          Icon(Icons.local_cafe, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Snack'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty || timeCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }
                context.read<DayCubit>().editMeal(
                  widget.dayIndex,
                  widget.mealIndex,
                  Meal(
                    name: nameCtrl.text,
                    details: detailsCtrl.text,
                    time: timeCtrl.text,
                    type: selectedType,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Update Meal', style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}

// -------------------- ADD DRINK PAGE --------------------
class AddDrinkPage extends StatefulWidget {
  final int dayIndex;
  final List<Meal> meals;

  AddDrinkPage({required this.dayIndex, required this.meals});

  @override
  _AddDrinkPageState createState() => _AddDrinkPageState();
}

class _AddDrinkPageState extends State<AddDrinkPage> {
  final nameCtrl = TextEditingController();
  final timeCtrl = TextEditingController();
  int sugarSpoons = 0;
  String? selectedAfterMeal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Drink')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Drink Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_drink),
              ),
            ),
            SizedBox(height: 16),
            
            // عدد ملاعق السكر
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Sugar Spoons 🥄',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          if (sugarSpoons > 0) {
                            setState(() {
                              sugarSpoons--;
                            });
                          }
                        },
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: sugarSpoons == 0 ? Colors.green[50] : 
                                 sugarSpoons <= 2 ? Colors.yellow[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$sugarSpoons spoons',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: sugarSpoons == 0 ? Colors.green : 
                                   sugarSpoons <= 2 ? Colors.orange : Colors.red,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            sugarSpoons++;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    sugarSpoons == 0 ? 'No sugar - Great! 👍' :
                    sugarSpoons <= 2 ? 'Moderate sugar 👌' :
                    'High sugar! ⚠️',
                    style: TextStyle(
                      color: sugarSpoons == 0 ? Colors.green : 
                             sugarSpoons <= 2 ? Colors.orange : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            
            // الوقت
            TextField(
              controller: timeCtrl,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    timeCtrl.text = time.format(context);
                  });
                }
              },
            ),
            SizedBox(height: 16),
            
            // بعد أي وجبة
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedAfterMeal,
                  isExpanded: true,
                  hint: Text('After which meal? (Optional)'),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Not after a meal'),
                    ),
                    ...widget.meals.map((meal) {
                      return DropdownMenuItem(
                        value: meal.name,
                        child: Text('After: ${meal.name}'),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedAfterMeal = value;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty || timeCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill drink name and time')),
                  );
                  return;
                }
                
                context.read<DayCubit>().addDrink(
                  widget.dayIndex,
                  Drink(
                    name: nameCtrl.text,
                    sugarSpoons: sugarSpoons,
                    time: timeCtrl.text,
                    afterMeal: selectedAfterMeal,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Save Drink', style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}
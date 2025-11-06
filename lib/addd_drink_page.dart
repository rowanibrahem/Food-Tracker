import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_food_tracker/cubit.dart';
import 'package:my_food_tracker/models.dart';

class AddDrinkPage extends StatefulWidget {
  final int dayIndex;
  final List<Meal> meals;

  const AddDrinkPage({super.key, required this.dayIndex, required this.meals});

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
            // SizedBox(height: 16),
            
            // بعد أي وجبة
            // Container(
            //   width: double.infinity,
            //   padding: EdgeInsets.symmetric(horizontal: 12),
            //   decoration: BoxDecoration(
            //     border: Border.all(color: Colors.grey),
            //     borderRadius: BorderRadius.circular(4),
            //   ),
            //   child: DropdownButtonHideUnderline(
            //     child: DropdownButton<String>(
            //       value: selectedAfterMeal,
            //       isExpanded: true,
            //       hint: Text('After which meal? (Optional)'),
            //       items: [
            //         DropdownMenuItem(
            //           value: null,
            //           child: Text('Not after a meal'),
            //         ),
            //         ...widget.meals.map((meal) {
            //           return DropdownMenuItem(
            //             value: meal.name,
            //             child: Text('After: ${meal.name}'),
            //           );
            //         }).toList(),
            //       ],
            //       onChanged: (value) {
            //         setState(() {
            //           selectedAfterMeal = value;
            //         });
            //       },
            //     ),
            //   ),
            // ),
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
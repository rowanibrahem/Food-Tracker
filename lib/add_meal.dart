import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_food_tracker/cubit.dart';
import 'package:my_food_tracker/models.dart';

class AddMealPage extends StatefulWidget {
  final int dayIndex;
  const AddMealPage({super.key, required this.dayIndex});

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

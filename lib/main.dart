import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_food_tracker/cubit.dart';
import 'package:my_food_tracker/home_page.dart';
import 'package:my_food_tracker/models.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  Hive.registerAdapter(MealAdapter());
  Hive.registerAdapter(DayModelAdapter());
  Hive.registerAdapter(DrinkAdapter());
  

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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








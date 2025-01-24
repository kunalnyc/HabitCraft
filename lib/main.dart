import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/Logic/habit_adaptar.dart';
import 'package:habit_tracker/screens/home.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and register the adapter
  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp (
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      home: HomeScreen(),
    );
  }
}

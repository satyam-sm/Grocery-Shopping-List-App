import 'package:flutter/material.dart';
import 'package:shopping_list/widgets/grocery_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Groceries',
        theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 0, 0),
            brightness: Brightness.dark,
            surface: const Color.fromARGB(255, 158, 66, 5),
          ),
          scaffoldBackgroundColor: const Color.fromARGB(255, 19, 38, 65),
        ),
        home: const GroceryList());
  }
}

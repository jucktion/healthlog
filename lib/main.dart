import 'package:flutter/material.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/view/users.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHandler().initializeDB();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      debugShowCheckedModeBanner: false,
      home: const UserScreen(),
    );
  }
}

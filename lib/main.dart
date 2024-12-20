import 'package:flutter/material.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/view/theme/style.dart';
import 'package:healthlog/view/users/users.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHandler.instance.initializeDB();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health',
      theme: healthTheme,
      darkTheme: healthDark,
      debugShowCheckedModeBanner: false,
      home: const UserScreen(),
    );
  }
}

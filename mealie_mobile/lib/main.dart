import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MealieMobileApp());
}

class MealieMobileApp extends StatelessWidget {
  const MealieMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mealie Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

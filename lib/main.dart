import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/result_screen.dart'; // Import ResultScreen instead of SearchScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Enable Firebase Analytics collection

    // Initialize Firebase service

    runApp(const MyApp());
  } catch (e) {
    debugPrint('Failed to initialize Firebase: $e');
    // Still run the app even if Firebase fails to initialize
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ResultScreen(), // Set ResultScreen as the starting screen
    );
  }
}

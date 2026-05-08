import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/yonetici_home_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ntykrlmphfizmisdaslh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50eWtybG1waGZpem1pc2Rhc2xoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5MzU4MDIsImV4cCI6MjA5MjUxMTgwMn0.l3q79FHW9yG3MHC0TUZHElJ23-blbPEu5iLeu40bflM',
  );

  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool darkMode = false;

  void toggleTheme(bool value) {
    setState(() {
      darkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
  debugShowCheckedModeBanner: false,
  home: LoginScreen(),
);
  }
} 
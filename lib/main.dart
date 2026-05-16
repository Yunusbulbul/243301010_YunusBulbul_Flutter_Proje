import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/yonetici_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/fatura_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ntykrlmphfizmisdaslh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50eWtybG1waGZpem1pc2Rhc2xoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5MzU4MDIsImV4cCI6MjA5MjUxMTgwMn0.l3q79FHW9yG3MHC0TUZHElJ23-blbPEu5iLeu40bflM',
  );

  runApp(MyApp());
}
Future<Widget> baslangicEkrani() async {

  final prefs =
      await SharedPreferences
          .getInstance();

  final yoneticiMi =
      prefs.getBool(
    'yonetici_mi',
  );

  if (yoneticiMi == true) {

    final yoneticiId =
        prefs.getInt(
      'yonetici_id',
    );

    final firmaId =
        prefs.getInt(
      'firma_id',
    );

    if (yoneticiId != null &&
        firmaId != null) {

      return YoneticiHomeScreen(

        yoneticiId:
            yoneticiId,

        firmaId:
            firmaId,
      );
    }
  }

  final kullaniciId =
      prefs.getInt(
    'kullanici_id',
  );

  if (kullaniciId != null) {

    return FaturalarScreen(
      kullaniciId: kullaniciId,
    );
  }

  return const LoginScreen();
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
 home: FutureBuilder(

  future: baslangicEkrani(),

  builder: (context, snapshot) {

    if (!snapshot.hasData) {

      return const Scaffold(

        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return snapshot.data!;
  },
),
);
  }
} 
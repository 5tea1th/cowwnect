import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cow Breed Classifier',
      theme: ThemeData(
        primaryColor: Color(0xFFE1BEE7),
        scaffoldBackgroundColor: Color(0xFFFFE4E1),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFBC84FF),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFF8BBD0),
          foregroundColor: Colors.white,
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B0082),
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Color(0xFF6A5ACD),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
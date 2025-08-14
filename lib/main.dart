import 'package:asisten_guru/screens/rpp_ai_input_screen.dart';
import 'package:asisten_guru/screens/question_generator_screen.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'screens/student_list_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/attendance_history_screen.dart';
import 'screens/class_list_screen.dart';
import 'screens/subject_list_screen.dart';
import 'screens/quiz_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asisten Guru',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black54,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.deepPurple),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Placeholder pages for each tab
  static const List<Widget> _widgetOptions = <Widget>[
    StudentListScreen(),
    AttendanceScreen(),
    AttendanceHistoryScreen(),
    ClassListScreen(),
    SubjectListScreen(),
    QuizListScreen(),
    RppAiInputScreen(),
    QuestionGeneratorScreen(),
  ];

  static const List<Color> _menuColors = [
    Colors.blue,      // For Siswa
    Colors.green,     // For Absensi
    Colors.orange,    // For Riwayat
    Colors.red,       // For Kelas
    Colors.purple,    // For Mapel
    Colors.indigo,    // For Pembuat Soal
    Colors.brown,     // For RPP AI
    Colors.teal,      // For Generator Soal AI
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = _menuColors[_selectedIndex];

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: selectedColor),
        appBarTheme: Theme.of(context).appBarTheme.copyWith(
              backgroundColor: selectedColor,
            ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: selectedColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: selectedColor, width: 2),
              ),
              labelStyle: TextStyle(color: selectedColor),
            ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Asisten Guru'),
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Siswa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist),
              label: 'Absensi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.class_),
              label: 'Kelas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Mapel',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.quiz),
              label: 'Soal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome),
              label: 'RPP AI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_fix_high),
              label: 'Generator Soal AI',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: selectedColor,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}

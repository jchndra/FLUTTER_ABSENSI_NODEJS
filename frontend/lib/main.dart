import 'package:absensi_club_olahraga/screens/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:absensi_club_olahraga/screens/login_screen.dart';
import 'package:absensi_club_olahraga/screens/main_screen.dart';
import 'package:absensi_club_olahraga/screens/member_list_screen.dart';
import 'package:absensi_club_olahraga/screens/attendance_screen.dart';
import 'package:absensi_club_olahraga/screens/attendance_history_screen.dart';
import 'package:absensi_club_olahraga/screens/club_settings_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- 1. TAMBAHKAN GlobalKey DI SINI ---
// Kunci ini akan berfungsi sebagai "pegangan" untuk mengakses MainScreenState dari luar.
final GlobalKey<MainScreenState> mainScreenKey = GlobalKey<MainScreenState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  // Bungkus MyApp dengan ProviderScope
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absensi Klub Olahraga',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          titleLarge: TextStyle(
            color: Colors.teal[800],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          bodyMedium: TextStyle(color: Colors.grey[800]),
        ),
        cardTheme: CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.teal),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.teal[700]!, width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.teal),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.teal[700],
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        // --- 2. BERIKAN key KE MainScreen ---
        '/main': (context) => MainScreen(key: mainScreenKey),
        '/members': (context) => const MemberListScreen(),
        '/attendance': (context) => const AttendanceScreen(),
        '/history': (context) => const AttendanceHistoryScreen(),
        '/report': (context) => const ReportScreen(),
        '/settings': (context) => const ClubSettingsScreen(),
      },
    );
  }
}

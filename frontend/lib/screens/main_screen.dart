import 'package:flutter/material.dart';
import 'beranda_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Indeks 0: Beranda, 1: Dashboard, 2: Profil

  static final List<Widget> _widgetOptions = <Widget>[
    BerandaScreen(),
    DashboardScreen(),
    ProfileScreen(),
  ];

  // --- FUNGSI BARU UNTUK PINDAH TAB ---
  // Fungsi ini bisa dipanggil dari luar untuk mengubah tab ke Dashboard.
  void jumpToDashboard() {
    setState(() {
      _selectedIndex = 1; // 1 adalah indeks untuk halaman Dashboard
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

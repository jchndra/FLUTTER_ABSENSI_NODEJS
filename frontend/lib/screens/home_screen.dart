import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Klub Olahraga'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Logika logout
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Selamat Datang di Aplikasi Absensi!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            _buildDashboardButton(
              context,
              icon: Icons.people,
              label: 'Daftar Anggota',
              routeName: '/members',
            ),
            SizedBox(height: 20),
            _buildDashboardButton(
              context,
              icon: Icons.check_circle_outline,
              label: 'Ambil Absensi',
              routeName: '/attendance',
            ),
            SizedBox(height: 20),
            // Tambahkan tombol lain jika perlu, misalnya Riwayat Absensi
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String routeName,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(label, style: TextStyle(fontSize: 18)),
      onPressed: () {
        Navigator.pushNamed(context, routeName);
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(250, 60),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

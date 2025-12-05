import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), centerTitle: true),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: <Widget>[
          _buildDashboardItem(
            context,
            icon: Icons.people_alt_rounded,
            label: 'Daftar Anggota',
            routeName: '/members',
            color: Colors.lightBlueAccent.shade700,
          ),
          _buildDashboardItem(
            context,
            icon: Icons.check_circle_outline_rounded,
            label: 'Ambil Absensi',
            routeName: '/attendance',
            color: Colors.greenAccent.shade700,
          ),
          _buildDashboardItem(
            context,
            icon: Icons.history_rounded,
            label: 'Riwayat Absensi',
            routeName: '/history',
            color: Colors.orangeAccent.shade700,
          ),
          _buildDashboardItem(
            context,
            icon: Icons.bar_chart_rounded,
            label: 'Laporan Kehadiran',
            routeName: '/report',
            color: Colors.pinkAccent.shade400,
          ),
          _buildDashboardItem(
            context,
            icon: Icons.settings_applications_rounded,
            label: 'Pengaturan Klub',
            routeName: '/settings', // Mengarahkan ke halaman pengaturan
            color: Colors.purpleAccent.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? routeName,
    VoidCallback? onTap,
    required Color color,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap:
            onTap ??
            () {
              if (routeName != null) {
                Navigator.pushNamed(context, routeName);
              }
            },
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withAlpha(38),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

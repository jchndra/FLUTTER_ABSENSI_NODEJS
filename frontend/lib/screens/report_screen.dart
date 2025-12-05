import 'package:flutter/material.dart';
import '../services/report_service.dart';
import '../services/attendance_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportService _reportService = ReportService();
  late Future<Map<String, double>> _reportFuture;

  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    setState(() {
      _reportFuture = _reportService.getMemberAttendancePercentage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Kehadiran'), centerTitle: true),
      body: FutureBuilder<Map<String, double>>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Terjadi error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Belum ada data absensi untuk dianalisis."),
            );
          }

          final Map<String, double> data = snapshot.data!;

          final sortedEntries = data.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Persentase Kehadiran Anggota",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                FutureBuilder<List>(
                  future: _attendanceService.getAttendanceHistory(),
                  builder: (context, attendanceSnapshot) {
                    final totalSessions = attendanceSnapshot.data?.length ?? 0;
                    return Text(
                      "Total Sesi Latihan: $totalSessions",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Simple fallback chart built with Containers (no fl_chart)
                SizedBox(
                  height: 320,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: sortedEntries.map((entry) {
                        final label = entry.key.split(' ').first;
                        final percent = entry.value.clamp(0, 100);
                        final barHeight = (percent / 100) * 220; // px
                        final color =
                            percent >= 80 ? Colors.teal : Colors.deepOrange;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 40,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('${percent.toStringAsFixed(1)}%'),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 10, height: 10, color: Colors.teal),
                    const SizedBox(width: 5),
                    const Text('Kehadiran Baik (>=80%)'),
                    const SizedBox(width: 15),
                    Container(width: 10, height: 10, color: Colors.deepOrange),
                    const SizedBox(width: 5),
                    const Text('Perlu Perhatian (<80%)'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

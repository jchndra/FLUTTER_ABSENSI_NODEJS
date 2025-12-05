import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../services/club_settings_service.dart';
import '../services/member_service.dart';
import '../services/attendance_service.dart';
import '../models/attendance_record.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final ClubSettingsService _settingsService = ClubSettingsService();
  final MemberService _memberService = MemberService();
  final AttendanceService _attendanceService = AttendanceService();

  String _clubName = "Memuat...";
  late Future<int> _totalMembersFuture;
  late Future<List<AttendanceRecord>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _totalMembersFuture = Future.value(0);
    _historyFuture = Future.value([]);
    _loadData();
  }

  void _loadData() async {
    final name = await _settingsService.getClubName();
    if (!mounted) return;

    setState(() {
      _clubName = name;
      _totalMembersFuture = _memberService.getMembers().then(
        (list) => list.length,
      );
      _historyFuture = _attendanceService.getAttendanceHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Beranda'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang di $_clubName!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Aplikasi Absensi Klub $_clubName.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 30),

            // ====================== RINGKASAN DATA ======================
            FutureBuilder<int>(
              future: _totalMembersFuture,
              builder: (context, memberSnapshot) {
                return FutureBuilder<List<AttendanceRecord>>(
                  future: _historyFuture,
                  builder: (context, historySnapshot) {
                    final totalMembers = memberSnapshot.data ?? 0;
                    final historyList = historySnapshot.data ?? [];
                    final totalSessions = historyList.length;

                    final lastRecord =
                        historyList.isNotEmpty ? historyList.first : null;

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                icon: Icons.people_alt_rounded,
                                title: "Total Anggota",
                                value: totalMembers.toString(),
                                subtitle: "",
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                icon: Icons.check_circle_outline_rounded,
                                title: "Sesi Terakhir",
                                value:
                                    lastRecord != null
                                        ? "${lastRecord.presentMemberIds.length} Hadir"
                                        : "0",
                                subtitle:
                                    lastRecord != null
                                        ? DateFormat(
                                          'dd MMM',
                                        ).format(lastRecord.date)
                                        : "",
                                color: Colors.green.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                icon: Icons.history_toggle_off_rounded,
                                title: "Total Sesi",
                                value: totalSessions.toString(),
                                subtitle: "Sejak dicatat",
                                color: Colors.deepOrange.shade600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        _buildInfoCard(
                          icon: Icons.info_outline_rounded,
                          title: "Tentang Aplikasi",
                          content:
                              "Aplikasi ini membantu pencatatan kehadiran anggota klub secara efisien.",
                          color: colorScheme.primary,
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30),

            // ====================== Info lain ======================
            _buildInfoCard(
              icon: Icons.event_note_rounded,
              title: 'Jadwal Kegiatan Club',
              content:
                  'Latihan Rutin: Setiap Sabtu, Pukul 16:00\nFriendly Match: Minggu depan, hubungi pelatih.',
              color: Colors.orangeAccent.shade700,
            ),
            const SizedBox(height: 20),

            _buildInfoCard(
              icon: Icons.notifications_active_outlined,
              title: 'Pengumuman Terbaru',
              content:
                  'Harap membawa perlengkapan lengkap untuk latihan berikutnya. Ada evaluasi teknik dasar.',
              color: Colors.purpleAccent.shade400,
            ),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.dashboard_customize_outlined),
                label: const Text('Buka Dashboard'),
                onPressed: () => mainScreenKey.currentState?.jumpToDashboard(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ========================= COMPONENT CARD =========================
  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        constraints: const BoxConstraints(minHeight: 140),
        padding: const EdgeInsets.all(16),
        child: _buildSummaryCardContent(
          icon: icon,
          title: title,
          value: value,
          subtitle: subtitle,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSummaryCardContent({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 26, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color:
                          Theme.of(context).textTheme.bodyMedium?.color ??
                          Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

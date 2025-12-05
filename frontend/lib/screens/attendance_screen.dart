import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/member.dart';
import '../services/member_service.dart';
import '../services/attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  AttendanceScreenState createState() => AttendanceScreenState();
}

class AttendanceScreenState extends State<AttendanceScreen> {
  final MemberService _memberService = MemberService();
  final AttendanceService _attendanceService = AttendanceService();
  late Future<List<Member>> _membersFuture;

  late Future<bool> _isAttendanceTakenForSelectedDateFuture;

  List<Member> _membersForAttendance = [];
  final Map<String, bool> _attendanceStatus = {};
  DateTime _selectedDate = DateTime.now();

  // Variabel untuk status apakah absensi sudah diambil di tanggal yang sedang dipilih
  bool _isAttendanceAlreadyTaken = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Fungsi ini memuat ulang data anggota dan mengecek status absensi
  void _loadData() {
    setState(() {
      _membersFuture = _memberService.getMembers();
      _isAttendanceTakenForSelectedDateFuture =
          _checkIfAttendanceIsTakenForSelectedDate();
    });
  }

  // Handle Pull-to-Refresh
  Future<void> _handleRefresh() async {
    _loadData();
    await Future.wait([
      _membersFuture,
      _isAttendanceTakenForSelectedDateFuture,
    ]);
  }

  Future<bool> _checkIfAttendanceIsTakenForSelectedDate() async {
    final history = await _attendanceService.getAttendanceHistory();

    final isTaken = history.any((record) {
      return record.date.year == _selectedDate.year &&
          record.date.month == _selectedDate.month &&
          record.date.day == _selectedDate.day;
    });

    if (mounted) {
      setState(() {
        _isAttendanceAlreadyTaken = isTaken;
      });
    }

    return isTaken;
  }

  void _initializeAttendanceStatus(List<Member> members) {
    _attendanceStatus.clear();
    for (var member in members) {
      _attendanceStatus[member.id] = false;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _initializeAttendanceStatus(_membersForAttendance);
        // Cek ulang status untuk tanggal baru yang dipilih
        _loadData();
      });
    }
  }

  void _submitAttendance() {
    final presentCount =
        _attendanceStatus.values.where((status) => status).length;
    final absentCount = _attendanceStatus.length - presentCount;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Absensi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate)}",
              ),
              const SizedBox(height: 16),
              Text(
                "Total Hadir: $presentCount",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("Total Tidak Hadir: $absentCount"),
              const SizedBox(height: 16),
              const Text("Yakin ingin menyimpan data absensi ini?"),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Simpan"),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                final List<String> presentMemberIds = [];
                _attendanceStatus.forEach((memberId, isPresent) {
                  if (isPresent) {
                    presentMemberIds.add(memberId);
                  }
                });

                // 1. Simpan Data
                await _attendanceService.saveAttendance(
                  _selectedDate,
                  presentMemberIds,
                );

                if (!mounted) return;

                navigator.pop(); // Tutup Dialog

                // 2. <<< PERUBAHAN UTAMA DI SINI >>>
                // Panggil _loadData() untuk me-refresh status halaman.
                // Karena data baru saja disimpan, pengecekan di _loadData akan
                // menghasilkan 'true', sehingga tampilan berubah ke Peringatan Merah.
                _loadData();

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Absensi untuk ${DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate)} berhasil disimpan.',
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengambilan Absensi'),
        centerTitle: true,
      ),
      body: FutureBuilder<bool>(
        future: _isAttendanceTakenForSelectedDateFuture,
        builder: (context, isTakenSnapshot) {
          if (isTakenSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return FutureBuilder<List<Member>>(
            future: _membersFuture,
            builder: (context, memberSnapshot) {
              if (memberSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (memberSnapshot.hasError) {
                return Center(
                  child: Text("Terjadi error: ${memberSnapshot.error}"),
                );
              }
              if (!memberSnapshot.hasData || memberSnapshot.data!.isEmpty) {
                return const Center(child: Text("Belum ada anggota."));
              }

              _membersForAttendance = memberSnapshot.data!;
              if (_attendanceStatus.isEmpty) {
                _initializeAttendanceStatus(_membersForAttendance);
              }

              final isAlreadyTaken =
                  isTakenSnapshot.data ?? _isAttendanceAlreadyTaken;

              // --- TAMPILAN JIKA SUDAH ABSEN ---
              if (isAlreadyTaken) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.do_not_disturb_on_rounded,
                          size: 80,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Absensi untuk tanggal ${DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate)} sudah dicatat.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Anda tidak dapat mengambil absensi dua kali di tanggal yang sama. Jika ada perubahan, silakan edit di Riwayat.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 30),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.history_rounded),
                          label: const Text('Buka Riwayat Absensi'),
                          onPressed: () {
                            Navigator.pushNamed(context, '/history');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            minimumSize: const Size(200, 45),
                          ),
                        ),

                        const SizedBox(height: 12),

                        OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_month_rounded),
                          label: const Text('Pilih Tanggal Lain'),
                          onPressed: () => _selectDate(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            side: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                            minimumSize: const Size(200, 45),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              // --- AKHIR TAMPILAN SUDAH ABSEN ---

              // --- TAMPILAN FORM ABSENSI ---
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Theme.of(context).primaryColor.withAlpha(25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat(
                            'EEEE, dd MMMM yyyy',
                            'id_ID',
                          ).format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: const Text('Ubah'),
                          onPressed: () => _selectDate(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _handleRefresh,
                      color: Theme.of(context).primaryColor,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _membersForAttendance.length,
                        itemBuilder: (context, index) {
                          final member = _membersForAttendance[index];
                          return Card(
                            child: CheckboxListTile(
                              secondary: CircleAvatar(
                                backgroundImage:
                                    member.photoUrl != null &&
                                            member.photoUrl!.isNotEmpty
                                        ? NetworkImage(member.photoUrl!)
                                        : null,
                                child:
                                    member.photoUrl == null ||
                                            member.photoUrl!.isEmpty
                                        ? Text(
                                          member.name.isNotEmpty
                                              ? member.name[0].toUpperCase()
                                              : '?',
                                        )
                                        : null,
                              ),
                              title: Text(member.name),
                              subtitle: Text('ID: ${member.id}'),
                              value: _attendanceStatus[member.id] ?? false,
                              onChanged: (bool? value) {
                                setState(() {
                                  _attendanceStatus[member.id] = value ?? false;
                                });
                              },
                              activeColor: Theme.of(context).primaryColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt_rounded),
                      label: const Text('Simpan Absensi'),
                      onPressed: _submitAttendance,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

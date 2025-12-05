import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance_record.dart';
import '../services/attendance_service.dart';
import '../services/member_service.dart';
import '../models/member.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final MemberService _memberService = MemberService();
  late Future<List<AttendanceRecord>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _historyFuture = _attendanceService.getAttendanceHistory();
    });
  }

  // --- LOGIKA HAPUS DAN EDIT (TETAP SAMA) ---

  void _showDeleteConfirmationDialog(AttendanceRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Riwayat"),
          content: Text(
            "Yakin ingin menghapus riwayat untuk tanggal ${DateFormat('dd MMMM yyyy', 'id_ID').format(record.date)}?",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Hapus"),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                await _attendanceService.deleteAttendanceRecord(record.date);

                navigator.pop();
                _loadHistory();

                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Riwayat berhasil dihapus.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showRemoveMemberConfirmationDialog(
    AttendanceRecord record,
    Member member,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Kehadiran Anggota"),
          content: Text(
            "Apakah Anda yakin ingin menghapus ${member.name} dari daftar hadir tanggal ${DateFormat('dd MMMM yyyy', 'id_ID').format(record.date)}?",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Hapus"),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                await _deleteMemberFromAttendance(record, member.id);

                navigator.pop();
                _loadHistory();

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      '${member.name} berhasil dihapus dari absensi.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMemberFromAttendance(
    AttendanceRecord record,
    String memberIdToRemove,
  ) async {
    List<String> updatedMemberIds = List.from(record.presentMemberIds);
    updatedMemberIds.remove(memberIdToRemove);

    AttendanceRecord updatedRecord = AttendanceRecord(
      date: record.date,
      presentMemberIds: updatedMemberIds,
    );

    await _attendanceService.updateAttendanceRecord(updatedRecord);
  }

  void _showEditAttendanceDialog(AttendanceRecord record) async {
    final allMembers = await _memberService.getMembers();
    final currentPresentIds = record.presentMemberIds.toSet();
    final absentMembers =
        allMembers
            .where((member) => !currentPresentIds.contains(member.id))
            .toList();

    if (!mounted) return;

    final Map<String, bool> membersToAdd = {
      for (var member in absentMembers) member.id: false,
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: const Text("Tambah Anggota"),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(record.date)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (absentMembers.isEmpty)
                      const Text(
                        "Semua anggota sudah tercatat hadir.",
                        style: TextStyle(color: Colors.green),
                      )
                    else
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: absentMembers.length,
                          itemBuilder: (context, index) {
                            final member = absentMembers[index];
                            return CheckboxListTile(
                              title: Text(member.name),
                              subtitle: Text('ID: ${member.id}'),
                              value: membersToAdd[member.id] ?? false,
                              onChanged: (bool? value) {
                                setStateInDialog(() {
                                  membersToAdd[member.id] = value ?? false;
                                });
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
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

                    final List<String> newPresentIds =
                        membersToAdd.entries
                            .where((entry) => entry.value)
                            .map((entry) => entry.key)
                            .toList();

                    if (newPresentIds.isEmpty) {
                      navigator.pop();
                      return;
                    }

                    final updatedPresentIds = [
                      ...currentPresentIds,
                      ...newPresentIds,
                    ];

                    final updatedRecord = AttendanceRecord(
                      date: record.date,
                      presentMemberIds: updatedPresentIds,
                    );

                    await _attendanceService.updateAttendanceRecord(
                      updatedRecord,
                    );

                    if (!mounted) return;

                    navigator.pop();
                    _loadHistory();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          '${newPresentIds.length} anggota berhasil ditambahkan.',
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- WIDGET HELPER: Membuat Kartu Absensi ---
  Widget _buildAttendanceCard(AttendanceRecord record) {
    final dateString = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(record.date);
    final presentCount = record.presentMemberIds.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            '${record.date.day}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        title: Text(
          dateString,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text("$presentCount Anggota Hadir"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.person_add_alt_1_rounded,
                color: Colors.blue[700],
              ),
              tooltip: "Tambah Anggota",
              onPressed: () => _showEditAttendanceDialog(record),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[700]),
              tooltip: "Hapus Riwayat Ini",
              onPressed: () => _showDeleteConfirmationDialog(record),
            ),
          ],
        ),
        children: [
          ...(record.presentMembersDetails?.map((member) {
                return ListTile(
                  contentPadding: const EdgeInsets.only(left: 32, right: 16),
                  title: Text(member.name),
                  subtitle: Text("ID: ${member.id}"),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    tooltip: "Hapus ${member.name} dari absensi ini",
                    onPressed:
                        () =>
                            _showRemoveMemberConfirmationDialog(record, member),
                  ),
                );
              }).toList() ??
              [const ListTile(title: Text("Tidak ada detail anggota."))]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Absensi"), centerTitle: true),
      body: FutureBuilder<List<AttendanceRecord>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Terjadi error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Belum ada riwayat absensi.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final history = snapshot.data!;
          // 1. Urutkan berdasarkan tanggal terbaru
          history.sort((a, b) => b.date.compareTo(a.date));

          // 2. Kelompokkan data berdasarkan Bulan & Tahun
          final Map<String, List<AttendanceRecord>> groupedHistory = {};
          for (var record in history) {
            // Key format: "November 2025"
            final key = DateFormat('MMMM yyyy', 'id_ID').format(record.date);
            if (!groupedHistory.containsKey(key)) {
              groupedHistory[key] = [];
            }
            groupedHistory[key]!.add(record);
          }

          // 3. Tampilkan ListView berdasarkan grup
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            itemCount: groupedHistory.keys.length,
            itemBuilder: (context, index) {
              final monthKey = groupedHistory.keys.elementAt(index);
              final records = groupedHistory[monthKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header Bulan ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
                    child: Text(
                      monthKey,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  // --- Daftar Kartu Absensi di Bulan Tersebut ---
                  ...records.map((record) => _buildAttendanceCard(record)),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

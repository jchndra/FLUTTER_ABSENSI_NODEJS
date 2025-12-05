import 'attendance_service.dart';
import 'member_service.dart';

class ReportService {
  final MemberService _memberService = MemberService();
  final AttendanceService _attendanceService = AttendanceService();

  Future<Map<String, double>> getMemberAttendancePercentage() async {
    final allMembers = await _memberService.getMembers();
    final allRecords = await _attendanceService.getAttendanceHistory();

    if (allRecords.isEmpty || allMembers.isEmpty) {
      return {};
    }

    // 1. Hitung Total Sesi Latihan
    final totalSessions = allRecords.length;

    // 2. Hitung Kehadiran per Anggota
    final Map<String, int> presenceCount = {};
    for (var member in allMembers) {
      presenceCount[member.id] = 0;
    }

    for (var record in allRecords) {
      for (var memberId in record.presentMemberIds) {
        presenceCount.update(memberId, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    // 3. Hitung Persentase
    final Map<String, double> attendancePercentage = {};
    for (var member in allMembers) {
      final totalPresent = presenceCount[member.id] ?? 0;
      final percentage = (totalPresent / totalSessions) * 100;

      // Simpan dalam format yang mudah dibaca (Nama anggota sebagai key)
      // Menggunakan ID anggota sebagai fallback key jika nama kosong
      final memberKey = member.name.isNotEmpty ? member.name : member.id;

      attendancePercentage[memberKey] = double.parse(
        percentage.toStringAsFixed(1),
      );
    }

    return attendancePercentage;
  }
}

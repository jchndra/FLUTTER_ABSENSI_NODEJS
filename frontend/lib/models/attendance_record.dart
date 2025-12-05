import 'package:absensi_club_olahraga/models/member.dart';

class AttendanceRecord {
  final DateTime date;
  final List<String> presentMemberIds;

  // Opsional: untuk menampilkan detail di UI
  final List<Member>? presentMembersDetails;

  AttendanceRecord({
    required this.date,
    required this.presentMemberIds,
    this.presentMembersDetails,
  });

  // Mengubah data dari Map/JSON menjadi objek AttendanceRecord
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    // Support both snake_case and camelCase keys from backend
    final presentIds =
        json['present_member_ids'] ?? json['presentMemberIds'] ?? [];
    return AttendanceRecord(
      date: DateTime.parse(json['date']),
      presentMemberIds: List<String>.from(presentIds),
      presentMembersDetails: json['presentMembersDetails'] != null
          ? (json['presentMembersDetails'] as List)
              .map((m) => Member.fromJson(m as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  // Mengubah objek AttendanceRecord menjadi Map/JSON untuk disimpan
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(), // Simpan tanggal dalam format standar
      'present_member_ids': presentMemberIds,
      // Menghapus penyimpanan data GPS:
      // 'latitude': latitude,
      // 'longitude': longitude,
    };
  }
}

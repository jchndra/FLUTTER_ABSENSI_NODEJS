import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/attendance_record.dart';
import '../config.dart';

class AttendanceService {
  static const _baseUrl = API_BASE_URL;

  // --- FUNGSI Mendapatkan Alamat dari Koordinat DIHAPUS ---
  // Future<String> getAddressFromCoordinates(double? lat, double? lon) async { ... }

  /// Menyimpan data absensi
  Future<void> saveAttendance(
      DateTime date, List<String> presentMemberIds) async {
    final url = Uri.parse('$_baseUrl/attendance');
    final resp = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'date': date.toIso8601String().substring(0, 10),
          'presentMemberIds': presentMemberIds
        }));
    if (resp.statusCode != 201) {
      throw Exception(
          'Failed to save attendance: ${resp.statusCode} ${resp.body}');
    }
  }

  /// Mengambil riwayat absensi (dimodifikasi untuk hapus logic lokasi)
  Future<List<AttendanceRecord>> getAttendanceHistory() async {
    final url = Uri.parse('$_baseUrl/attendance');
    final resp = await http.get(url);
    if (resp.statusCode != 200) return [];
    final data = jsonDecode(resp.body) as List<dynamic>;

    // Map into AttendanceRecord using model's fromJson which handles member details
    final history = data
        .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
    history.sort((a, b) => b.date.compareTo(a.date));
    return history;
  }

  /// FUNGSI UNTUK HAPUS RIWAYAT (tetap)
  Future<void> deleteAttendanceRecord(DateTime date) async {
    final dateStr = date.toIso8601String().substring(0, 10);
    final url = Uri.parse('$_baseUrl/attendance/$dateStr');
    final resp = await http.delete(url);
    if (resp.statusCode != 200) {
      throw Exception('Failed to delete attendance: ${resp.statusCode}');
    }
  }

  /// FUNGSI Memperbarui Record Absensi (dimodifikasi untuk hapus logic lokasi)
  Future<void> updateAttendanceRecord(AttendanceRecord updatedRecord) async {
    final dateStr = updatedRecord.date.toIso8601String().substring(0, 10);
    final url = Uri.parse('$_baseUrl/attendance/$dateStr');
    final resp = await http.put(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'presentMemberIds': updatedRecord.presentMemberIds}));
    if (resp.statusCode != 200) {
      throw Exception('Failed to update attendance: ${resp.statusCode}');
    }
  }
}

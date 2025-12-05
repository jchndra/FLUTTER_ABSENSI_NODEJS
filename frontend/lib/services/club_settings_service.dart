import 'package:shared_preferences/shared_preferences.dart';

class ClubSettingsService {
  static const _clubNameKey = 'club_name';

  // Mendapatkan nama klub yang tersimpan
  Future<String> getClubName() async {
    final prefs = await SharedPreferences.getInstance();
    // Jika tidak ada nama yang tersimpan, kembalikan nama default 'RentSport'
    return prefs.getString(_clubNameKey) ?? 'RentSport';
  }

  // Menyimpan nama klub yang baru
  Future<void> saveClubName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clubNameKey, newName);
  }
}

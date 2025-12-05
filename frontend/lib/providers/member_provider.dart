import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/member.dart';
import '../services/member_service.dart';

// 1. Provider untuk MemberService (untuk injeksi dependency, agar mudah diganti ke Firestore nanti)
final memberServiceProvider = Provider((ref) => MemberService());

// 2. StateNotifierProvider untuk mengelola daftar anggota dan memuatnya secara async
final memberListProvider =
    StateNotifierProvider<MemberListNotifier, AsyncValue<List<Member>>>((ref) {
      // Minta MemberService dari provider di atas
      return MemberListNotifier(ref.read(memberServiceProvider));
    });

class MemberListNotifier extends StateNotifier<AsyncValue<List<Member>>> {
  final MemberService _service;

  MemberListNotifier(this._service) : super(const AsyncValue.loading()) {
    // Muat data segera setelah Notifier dibuat
    loadMembers();
  }

  Future<void> loadMembers() async {
    // Set state ke loading saat proses dimulai (kecuali di inisialisasi)
    if (state is! AsyncLoading) {
      state = const AsyncValue.loading();
    }

    try {
      final members = await _service.getMembers();
      // Set state ke data jika berhasil
      state = AsyncValue.data(members);
    } catch (e, st) {
      // Set state ke error jika gagal
      state = AsyncValue.error(e, st);
    }
  }

  // Dipanggil dari UI untuk menambah anggota
  Future<void> addMember(Member newMember) async {
    // Lakukan operasi penambahan ke service
    await _service.addMember(newMember);
    // Muat ulang data secara keseluruhan (memaksa UI untuk rebuild dengan data baru)
    await loadMembers();
  }

  // Dipanggil dari UI untuk menghapus anggota
  Future<void> deleteMember(String memberId) async {
    // Lakukan operasi penghapusan ke service
    await _service.deleteMember(memberId);
    // Muat ulang data
    await loadMembers();
  }
}

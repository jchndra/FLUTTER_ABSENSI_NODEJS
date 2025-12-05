import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <<< WAJIB DIIMPORT
import '../models/member.dart';
import '../providers/member_provider.dart'; // <<< Import Provider kita

// 1. Ganti StatefulWidget menjadi ConsumerStatefulWidget
class MemberListScreen extends ConsumerStatefulWidget {
  const MemberListScreen({super.key});

  @override
  ConsumerState<MemberListScreen> createState() => MemberListScreenState();
}

// 2. Ganti State menjadi ConsumerState
class MemberListScreenState extends ConsumerState<MemberListScreen> {
  
  List<Member> _allMembers = [];
  List<Member> _filteredMembers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inisialisasi listener tetap di sini
    _searchController.addListener(_filterMembers);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_filterMembers);
    _searchController.dispose();
    super.dispose();
  }

  void _filterMembers() {
    String query = _searchController.text.toLowerCase();

    // Tidak perlu cek loading, karena fungsi ini hanya dipanggil jika data sudah ada.
    if (_allMembers.isEmpty) return;

    // Panggil setState agar UI di dalam builder mere-render
    setState(() {
      _filteredMembers =
          _allMembers.where((member) {
            return member.name.toLowerCase().contains(query) ||
                member.id.toLowerCase().contains(query);
          }).toList();
    });
  }

  // --- LOGIKA LAMA DIUBAH MENGGUNAKAN Riverpod (ref.read) ---
  void _showDeleteConfirmationDialog(Member member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Anggota"),
          content: Text(
            "Apakah Anda yakin ingin menghapus ${member.name}? Tindakan ini tidak dapat dibatalkan.",
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

                // Gunakan ref.read untuk memanggil fungsi di Notifier
                await ref
                    .read(memberListProvider.notifier)
                    .deleteMember(member.id);

                messenger.showSnackBar(
                  SnackBar(
                    content: Text('${member.name} berhasil dihapus.'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                navigator.pop();
                // Data akan ter-update otomatis oleh Riverpod!
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddMemberDialog() {
    final formKey = GlobalKey<FormState>();
    final idController = TextEditingController();
    final nameController = TextEditingController();
    final photoUrlController = TextEditingController();

    // Ambil data anggota saat ini dari Riverpod untuk validasi ID unik
    final membersData = ref.read(memberListProvider).value ?? [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Tambah Anggota Baru"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: idController,
                    decoration: const InputDecoration(
                      labelText: 'ID Anggota',
                      hintText: 'Contoh: M006',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ID tidak boleh kosong';
                      }
                      if (membersData.any(
                        (m) => m.id.toLowerCase() == value.toLowerCase(),
                      )) {
                        return 'ID sudah digunakan';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Nama tidak boleh kosong'
                                : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: photoUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL Foto (Opsional)',
                    ),
                  ),
                ],
              ),
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
                if (formKey.currentState!.validate()) {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  final newMember = Member(
                    id: idController.text.trim(),
                    name: nameController.text.trim(),
                    photoUrl:
                        photoUrlController.text.trim().isEmpty
                            ? null
                            : photoUrlController.text.trim(),
                  );

                  // Gunakan ref.read untuk memanggil fungsi di Notifier
                  await ref
                      .read(memberListProvider.notifier)
                      .addMember(newMember);

                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('${newMember.name} berhasil ditambahkan!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  navigator.pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Ekstrak Search Bar ke fungsi terpisah agar kode build lebih rapi
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari anggota (nama atau ID)...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 3. Gunakan ref.watch untuk memantau data secara reaktif
    final memberListAsync = ref.watch(memberListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Anggota')),
      // 4. Mengganti FutureBuilder dengan .when dari AsyncValue
      body: memberListAsync.when(
        // State Loading
        loading: () => const Center(child: CircularProgressIndicator()),
        // State Error
        error: (e, s) {
          return Center(
            child: Text(
              "Terjadi error saat memuat data: $e",
              textAlign: TextAlign.center,
            ),
          );
        },
        // State Data tersedia (PENTING: Hanya data yang sudah di-cache)
        data: (members) {
          // Selalu update _allMembers dengan data terbaru
          _allMembers = members;

          // Terapkan filter hanya jika belum pernah di-filter atau query kosong
          if (_searchController.text.isEmpty) {
            _filteredMembers = _allMembers;
          } else {
            // Panggil filter untuk memperbarui _filteredMembers dengan data terbaru
            // Perlu dipanggil di sini untuk memastikan data yang ditampilkan up-to-date
            // Meskipun _filterMembers memanggil setState, dalam konteks ini,
            // setState hanya akan memicu rebuild jika ada perubahan, dan rebuild
            // pertama kali di sini dipicu oleh perubahan data Riverpod.
            _filterMembers();
          }

          if (_filteredMembers.isEmpty && _searchController.text.isNotEmpty) {
            return Column(
              children: [
                _buildSearchBar(context),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Anggota tidak ditemukan.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            );
          }

          if (members.isEmpty && _searchController.text.isEmpty) {
            return const Center(child: Text("Belum ada anggota."));
          }

          return Column(
            children: [
              _buildSearchBar(context),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = _filteredMembers[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
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
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red[700],
                          ),
                          onPressed: () {
                            _showDeleteConfirmationDialog(member);
                          },
                          tooltip: 'Hapus ${member.name}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMemberDialog,
        icon: const Icon(Icons.add),
        label: const Text("Tambah Anggota"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

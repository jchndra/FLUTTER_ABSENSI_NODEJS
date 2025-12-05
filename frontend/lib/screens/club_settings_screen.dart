import 'package:flutter/material.dart';
import '../services/club_settings_service.dart';

class ClubSettingsScreen extends StatefulWidget {
  const ClubSettingsScreen({super.key});

  @override
  State<ClubSettingsScreen> createState() => _ClubSettingsScreenState();
}

class _ClubSettingsScreenState extends State<ClubSettingsScreen> {
  final ClubSettingsService _settingsService = ClubSettingsService();
  final _formKey = GlobalKey<FormState>();
  final _clubNameController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClubName();
  }

  Future<void> _loadClubName() async {
    final clubName = await _settingsService.getClubName();
    if (mounted) {
      setState(() {
        _clubNameController.text = clubName;
        _isLoading = false;
      });
    }
  }

  // --- FUNGSI INI YANG DIPERBAIKI ---
  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      // Amankan context sebelum proses async
      final messenger = ScaffoldMessenger.of(context);

      final newName = _clubNameController.text.trim();
      // Lakukan proses async
      await _settingsService.saveClubName(newName);

      // Gunakan variabel yang sudah diamankan
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Pengaturan berhasil disimpan!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _clubNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan Klub"), centerTitle: true),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    TextFormField(
                      controller: _clubNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Klub',
                        icon: Icon(Icons.shield_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama klub tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Simpan Pengaturan'),
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

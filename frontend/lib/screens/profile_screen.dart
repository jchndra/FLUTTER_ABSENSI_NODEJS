import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Data admin dummy, akan diubah oleh dialog edit profil
  String _adminName = 'Admin Klub';
  String _adminEmail = 'admin@klub.com';

  // Controller untuk dialog edit profil
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Controller untuk dialog ubah password
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _editProfileFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _changePasswordFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController.text = _adminName;
    _emailController.text = _adminEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog() {
    // Set nilai awal controller dari state saat ini
    _nameController.text = _adminName;
    _emailController.text = _adminEmail;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Edit Profil Admin",
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _editProfileFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Admin',
                      icon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Admin',
                      icon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Masukkan email yang valid';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Batal", style: TextStyle(color: Colors.grey[600])),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.save_alt_rounded),
              label: Text("Simpan"),
              onPressed: () {
                if (_editProfileFormKey.currentState!.validate()) {
                  setState(() {
                    _adminName = _nameController.text.trim();
                    _adminEmail = _emailController.text.trim();
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profil berhasil diperbarui!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Ubah Password",
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _changePasswordFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _oldPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Password Lama',
                      icon: Icon(Icons.lock_outline_rounded),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password lama tidak boleh kosong';
                      }
                      // Simulasi validasi password lama
                      if (value != 'password') {
                        // Ganti dengan logika validasi sebenarnya
                        return 'Password lama salah';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      icon: Icon(Icons.lock_person_outlined),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password baru tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Password baru minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                      icon: Icon(Icons.lock_reset_outlined),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi password tidak boleh kosong';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Password baru tidak cocok';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Batal", style: TextStyle(color: Colors.grey[600])),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.key_rounded),
              label: Text("Ubah"),
              onPressed: () {
                if (_changePasswordFormKey.currentState!.validate()) {
                  // Logika ubah password sebenarnya akan ada di sini
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password berhasil diubah! (Simulasi)'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAppInfoDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Absensi Club RentSport',
      applicationVersion: '1.0.2', // Versi bisa diupdate
      applicationIcon: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          Icons.sports_soccer_rounded,
          size: 48,
          color: Theme.of(context).primaryColor,
        ),
      ),
      applicationLegalese:
          '© ${DateTime.now().year} Pengembang Aplikasi Anda\nSeluruh hak cipta dilindungi.',
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            'Aplikasi ini dirancang untuk membantu manajemen dan pencatatan kehadiran anggota klub olahraga dengan lebih mudah dan efisien. Dan untuk memenuhi tugas projek Mobile Programming I.',
            textAlign: TextAlign.justify,
          ),
        ),
        Text('Fitur:', style: TextStyle(fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✓  Manajemen Daftar Anggota'),
              Text('✓  Pengambilan Absensi Harian'),
              Text('✓  Riwayat Absensi Anggota'),
              Text('✓  Pengaturan Klub'),
              Text('✓  Profil Pengguna (Admin)'),
            ],
          ),
        ),
        SizedBox(height: 15),
        Text(
          'Untuk dukungan atau pertanyaan lebih lanjut, silakan hubungi tim pengembang.',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil Admin'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 65,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.admin_panel_settings_rounded,
                size: 75,
                color: Theme.of(context).primaryColor,
              ),
            ),

            SizedBox(height: 20),
            Text(
              _adminName, // Menggunakan state
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    Theme.of(context).primaryColorDark,
              ),
            ),
            SizedBox(height: 5),
            Text(
              _adminEmail, // Menggunakan state
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 35),
            Divider(thickness: 0.8),
            _buildProfileOption(
              context,
              icon: Icons.edit_outlined,
              title: 'Edit Profil',
              onTap: _showEditProfileDialog,
            ),
            _buildProfileOption(
              context,
              icon: Icons.lock_person_outlined, // Ikon lebih relevan
              title: 'Ubah Password',
              onTap: _showChangePasswordDialog,
            ),
            _buildProfileOption(
              context,
              icon: Icons.info_outline_rounded,
              title: 'Tentang Aplikasi',
              onTap: _showAppInfoDialog, // Menggunakan fungsi yang sudah ada
            ),
            Divider(thickness: 0.8),
            SizedBox(height: 25),
            ElevatedButton.icon(
              icon: Icon(Icons.logout_rounded),
              label: Text('LOGOUT'),
              onPressed: () {
                // Logika logout
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.shade400,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          color: Theme.of(
            context,
          ).textTheme.bodyMedium?.color?.withOpacity(0.9),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey[500],
      ),
      onTap: onTap,
    );
  }
}

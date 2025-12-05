import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      // Simulasi proses login
      await Future.delayed(Duration(seconds: 1));

      if (!mounted)
        return; // <-- tambah ini untuk cek apakah widget masih aktif

      // Try login via backend
      try {
        final resp = await _authService.login(_username.trim(), _password);
        if (resp['ok'] == true) {
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Login gagal: ${resp['error'] ?? 'unknown'}'),
                backgroundColor: Colors.redAccent),
          );
        }
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Login error: ${err.toString()}'),
              backgroundColor: Colors.redAccent),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(
                    Icons.sports_soccer, // Ganti dengan ikon klub Anda
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Selamat Datang di Aplikasi Absensi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Masuk untuk melanjutkan ke aplikasi absensi klub.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 40),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'admin@klub.com',
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
                    onSaved: (value) {
                      _username = value!; // stored as username in backend
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      hintText: 'Masukkan password Anda',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _password = value!;
                    },
                  ),
                  SizedBox(height: 30),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(onPressed: _login, child: Text('LOGIN')),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // Arahkan ke halaman lupa password jika ada
                    },
                    child: Text(
                      'Lupa Password?',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

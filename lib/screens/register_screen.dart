import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _username = '';
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Image.asset('assets/mmv-logo.png', height: 80),
                const SizedBox(height: 16),
                Text('MoodieMovies\'e Kaydolun',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-posta *'),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (v) => _email = v?.trim() ?? '',
                  validator: (v) => v == null || v.isEmpty ? 'E-posta gerekli' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Şifre *'),
                  obscureText: true,
                  onSaved: (v) => _password = v ?? '',
                  validator: (v) => v == null || v.length < 6 ? 'En az 6 karakter' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Kullanıcı Adı *'),
                  onSaved: (v) => _username = v?.trim() ?? '',
                  validator: (v) => v == null || v.isEmpty ? 'Kullanıcı adı gerekli' : null,
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            setState(() => _loading = true);
                            final success = await auth.register(
                                email: _email, password: _password, username: _username);
                            setState(() => _loading = false);
                            if (success) {
                              if (!mounted) return;
                              Navigator.pushReplacementNamed(context, '/home');
                            } else {
                              setState(() => _error = 'Kayıt başarısız');
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppConstants.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Hesabı Oluştur', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _loading ? null : () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Zaten hesabınız var mı? Giriş Yap'),
                ),
                const SizedBox(height: 32),
                // Poster asset
                Image.asset('assets/afisler.jpg', fit: BoxFit.cover),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 
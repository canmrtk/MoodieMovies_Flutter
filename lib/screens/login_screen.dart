import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'MOODIEMOVIES',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: const Color(AppConstants.accentBlue),
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-posta'),
                  onSaved: (v) => _email = v?.trim() ?? '',
                  validator: (v) => v == null || v.isEmpty ? 'E-posta girin' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Şifre'),
                  obscureText: true,
                  onSaved: (v) => _password = v ?? '',
                  validator: (v) => v == null || v.isEmpty ? 'Şifre girin' : null,
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            setState(() => _loading = true);
                            final success = await auth.login(_email, _password);
                            setState(() => _loading = false);
                            if (success) {
                              if (!mounted) return;
                              Navigator.pushReplacementNamed(context, '/home');
                            } else {
                              setState(() => _error = 'Giriş başarısız');
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
                      : const Text('Giriş Yap', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          final success = await auth.loginWithGoogle();
                          setState(() => _loading = false);
                          if (success) {
                            if (!mounted) return;
                            Navigator.pushReplacementNamed(context, '/home');
                          } else {
                            setState(() => _error = 'Google ile giriş başarısız');
                          }
                        },
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('Google ile Giriş'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _loading ? null : () => Navigator.pushReplacementNamed(context, '/register'),
                  child: const Text('Hesabınız yok mu? Kaydol'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../constants/constants.dart';
import '../utils/notifications.dart';

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

  // LEFT section: form
  Widget _buildLeft(BuildContext context, {required bool isWide}) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Padding(
      padding: isWide
          ? const EdgeInsets.symmetric(horizontal: 48, vertical: 32)
          : const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
              isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Text(
              'Oturum Aç',
              style: GoogleFonts.inter(
                  fontSize: isWide ? 32 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 32),
            TextFormField(
              decoration: const InputDecoration(labelText: 'E-posta'),
              keyboardType: TextInputType.emailAddress,
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
                        try {
                          final success = await auth.login(_email, _password);
                          setState(() => _loading = false);
                          if (success) {
                            if (!mounted) return;
                            showSuccess(context, 'Giriş başarılı');
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        } catch (e) {
                          setState(() => _loading = false);
                          showError(context, e.toString());
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppConstants.primaryGreen),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Giriş Yap',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
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
              label: const Text('Google ile Giriş Yap'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider(color: Colors.grey)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Ya Da',
                      style: GoogleFonts.inter(color: Colors.grey[300])),
                ),
                const Expanded(child: Divider(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _loading
                  ? null
                  : () => Navigator.pushReplacementNamed(context, '/register'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                minimumSize: const Size.fromHeight(48),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Yeni Hesap Oluştur'),
            ),
            const SizedBox(height: 24),
            Text(
              'MoodieMovies hesabınıza giriş yaparak Kullanım Koşulları ve Gizlilik Politikasını kabul etmiş olursunuz.',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // RIGHT section: benefits list
  Widget _buildRight({required bool isWide}) {
    return Container(
      width: double.infinity,
      decoration: isWide
          ? const BoxDecoration(
              border: Border(left: BorderSide(color: Colors.grey)),
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MoodieMovies Üyeliğinizin Avantajları',
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 24),
          _buildBenefit('Kişiselleştirilmiş Öneriler',
              'Seveceğiniz filmleri ve dizileri keşfedin.'),
          _buildBenefit('İzleme Listeniz', 'Takip edin ve bildirim alın.'),
          _buildBenefit('Puanlarınız', 'Filmleri puanlayın, favorilerinizi hatırlayın.'),
          _buildBenefit('Katkıda Bulunun', 'Topluluğa katılın, rozet kazanın!'),
        ],
      ),
    );
  }

  Widget _buildBenefit(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔹 '),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                children: [
                  TextSpan(
                      text: '$title\n',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColor),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            if (isWide) {
              return Row(
                children: [
                  Expanded(child: _buildLeft(context, isWide: true)),
                  Expanded(child: _buildRight(isWide: true)),
                ],
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildLeft(context, isWide: false),
                    _buildRight(isWide: false),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
} 
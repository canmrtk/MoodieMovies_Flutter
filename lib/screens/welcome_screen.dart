import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/constants.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  // Helper for left section
  Widget _buildLeftSection(BuildContext context, {required bool isWide}) {
    return Padding(
      padding: isWide
          ? const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32)
          : const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
      child: Column(
        crossAxisAlignment:
            isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            'Ücretsiz Hesabınızı Oluşturun',
            style: GoogleFonts.inter(
              fontSize: isWide ? 32 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: isWide ? TextAlign.left : TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "MoodieMovies'in temel özelliklerini keşfedin.",
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[400],
            ),
            textAlign: isWide ? TextAlign.left : TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Poster image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/afisler.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  // Helper for right section
  Widget _buildRightSection(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Container(
      color: const Color(0xFF2D2D32), // grey-ish card background similar to web
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "MoodieMovies'e Kaydolun",
                style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppConstants.primaryGreen),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Hesabı Oluştur',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final success = await auth.loginWithGoogle();
                  if (success) {
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Google ile Devam Et'),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('Ya da',
                        style: GoogleFonts.inter(color: Colors.grey[300])),
                  ),
                  const Expanded(child: Divider(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Oturum Açın'),
              ),
              const SizedBox(height: 32),
              Text(
                "Bir hesap oluşturarak Hizmet Şartları'nı kabul etmiş olursunuz. Gizlilik Politikamızı incelediğinizi onaylarsınız.",
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
                  Expanded(child: _buildLeftSection(context, isWide: true)),
                  Expanded(child: _buildRightSection(context)),
                ],
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildLeftSection(context, isWide: false),
                    _buildRightSection(context),
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
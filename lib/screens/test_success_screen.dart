import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_drawer.dart';

class TestSuccessScreen extends StatelessWidget {
  const TestSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(),
      endDrawer: const AppDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/tebrikler_icon.png', height: 100),
              const SizedBox(height: 24),
              const Text('Tebrikler! Testi tamamladınız.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/recommendations'),
                child: const Text('Sonuçlarımı Gör'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
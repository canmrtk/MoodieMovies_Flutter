import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_drawer.dart';

class TestIntroScreen extends StatelessWidget {
  const TestIntroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(),
      endDrawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/test_intro.png', height: 120, fit: BoxFit.contain),
            const SizedBox(height: 24),
            const Text('Kişilik testimizi tamamlayarak size özel film önerileri alın!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/test/1'),
              child: const Text('Teste Başla'),
            ),
          ],
        ),
      ),
    );
  }
} 
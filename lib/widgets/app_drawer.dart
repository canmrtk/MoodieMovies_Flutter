import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
           DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Ana Sayfa'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.movie),
            title: const Text('Filmler'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/films');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Listelerim'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/listem');
            },
          ),
          ListTile(
            leading: const Icon(Icons.recommend),
            title: const Text('Tavsiyeler'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/recommendations');
            },
          ),
          ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text('Test'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/test-intro');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Çıkış Yap'),
            onTap: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              Navigator.of(context).pushReplacementNamed('/welcome');
            },
          ),
        ],
      ),
    );
  }
} 
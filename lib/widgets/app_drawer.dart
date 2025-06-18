import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/constants.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  ListTile _navTile(BuildContext context, IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Drawer(
      backgroundColor: const Color(AppConstants.backgroundColor),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (auth.isAuthenticated)
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: auth.currentUser?.fullAvatarUrl != null
                    ? NetworkImage(auth.currentUser!.fullAvatarUrl!) as ImageProvider
                    : null,
                child: auth.currentUser?.fullAvatarUrl == null
                    ? const Icon(Icons.person, color: Colors.black)
                    : null,
              ),
              accountName: Text(auth.currentUser?.name ?? 'Kullanıcı'),
              accountEmail: Text(auth.currentUser?.email ?? ''),
              decoration: const BoxDecoration(
                color: Color(AppConstants.primaryGreen),
              ),
            )
          else
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(AppConstants.primaryGreen),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text('MoodieMovies', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Hoş Geldiniz!', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          _navTile(context, Icons.home, 'Ana Sayfa', '/home'),
          _navTile(context, Icons.movie, 'Filmler', '/films'),
          _navTile(context, Icons.list, 'Listelerim', '/listem'),
          _navTile(context, Icons.forum, 'Forum', '/forum'),
          if (auth.isAuthenticated)
            _navTile(context, Icons.person, 'Profilim', '/profile'),
          const Divider(),
          if (auth.isAuthenticated)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await context.read<AuthProvider>().logout();
                Navigator.pushReplacementNamed(context, '/welcome');
              },
            )
          else ...[
            ListTile(
              leading: const Icon(Icons.login, color: Colors.white),
              title: const Text('Giriş Yap', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            ListTile(
              leading: const Icon(Icons.app_registration, color: Colors.white),
              title: const Text('Kayıt Ol', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/register');
              },
            ),
          ],
        ],
      ),
    );
  }
} 
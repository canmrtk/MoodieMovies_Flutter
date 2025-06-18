import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import 'custom_search_bar.dart';
import '../providers/auth_provider.dart';

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavbar({Key? key}) : super(key: key);

  Widget _navLink(BuildContext context, String label, String routeName) {
    final current = ModalRoute.of(context)!.settings.name;
    final bool isActive = current == routeName;
    return InkWell(
      onTap: () {
        if (current != routeName) {
          Navigator.pushReplacementNamed(context, routeName);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(AppConstants.accentBlue) : Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    final auth = Provider.of<AuthProvider>(context);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(AppConstants.backgroundColor),
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
            child: Row(
              children: [
                Image.asset('assets/mmv-logo.png', height: 32),
                const SizedBox(width: 8),
                const Text(
                  'MOODIEMOVIES',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
          if (isWide) ...[
            const SizedBox(width: 32),
            _navLink(context, 'FİLMLER', '/films'),
            _navLink(context, 'LİSTEM', '/listem'),
            _navLink(context, 'FORUM', '/forum'),
          ],
        ],
      ),
      actions: [
        if (isWide)
          SizedBox(
            width: 250,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CustomSearchBar(onSelected: (_) {}),
            ),
          ),
        if (isWide)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: auth.isAuthenticated
                ? PopupMenuButton<String>(
                    offset: const Offset(0, kToolbarHeight),
                    tooltip: 'Profil Menüsü',
                    onSelected: (value) async {
                      if (value == 'profile') {
                        Navigator.pushNamed(context, '/profile');
                      } else if (value == 'logout') {
                        await context.read<AuthProvider>().logout();
                        Navigator.pushReplacementNamed(context, '/welcome');
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'profile', child: Text('Profilim')),
                      const PopupMenuItem(value: 'logout', child: Text('Çıkış Yap')),
                    ],
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
                        const SizedBox(width: 6),
                        Text(auth.currentUser?.name ?? 'Profil'),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                        child: const Text('Giriş Yap'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppConstants.primaryGreen),
                        ),
                        onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                        child: const Text('Kayıt Ol'),
                      ),
                    ],
                  ),
          ),
        // Hamburger icon for drawer
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 
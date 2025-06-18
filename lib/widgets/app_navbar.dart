import 'package:flutter/material.dart';
import '../constants/constants.dart';

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Don't show back button
      title: Image.asset('assets/mmv-logo.png', height: 40),
      backgroundColor: const Color(AppConstants.backgroundColor),
      elevation: 0,
      actions: [
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
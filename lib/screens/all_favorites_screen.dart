import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_drawer.dart';
import '../models/film.dart';
import '../services/api_service.dart';
import '../widgets/film_card.dart';
import '../constants/constants.dart';
import '../widgets/app_loader.dart';

class AllFavoritesScreen extends StatefulWidget {
  const AllFavoritesScreen({Key? key}) : super(key: key);

  @override
  State<AllFavoritesScreen> createState() => _AllFavoritesScreenState();
}

class _AllFavoritesScreenState extends State<AllFavoritesScreen> {
  bool _loading = true;
  List<Film> _films = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.get('/interactions/favorites');
      _films = (res.data as List<dynamic>).map((e) => Film.fromJson(e)).toList();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(),
      endDrawer: const AppDrawer(),
      body: _loading
          ? const AppLoader()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: _films.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.6),
                itemBuilder: (_, i) => FilmCard(film: _films[i]),
              ),
            ),
    );
  }
} 
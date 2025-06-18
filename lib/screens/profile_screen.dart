import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/film.dart';
import '../models/film_list_summary.dart';
import '../services/api_service.dart';
import '../widgets/film_card.dart';
import 'dart:async';
import '../widgets/list_card.dart';
import '../constants/constants.dart';
import '../widgets/app_loader.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Film> _favorites = [];
  List<FilmListSummary> _lists = [];
  List<_RatedFilm> _ratings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final tokenExists = auth.token != null;
    if (!tokenExists) return;

    setState(() => _loading = true);
    try {
      final responses = await Future.wait([
        ApiService.get('/interactions/favorites?limit=4'),
        ApiService.get('/lists?limit=2'),
        ApiService.get('/interactions/ratings/latest?limit=5'),
      ]);

      if (responses[0].statusCode == 200) {
        _favorites = (responses[0].data as List<dynamic>).map((e) => Film.fromJson(e)).toList();
      }
      if (responses[1].statusCode == 200) {
        _lists = (responses[1].data as List<dynamic>).map((e) => FilmListSummary.fromJson(e)).toList();
      }
      if (responses[2].statusCode == 200) {
        _ratings = (responses[2].data as List<dynamic>).map((e) => _RatedFilm.fromJson(e)).toList();
      }
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: const AppNavbar(),
        endDrawer: const AppDrawer(),
        body: const AppLoader(),
      );
    }

    return Scaffold(
      appBar: const AppNavbar(),
      endDrawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: user.fullAvatarUrl != null ? NetworkImage(user.fullAvatarUrl!) : null,
                    child: user.fullAvatarUrl == null ? const Icon(Icons.person, size: 40) : null,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(user.email, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _statChip('${user.favoriteCount}', 'Favori'),
                          _statChip('${user.listCount}', 'Liste'),
                          _statChip('${user.ratingCount}', 'Puan'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 800;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LEFT COLUMN
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionCard(
                                title: 'Favori Filmler',
                                child: _buildFavoritesGrid(isWide: true),
                                viewAllRoute: '/favorites-all',
                              ),
                              const SizedBox(height: 24),
                              _sectionCard(
                                title: 'Son Listelerin',
                                child: _buildListsColumn(),
                                viewAllRoute: '/listem',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // RIGHT COLUMN
                        Expanded(
                          child: _sectionCard(
                            title: 'Son Puanlamalar',
                            child: _buildRatingsColumn(),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _sectionCard(title: 'Favori Filmler', child: _buildFavoritesGrid(isWide: false)),
                        const SizedBox(height: 24),
                        _sectionCard(title: 'Son Listelerin', child: _buildListsColumn(), viewAllRoute: '/listem'),
                        const SizedBox(height: 24),
                        _sectionCard(title: 'Son Puanlamalar', child: _buildRatingsColumn()),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        backgroundColor: Colors.grey[800],
        label: Text('$value $label'),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child, String? viewAllRoute}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(AppConstants.cardGrey),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if(viewAllRoute!=null) TextButton(onPressed: () => Navigator.pushNamed(context, viewAllRoute), child: const Text('Tümünü Gör')),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid({required bool isWide}) {
    if (_loading) return const AppLoader();
    if (_favorites.isEmpty) return const Text('Henüz favori film yok');
    final crossAxisCount = isWide ? 2 : 2;
    return GridView.builder(
      itemCount: _favorites.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (_, i) => FilmCard(film: _favorites[i]),
    );
  }

  Widget _buildListsColumn() {
    if (_loading) return const AppLoader();
    if (_lists.isEmpty) return const Text('Liste bulunamadı');
    return Column(
      children: _lists.map((l) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ListCard(list: l),
      )).toList(),
    );
  }

  Widget _buildRatingsColumn() {
    if (_loading) return const AppLoader();
    if (_ratings.isEmpty) return const Text('Puanlama bulunamadı');
    return Column(
      children: _ratings.map((r) => _RatedFilmItem(rated: r)).toList(),
    );
  }
}

class _SimpleListCard extends StatelessWidget {
  final FilmListSummary list;
  const _SimpleListCard({Key? key, required this.list}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(list.name),
        subtitle: Text('${list.filmCount} film'),
        onTap: () => Navigator.pushNamed(context, '/list-detail', arguments: {'id': list.id}),
      ),
    );
  }
}

class _RatedFilm {
  final Film film;
  final double rating;
  final DateTime? ratedAt;
  _RatedFilm({required this.film, required this.rating, this.ratedAt});

  factory _RatedFilm.fromJson(Map<String, dynamic> json) {
    return _RatedFilm(
      film: Film.fromJson(json['film'] ?? {}),
      rating: (json['rating'] ?? 0).toDouble(),
      ratedAt: json['ratedAt'] != null ? DateTime.tryParse(json['ratedAt']) : null,
    );
  }
}

class _RatedFilmItem extends StatelessWidget {
  final _RatedFilm rated;
  const _RatedFilmItem({Key? key, required this.rated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateStr = rated.ratedAt != null ? '${rated.ratedAt!.day}/${rated.ratedAt!.month}/${rated.ratedAt!.year}' : '—';
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: rated.film.fullPosterUrl != null
            ? Image.network(rated.film.fullPosterUrl!, width: 40, fit: BoxFit.cover)
            : const Icon(Icons.movie),
        title: Text(rated.film.title),
        subtitle: Text('Puan: ${rated.rating}  •  $dateStr'),
        onTap: () => Navigator.pushNamed(context, '/film', arguments: {'id': rated.film.id}),
      ),
    );
  }
} 
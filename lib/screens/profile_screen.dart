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
                  Expanded( // Genişlemesi için eklendi
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        Text(user.email, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        SingleChildScrollView( // Yatayda taşmayı engelle
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _statChip('${user.favoriteCount}', 'Favori'),
                              _statChip('${user.listCount}', 'Liste'),
                              _statChip('${user.ratingCount}', 'Puan'),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                          flex: 2, // Sol sütuna daha fazla yer ver
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
                          flex: 1, // Sağ sütuna daha az yer ver
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
                        _sectionCard(title: 'Favori Filmler', child: _buildFavoritesGrid(isWide: false), viewAllRoute: '/favorites-all'),
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
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child, String? viewAllRoute}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3237), // Biraz daha açık bir ton
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if(viewAllRoute != null) 
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, viewAllRoute), 
                  child: const Text('Tümünü Gör >'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white70)
                ),
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
    if (_favorites.isEmpty) return const Center(child: Text('Henüz favori film yok'));
    final crossAxisCount = isWide ? 4 : 2; // Geniş ekranda daha fazla film göster
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
    if (_lists.isEmpty) return const Center(child: Text('Liste bulunamadı'));
    return Column(
      children: _lists.map((l) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ListCard(list: l),
      )).toList(),
    );
  }

  Widget _buildRatingsColumn() {
    if (_loading) return const AppLoader();
    if (_ratings.isEmpty) return const Center(child: Text('Puanlama bulunamadı'));
    return Column(
      children: _ratings.map((r) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: _RatedFilmItem(rated: r),
      )).toList(),
    );
  }
}

class _RatedFilm {
  final Film film;
  final int rating;
  final DateTime? ratedAt;
  _RatedFilm({required this.film, required this.rating, this.ratedAt});

  factory _RatedFilm.fromJson(Map<String, dynamic> json) {
    return _RatedFilm(
      film: Film.fromJson(json['film'] ?? {}),
      rating: (json['userRating'] ?? 0).toInt(), // 'rating' yerine 'userRating'
      ratedAt: json['ratedDate'] != null ? DateTime.tryParse(json['ratedDate']) : null, // 'ratedAt' yerine 'ratedDate'
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
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: rated.film.fullPosterUrl != null
              ? Image.network(rated.film.fullPosterUrl!, width: 40, height: 60, fit: BoxFit.cover)
              : const Icon(Icons.movie, size: 40),
        ),
        title: Text(rated.film.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Puan: ${rated.rating}/10  •  $dateStr'),
        onTap: () => Navigator.pushNamed(context, '/film', arguments: {'id': rated.film.id}),
      ),
    );
  }
}
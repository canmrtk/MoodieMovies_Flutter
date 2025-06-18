import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_drawer.dart';
import '../models/user.dart';
import '../models/film.dart';
import '../models/film_list_summary.dart';
import '../services/api_service.dart';
import '../widgets/film_card.dart';
import '../widgets/list_card.dart';
import '../constants/constants.dart';
import '../widgets/app_loader.dart';

class UserPage extends StatefulWidget {
  final String userId;
  const UserPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _loading = true;
  User? _user;
  List<Film> _favorites = [];
  List<FilmListSummary> _lists = [];
  List<_RatedFilm> _ratings = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await Future.wait([
        ApiService.get('/users/${widget.userId}'),
        ApiService.get('/lists/user/${widget.userId}'),
        ApiService.get('/interactions/public/favorites/${widget.userId}'),
        ApiService.get('/interactions/public/ratings/${widget.userId}'),
      ]);
      _user = User.fromJson(res[0].data);
      _lists = (res[1].data as List<dynamic>).map((e) => FilmListSummary.fromJson(e)).toList();
      _favorites = (res[2].data as List<dynamic>).map((e) => Film.fromJson(e)).toList();
      _ratings = (res[3].data as List<dynamic>).map((e) => _RatedFilm.fromJson(e)).toList();
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
          : _user == null
              ? const Center(child: Text('Kullanıcı bulunamadı'))
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: _user!.fullAvatarUrl != null ? NetworkImage(_user!.fullAvatarUrl!) : null,
                              child: _user!.fullAvatarUrl == null ? const Icon(Icons.person, size: 40) : null,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_user!.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                Text(_user!.email, style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 8),
                                Row(children: [
                                  _statChip('${_user!.favoriteCount}', 'Favori'),
                                  _statChip('${_user!.listCount}', 'Liste'),
                                  _statChip('${_user!.ratingCount}', 'Puan'),
                                ]),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _sectionCard(title: 'Favori Filmler', child: _buildFavoritesGrid()),
                        const SizedBox(height: 24),
                        _sectionCard(title: 'Herkese Açık Listeler', child: _buildListsColumn()),
                        const SizedBox(height: 24),
                        _sectionCard(title: 'Son Puanlamalar', child: _buildRatingsColumn()),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _statChip(String v, String lbl) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Chip(backgroundColor: Colors.grey[800], label: Text('$v $lbl')),
      );

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(AppConstants.cardGrey),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }

  Widget _buildFavoritesGrid() {
    if (_loading) return const AppLoader();
    if (_favorites.isEmpty) return const Text('Favori bulunamadı');
    return GridView.builder(
      itemCount: _favorites.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.6),
      itemBuilder: (_, i) => FilmCard(film: _favorites[i]),
    );
  }

  Widget _buildListsColumn() {
    if (_lists.isEmpty) return const Text('Liste bulunamadı');
    return Column(
      children: _lists.map((l) => Padding(padding: const EdgeInsets.only(bottom: 12), child: ListCard(list: l))).toList(),
    );
  }

  Widget _buildRatingsColumn() {
    if (_ratings.isEmpty) return const Text('Puanlama bulunamadı');
    return Column(
      children: _ratings.map((r) => _RatedFilmItem(rated: r)).toList(),
    );
  }
}

class _RatedFilm {
  final Film film;
  final double rating;
  final DateTime? ratedAt;
  _RatedFilm({required this.film, required this.rating, this.ratedAt});
  factory _RatedFilm.fromJson(Map<String, dynamic> json) => _RatedFilm(
      film: Film.fromJson(json['film'] ?? {}),
      rating: (json['rating'] ?? 0).toDouble(),
      ratedAt: json['ratedAt'] != null ? DateTime.tryParse(json['ratedAt']) : null);
}

class _RatedFilmItem extends StatelessWidget {
  final _RatedFilm rated;
  const _RatedFilmItem({Key? key, required this.rated}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final dateStr = rated.ratedAt != null
        ? '${rated.ratedAt!.day}/${rated.ratedAt!.month}/${rated.ratedAt!.year}'
        : '—';
    return Card(
      color: const Color(AppConstants.cardGrey),
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
import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_drawer.dart';
import '../services/api_service.dart';
import '../models/film.dart';
import '../models/film_list_summary.dart';
import '../models/user.dart';
import '../widgets/film_card.dart';
import '../widgets/list_card.dart';
import '../widgets/user_card.dart';
import '../constants/constants.dart';
import '../widgets/app_loader.dart';

class FilmsPage extends StatefulWidget {
  const FilmsPage({Key? key}) : super(key: key);

  @override
  State<FilmsPage> createState() => _FilmsPageState();
}

class _FilmsPageState extends State<FilmsPage> {
  bool _loading = true;
  List<Film> _popularFavorites = [];
  List<FilmListSummary> _latestLists = [];
  List<User> _reviewers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final responses = await Future.wait([
        ApiService.get('/films/popular/favorites?limit=5'),
        ApiService.get('/lists/public/latest?limit=3'),
        ApiService.get('/users/popular/reviewers?limit=4'),
      ]);
      if (responses[0].statusCode == 200) {
        _popularFavorites = (responses[0].data as List<dynamic>).map((e) => Film.fromJson(e)).toList();
      }
      if (responses[1].statusCode == 200) {
        _latestLists = (responses[1].data as List<dynamic>).map((e) => FilmListSummary.fromJson(e)).toList();
      }
      if (responses[2].statusCode == 200) {
        _reviewers = (responses[2].data as List<dynamic>).map((e) => User.fromJson(e)).toList();
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(),
      endDrawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            if (isWide) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT COLUMN
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _sectionCard(
                            title: 'En Çok Favorilenen Filmler',
                            child: _buildPopularFavorites(),
                            viewAllRoute: '/favorites-all',
                          ),
                          const SizedBox(height: 24),
                          _sectionCard(
                            title: 'Son Eklenen Herkese Açık Listeler',
                            child: _buildLatestLists(),
                            viewAllRoute: '/lists-all',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // RIGHT COLUMN
                    Expanded(
                      flex: 2,
                      child: _sectionCard(
                        title: 'Popüler İncelemeciler',
                        child: _buildReviewers(),
                        viewAllRoute: '/reviewers-all',
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Mobile single column
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _sectionCard(title: 'En Çok Favorilenen Filmler', child: _buildPopularFavorites(), viewAllRoute: '/favorites-all'),
                    const SizedBox(height: 24),
                    _sectionCard(title: 'Son Eklenen Herkese Açık Listeler', child: _buildLatestLists(), viewAllRoute: '/lists-all'),
                    const SizedBox(height: 24),
                    _sectionCard(title: 'Popüler İncelemeciler', child: _buildReviewers(), viewAllRoute: '/reviewers-all'),
                  ],
                ),
              );
            }
          },
        ),
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
              TextButton(onPressed: viewAllRoute!=null ? () => Navigator.pushNamed(context, viewAllRoute) : null, child: const Text('Tümünü Gör')),
            ],
          ),
          const SizedBox(height: 12),
          _loading ? const AppLoader() : child,
        ],
      ),
    );
  }

  Widget _buildPopularFavorites() {
    if (_popularFavorites.isEmpty) return const Text('Film bulunamadı');
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _popularFavorites.length,
        itemBuilder: (_, i) => Container(
          width: 150,
          margin: const EdgeInsets.only(right: 12),
          child: FilmCard(film: _popularFavorites[i]),
        ),
      ),
    );
  }

  Widget _buildLatestLists() {
    if (_latestLists.isEmpty) return const Text('Liste bulunamadı');
    return Column(
      children: _latestLists.map((l) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ListCard(list: l),
      )).toList(),
    );
  }

  Widget _buildReviewers() {
    if (_reviewers.isEmpty) return const Text('Kullanıcı bulunamadı');
    return Column(
      children: _reviewers.map((u) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: UserCard(user: u),
      )).toList(),
    );
  }
} 
import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_loader.dart';
import '../models/film_list_summary.dart';
import '../widgets/list_card.dart';
import '../services/api_service.dart';

class AllListsScreen extends StatefulWidget {
  const AllListsScreen({Key? key}) : super(key: key);

  @override
  State<AllListsScreen> createState() => _AllListsScreenState();
}

class _AllListsScreenState extends State<AllListsScreen> {
  bool _loading = true;
  List<FilmListSummary> _lists = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.get('/lists/public');
      if (res.statusCode == 200) {
        _lists = (res.data as List<dynamic>).map((e) => FilmListSummary.fromJson(e)).toList();
      }
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
          : RefreshIndicator(
              onRefresh: _fetch,
              child: _lists.isEmpty
                  ? const Center(child: Text('Liste bulunamadı'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _lists.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => ListCard(list: _lists[i]),
                    ),
            ),
    );
  }
} 
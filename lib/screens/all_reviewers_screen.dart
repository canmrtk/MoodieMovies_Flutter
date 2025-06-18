import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_loader.dart';
import '../widgets/user_card.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AllReviewersScreen extends StatefulWidget {
  const AllReviewersScreen({Key? key}) : super(key: key);

  @override
  State<AllReviewersScreen> createState() => _AllReviewersScreenState();
}

class _AllReviewersScreenState extends State<AllReviewersScreen> {
  bool _loading = true;
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.get('/users/popular/reviewers');
      if (res.statusCode == 200) {
        _users = (res.data as List<dynamic>).map((e) => User.fromJson(e)).toList();
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
              child: _users.isEmpty
                  ? const Center(child: Text('Kullanıcı bulunamadı'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => UserCard(user: _users[i]),
                    ),
            ),
    );
  }
} 
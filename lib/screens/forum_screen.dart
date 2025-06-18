import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_drawer.dart';
import '../models/forum_post_summary.dart';
import '../models/forum_post_create.dart';
import '../services/api_service.dart';
import '../constants/constants.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/notifications.dart';
import '../widgets/app_loader.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  bool _loading = true;
  List<ForumPostSummary> _posts = [];

  // form controllers
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String _selectedTag = 'Genel';
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() => _loading = true);
    final response = await ApiService.get('/forum/posts');
    if (response.statusCode == 200) {
      final list = response.data['content'] ?? response.data ?? [];
      _posts = (list as List<dynamic>).map((e) => ForumPostSummary.fromJson(e)).toList();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _submitPost() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) return;
    setState(() => _posting = true);
    final create = ForumPostCreate(title: title, tag: _selectedTag, context: content);
    try {
      final response = await ApiService.post('/forum/posts', body: create.toJson());
      setState(() => _posting = false);
      final newPost = ForumPostSummary.fromJson(response.data);
      setState(() {
        _posts.insert(0, newPost);
        _titleCtrl.clear();
        _contentCtrl.clear();
      });
      showSuccess(context, 'Başlık oluşturuldu');
    } catch (e) {
      setState(() => _posting = false);
      showError(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _deletePostById(String id) async {
    try {
      await ApiService.delete('/forum/posts/$id');
      setState(() => _posts.removeWhere((p) => p.id == id));
      showSuccess(context, 'Başlık silindi');
    } catch (e) {
      showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: const AppNavbar(),
      endDrawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _fetchPosts,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (auth.isAuthenticated) _buildCreateForm(),
              const SizedBox(height: 24),
              _loading ? const AppLoader() : _buildPostList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(AppConstants.cardGrey),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Yeni Konu Başlat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Başlık'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedTag,
            decoration: const InputDecoration(labelText: 'Etiket'),
            items: const [ 'Genel', 'Film', 'Dizi', 'Soru' ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _selectedTag = v ?? 'Genel'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _contentCtrl,
            decoration: const InputDecoration(labelText: 'İçerik'),
            maxLines: 5,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _posting ? null : _submitPost,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(AppConstants.primaryGreen)),
            child: _posting ? const CircularProgressIndicator() : const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostList() {
    if (_posts.isEmpty) return const Text('Henüz başlık yok');
    return Column(
      children: _posts.map((p) => _ForumPostTile(post: p)).toList(),
    );
  }
}

class _ForumPostTile extends StatelessWidget {
  final ForumPostSummary post;
  const _ForumPostTile({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/forum/detay/${post.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(AppConstants.cardGrey),
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          boxShadow: AppConstants.defaultShadow,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: post.authorAvatarUrl != null ? NetworkImage(post.authorAvatarUrl!) : null,
              child: post.authorAvatarUrl == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${post.authorName} • ${post.commentCount} yorum • ${_timeSince(post.createdAt)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeSince(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) return '${diff.inDays}g önce';
    if (diff.inHours >= 1) return '${diff.inHours}s önce';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}dk önce';
    return 'az önce';
  }
} 
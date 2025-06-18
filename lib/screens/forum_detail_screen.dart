import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_drawer.dart';
import '../models/forum_post_detail.dart';
import '../models/forum_comment.dart';
import '../models/forum_comment_create.dart';
import '../services/api_service.dart';
import '../constants/constants.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_loader.dart';
import '../utils/notifications.dart';

class ForumDetailScreen extends StatefulWidget {
  final String postId;
  const ForumDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  bool _loading = true;
  ForumPostDetail? _post;
  final _commentCtrl = TextEditingController();
  bool _commentPosting = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => _loading = true);
    final response = await ApiService.get('/forum/posts/${widget.postId}');
    if (response.statusCode == 200) {
      _post = ForumPostDetail.fromJson(response.data);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _submitComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _commentPosting = true);
    final create = ForumCommentCreate(text);
    try {
      final resp = await ApiService.post('/forum/posts/${widget.postId}/comments', body: create.toJson());
      final comm = ForumComment.fromJson(resp.data);
      setState(() {
        _post!.comments.add(comm);
        _commentCtrl.clear();
      });
      showSuccess(context, 'Yorum eklendi');
    } catch (e) {
      showError(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _commentPosting = false);
    }
  }

  Future<void> _deletePost() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Başlığı Sil'),
        content: const Text('Bu başlığı silmek istediğinize emin misiniz?'),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil'))],
      ),
    );
    if (ok != true) return;
    final res = await ApiService.delete('/forum/posts/${widget.postId}');
    if (res.statusCode == 204 || res.statusCode == 200) {
      if (mounted) Navigator.pop(context); // geri dön forum listesine
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userId = auth.currentUser?.id;
    return Scaffold(
      appBar: const AppNavbar(),
      endDrawer: const AppDrawer(),
      body: _loading
          ? const AppLoader()
          : _post == null
              ? const Center(child: Text('Başlık bulunamadı'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post Card
                      Container(
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
                              children: [
                                CircleAvatar(
                                  backgroundImage: _post!.authorAvatarUrl != null
                                      ? NetworkImage(_post!.authorAvatarUrl!.startsWith('http') ? _post!.authorAvatarUrl! : '${AppConstants.baseUrl}${_post!.authorAvatarUrl!}')
                                      : null,
                                  child: _post!.authorAvatarUrl == null ? const Icon(Icons.person) : null,
                                ),
                                const SizedBox(width: 8),
                                Text(_post!.authorName),
                                const Spacer(),
                                Text(_timeSince(_post!.createdAt)),
                                if (userId == _post!.authorId) ...[
                                  IconButton(onPressed: _deletePost, icon: const Icon(Icons.delete, size: 20))
                                ]
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(_post!.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(_post!.content),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Yorumlar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ..._post!.comments.map((c) => _CommentTile(comment: c, isOwner: c.authorId == userId, onDelete: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(title: const Text('Yorumu Sil'), content: const Text('Yorumu silmek istiyor musunuz?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil'))]),
                            );
                            if (ok == true) {
                              final res = await ApiService.delete('/forum/comments/${c.id}');
                              if (res.statusCode == 204 || res.statusCode == 200) {
                                setState(() => _post!.comments.removeWhere((el) => el.id == c.id));
                              }
                            }
                          })),
                      const SizedBox(height: 24),
                      if (auth.isAuthenticated) _buildCommentForm(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCommentForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(AppConstants.cardGrey),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _commentCtrl,
            decoration: const InputDecoration(labelText: 'Yorumunuzu yazın'),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _commentPosting ? null : _submitComment,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(AppConstants.primaryGreen)),
            child: _commentPosting ? const CircularProgressIndicator() : const Text('Yorum Yap'),
          )
        ],
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

class _CommentTile extends StatelessWidget {
  final ForumComment comment;
  final bool isOwner;
  final VoidCallback onDelete;
  const _CommentTile({Key? key, required this.comment, required this.isOwner, required this.onDelete}) : super(key: key);

  String _timeSince(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) return '${diff.inDays}g';
    if (diff.inHours >= 1) return '${diff.inHours}s';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}dk';
    return 'az önce';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(AppConstants.cardGrey),
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        boxShadow: AppConstants.defaultShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: comment.authorAvatarUrl != null
                ? NetworkImage(comment.authorAvatarUrl!.startsWith('http') ? comment.authorAvatarUrl! : '${AppConstants.baseUrl}${comment.authorAvatarUrl!}')
                : null,
            child: comment.authorAvatarUrl == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(comment.authorName, style: const TextStyle(fontWeight: FontWeight.bold))),
                    Text(_timeSince(comment.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    if (isOwner)
                      IconButton(icon: const Icon(Icons.delete, size: 18), padding: EdgeInsets.zero, onPressed: onDelete),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 
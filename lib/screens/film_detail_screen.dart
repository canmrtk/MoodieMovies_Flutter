import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/user_lists_provider.dart';
import '../widgets/create_list_dialog.dart';
import '../widgets/app_loader.dart';

class FilmDetailScreen extends StatefulWidget {
  final String filmId;
  const FilmDetailScreen({Key? key, required this.filmId}) : super(key: key);

  @override
  State<FilmDetailScreen> createState() => _FilmDetailScreenState();
}

class _FilmDetailScreenState extends State<FilmDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    final response = await ApiService.get('/films/${widget.filmId}');
    if (response.statusCode == 200) {
      setState(() { _data = response.data; _loading = false; });
    } else {
      setState(() { _error = 'Film getirilemedi'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Film Detayı'), backgroundColor: const Color(0xFF1B1D23)),
      body: _loading
          ? const AppLoader()
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _data!['imageUrl'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(_data!['imageUrl'], fit: BoxFit.cover),
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 16),
                      Text(_data!['title'] ?? '', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (_data!['genres'] != null)
                        Wrap(
                          spacing: 8,
                          children: List<Widget>.from((_data!['genres'] as List<dynamic>).map((g) => Chip(label: Text(g)))).toList(),
                        ),
                      const SizedBox(height: 16),
                      Text(_data!['plot'] ?? ''),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await _showAddToListSheet(context);
                        },
                        icon: const Icon(Icons.playlist_add),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(AppConstants.primaryGreen)),
                        label: const Text('Listeme Ekle'),
                      ),
                    ],
                  ),
                ),
    );
  }

  Future<void> _showAddToListSheet(BuildContext context) async {
    final userListsProvider = context.read<UserListsProvider>();
    if (userListsProvider.lists.isEmpty && !userListsProvider.loading) {
      await userListsProvider.fetchLists();
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2B2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: userListsProvider,
        child: SizedBox(
          height: 400,
          child: Consumer<UserListsProvider>(
            builder: (context, prov, __) {
              if (prov.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Liste Seç', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            final created = await showDialog(
                                context: context, builder: (_) => const CreateListDialog());
                            if (created == true) {
                              // lists refreshed inside provider
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: prov.lists.isEmpty
                        ? const Center(child: Text('Liste bulunamadı'))
                        : ListView.builder(
                            itemCount: prov.lists.length,
                            itemBuilder: (context, index) {
                              final list = prov.lists[index];
                              return ListTile(
                                title: Text(list.name),
                                subtitle: Text('${list.filmCount} film'),
                                onTap: () async {
                                  final success = await prov.addFilmToList(list.id, widget.filmId);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    SnackBar(content: Text(success ? 'Film listeye eklendi' : 'Ekleme başarısız')),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
} 
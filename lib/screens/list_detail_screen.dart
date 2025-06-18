import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_navbar.dart';
import '../providers/list_detail_provider.dart';
import '../widgets/film_card.dart';
import '../providers/user_lists_provider.dart';
import '../widgets/edit_list_dialog.dart';

class ListDetailScreen extends StatelessWidget {
  final String listId;
  const ListDetailScreen({Key? key, required this.listId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final p = ListDetailProvider();
        p.fetchDetail(listId);
        return p;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Liste Detayı'),
          backgroundColor: const Color(0xFF1B1D23),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final detail = context.read<ListDetailProvider>().detail;
                if (detail == null) return;
                final updated = await showDialog(
                  context: context,
                  builder: (_) => EditListDialog(
                    listId: detail.id,
                    initialName: detail.name,
                    initialTag: detail.tag,
                    initialDescription: detail.description,
                    initialVisible: (detail.visibility ?? 1) == 1,
                  ),
                );
                if (updated == true) {
                  // also refresh lists overview
                  if (context.mounted) {
                    context.read<UserListsProvider>().fetchLists();
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Listeyi Sil'),
                    content: const Text('Bu listeyi silmek istediğinize emin misiniz?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
                      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
                    ],
                  ),
                );
                if (confirm == true) {
                  final detail = context.read<ListDetailProvider>().detail;
                  if (detail == null) return;
                  final success = await context.read<ListDetailProvider>().deleteList(detail.id);
                  if (success && context.mounted) {
                    context.read<UserListsProvider>().fetchLists();
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ),
        body: Consumer<ListDetailProvider>(
          builder: (context, prov, _) {
            if (prov.loading) return const Center(child: CircularProgressIndicator());
            if (prov.error != null) return Center(child: Text(prov.error!, style: const TextStyle(color: Colors.red)));
            if (prov.detail == null) return const SizedBox.shrink();
            final detail = prov.detail!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(detail.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (detail.description != null && detail.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(detail.description!),
                ],
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: detail.films.length,
                  itemBuilder: (context, index) {
                    final film = detail.films[index];
                    return Stack(
                      children: [
                        FilmCard(film: film),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Filmi Kaldır'),
                                  content: const Text('Bu filmi listeden çıkarmak istiyor musunuz?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
                                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Kaldır')),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await context.read<ListDetailProvider>().removeFilm(detail.id, film.id);
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
} 
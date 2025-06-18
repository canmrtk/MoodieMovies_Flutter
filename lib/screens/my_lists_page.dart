import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_lists_provider.dart';
import '../widgets/app_navbar.dart';
import '../widgets/create_list_dialog.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_loader.dart';

class MyListsPage extends StatefulWidget {
  const MyListsPage({Key? key}) : super(key: key);

  @override
  State<MyListsPage> createState() => _MyListsPageState();
}

class _MyListsPageState extends State<MyListsPage> {
  @override
  void initState() {
    super.initState();
    context.read<UserListsProvider>().fetchLists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(),
      endDrawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (_) => const CreateListDialog(),
          );
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Liste oluşturuldu')));
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<UserListsProvider>(
        builder: (context, prov, _) {
          if (prov.loading) return const AppLoader();
          if (prov.error != null) return Center(child: Text(prov.error!, style: const TextStyle(color: Colors.red)));
          if (prov.lists.isEmpty) return const Center(child: Text('Henüz listeniz yok'));

          return ListView.separated(
            itemCount: prov.lists.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final list = prov.lists[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: const Color(0xFF4A4B4E),
                child: ListTile(
                  title: Text(list.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${list.filmCount} film'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushNamed(context, '/list-detail', arguments: {'id': list.id});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 
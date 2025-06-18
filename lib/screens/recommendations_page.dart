import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recommendation_provider.dart';
import '../widgets/film_card.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_loader.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({Key? key}) : super(key: key);

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<RecommendationProvider>().fetch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(),
      endDrawer: const AppDrawer(),
      body: Consumer<RecommendationProvider>(
        builder: (context, prov, _) {
          if (prov.loading) return const AppLoader();
          if (prov.error != null) return Center(child: Text(prov.error!, style: const TextStyle(color: Colors.red)));
          if (prov.visible.isEmpty) return const Center(child: Text('Öneri bulunamadı'));

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemCount: prov.visible.length,
            itemBuilder: (context, index) {
              final film = prov.visible[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: FilmCard(film: film)),
                  const SizedBox(height: 6),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(36),
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () => prov.markWatched(film.id),
                    child: const Text('İzledim'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
} 
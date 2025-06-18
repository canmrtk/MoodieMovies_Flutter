import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_navbar.dart';
import '../widgets/film_card.dart';
import '../providers/films_catalog_provider.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/app_drawer.dart';

class FilmsPage extends StatefulWidget {
  const FilmsPage({Key? key}) : super(key: key);

  @override
  State<FilmsPage> createState() => _FilmsPageState();
}

class _FilmsPageState extends State<FilmsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<FilmsCatalogProvider>();
    provider.refresh();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
        provider.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(),
      endDrawer: const AppDrawer(),
      body: Consumer<FilmsCatalogProvider>(
        builder: (context, catalog, _) {
          return RefreshIndicator(
            onRefresh: catalog.refresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomSearchBar(onSelected: (_) {}),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= catalog.films.length) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final film = catalog.films[index];
                        return FilmCard(film: film);
                      },
                      childCount: catalog.hasNext ? catalog.films.length + 1 : catalog.films.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 
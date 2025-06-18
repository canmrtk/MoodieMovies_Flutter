import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/film_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_navbar.dart';
import '../widgets/film_card.dart';
import '../constants/constants.dart';
import '../widgets/app_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FilmProvider>().fetchPopular();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(),
      endDrawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => context.read<FilmProvider>().fetchPopular(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://www.hollywoodreporter.com/wp-content/uploads/2014/11/godfather_cat.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'İzlediğiniz filmleri takip edin.\nGörmek istediklerinizi kaydedin.\nArkadaşlarınıza neyin iyi olduğunu söyleyin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/test-intro');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppConstants.primaryGreen),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('SANA FİLM ÖNEREYİM Mİ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EN SON BAKTIKLARIN', style: Theme.of(context).textTheme.titleMedium),
                    const Divider(height: 16, thickness: 1),
                    const SizedBox(height: 12),
                    Consumer<FilmProvider>(
                      builder: (context, filmProvider, _) {
                        if (filmProvider.loading) {
                          return const AppLoader();
                        }
                        if (filmProvider.error != null) {
                          return Center(child: Text(filmProvider.error!));
                        }
                        return SizedBox(
                          height: 250,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: filmProvider.films.length,
                            itemBuilder: (context, index) {
                              final film = filmProvider.films[index];
                              return Container(
                                width: 150,
                                margin: const EdgeInsets.only(right: 12),
                                child: FilmCard(film: film),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
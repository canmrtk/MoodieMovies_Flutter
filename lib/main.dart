import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'constants/constants.dart';
import 'providers/auth_provider.dart';
import 'providers/film_provider.dart';
import 'providers/search_provider.dart';
import 'providers/films_catalog_provider.dart';
import 'providers/user_lists_provider.dart';
import 'providers/recommendation_provider.dart';
import 'providers/test_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/film_detail_screen.dart';
import 'screens/films_page.dart';
import 'screens/my_lists_page.dart';
import 'screens/list_detail_screen.dart';
import 'screens/recommendations_page.dart';
import 'screens/test_intro_screen.dart';
import 'screens/test_success_screen.dart';
import 'screens/test_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/forum_screen.dart';
import 'screens/forum_detail_screen.dart';
import 'screens/all_favorites_screen.dart';
import 'screens/user_page.dart';
import 'screens/all_lists_screen.dart';
import 'screens/all_reviewers_screen.dart';

void main() {
  runApp(const MoodieMoviesApp());
}

class MoodieMoviesApp extends StatelessWidget {
  const MoodieMoviesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FilmProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => FilmsCatalogProvider()),
        ChangeNotifierProvider(create: (_) => UserListsProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
        ChangeNotifierProvider(create: (_) => TestProvider()),
      ],
      child: MaterialApp(
        title: 'MoodieMovies',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(AppConstants.backgroundColor),
          primaryColor: const Color(AppConstants.primaryGreen),
          colorScheme: ColorScheme.dark(
            primary: const Color(AppConstants.primaryGreen),
            secondary: const Color(AppConstants.accentBlue),
          ),
          textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
              .apply(bodyColor: Colors.white, displayColor: Colors.white),
        ),
        initialRoute: '/welcome',
        routes: {
          '/welcome': (_) => const WelcomeScreen(),
          '/login': (_) => const LoginScreen(),
          '/home': (_) => const HomeScreen(),
          '/film': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return FilmDetailScreen(filmId: args['id'] as String);
          },
          '/films': (_) => const FilmsPage(),
          '/listem': (_) => const MyListsPage(),
          '/list-detail': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return ListDetailScreen(listId: args['id'] as String);
          },
          '/test-intro': (_) => const TestIntroScreen(),
          '/test-success': (_) => const TestSuccessScreen(),
          '/recommendations': (_) => const RecommendationsPage(),
          '/forum': (_) => const ForumScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/register': (_) => const RegisterScreen(),
          '/favorites-all': (_) => const AllFavoritesScreen(),
          '/lists-all': (_) => const AllListsScreen(),
          '/reviewers-all': (_) => const AllReviewersScreen(),
          // TODO: add more routes
        },
        onGenerateRoute: (settings){
          if(settings.name!=null && settings.name!.startsWith('/user/')){
            final userId=settings.name!.split('/').last;
            return MaterialPageRoute(builder: (_) => UserPage(userId: userId));
          }
          if(settings.name!=null && settings.name!.startsWith('/forum/detay/')){
            final postId=settings.name!.split('/').last;
            return MaterialPageRoute(builder: (_) => ForumDetailScreen(postId: postId));
          }
          if(settings.name!=null && settings.name!.startsWith('/test/')){
            final pageStr=settings.name!.split('/').last;
            final page=int.tryParse(pageStr)??1;
            return MaterialPageRoute(builder: (_) => TestScreen(page: page));
          }
          return null;
        },
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../models/film_suggestion.dart';

class SearchBar extends StatelessWidget {
  final void Function(String filmId) onSelected;
  const SearchBar({Key? key, required this.onSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);

    return TypeAheadField<FilmSuggestion>(
      suggestionsCallback: (pattern) async {
        await searchProvider.fetchSuggestions(pattern);
        return searchProvider.suggestions;
      },
      itemBuilder: (context, FilmSuggestion suggestion) {
        return ListTile(
          leading: suggestion.imageUrl.isNotEmpty ? Image.network(suggestion.imageUrl, width: 40, fit: BoxFit.cover) : null,
          title: Text(suggestion.title),
        );
      },
      onSelected: (FilmSuggestion suggestion) {
        onSelected(suggestion.id);
        Navigator.pushNamed(context, '/film', arguments: {'id': suggestion.id});
      },
      emptyBuilder: (_) => const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('Sonuç bulunamadı'),
      ),
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Film ara...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            prefixIcon: const Icon(Icons.search),
          ),
        );
      },
    );
  }
} 
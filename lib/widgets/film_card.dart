import 'package:flutter/material.dart';
import '../models/film.dart';
import '../constants/constants.dart';

class FilmCard extends StatelessWidget {
  final Film film;
  final VoidCallback? onTap;
  const FilmCard({Key? key, required this.film, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        Navigator.pushNamed(context, '/film', arguments: {'id': film.id});
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(AppConstants.cardGrey),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: film.fullPosterUrl != null
                    ? Image.network(film.fullPosterUrl!, fit: BoxFit.cover)
                    : Image.asset('assets/placeholder_poster.png', fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                film.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

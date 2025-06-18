import 'package:flutter/material.dart';
import '../models/film_list_summary.dart';
import '../constants/constants.dart';

class ListCard extends StatelessWidget {
  final FilmListSummary list;
  const ListCard({Key? key, required this.list}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/list-detail', arguments: {'id': list.id});
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(AppConstants.cardGrey),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _buildPosterStack(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(list.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${list.filmCount} film', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPosterStack() {
    final posters = list.films.take(3).toList();
    return SizedBox(
      width: 70,
      height: 90,
      child: Stack(
        children: [
          for (int i = 0; i < posters.length; i++)
            Positioned(
              left: i * 20.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: posters[i].fullPosterUrl != null
                    ? Image.network(posters[i].fullPosterUrl!, width: 50, height: 75, fit: BoxFit.cover)
                    : Image.asset('assets/placeholder_poster.png', width: 50, height: 75, fit: BoxFit.cover),
              ),
            ),
        ],
      ),
    );
  }
} 
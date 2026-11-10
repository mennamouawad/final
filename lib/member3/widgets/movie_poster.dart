import 'package:flutter/material.dart';

class MoviePoster extends StatelessWidget {
  final String url;
  final double width;
  final double height;

  const MoviePoster({
    super.key,
    required this.url,
    this.width = 110,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: Colors.white10,
      child: const Icon(Icons.movie_outlined, size: 45),
    );
    if (url.isEmpty) return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: placeholder,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : placeholder,
      ),
    );
  }
}

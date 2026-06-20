import 'package:flutter/material.dart';

class PlaceImage extends StatelessWidget {
  const PlaceImage({
    super.key,
    required this.imageUrl,
    this.height = 150,
    this.width,
  });

  final String imageUrl;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.image_not_supported,
          size: 50,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width,
            color: Colors.grey.shade300,
            child: const Icon(
              Icons.broken_image,
              size: 50,
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PlaceImage extends StatelessWidget {
  const PlaceImage({super.key, required this.label, this.height = 150, this.width});

  final String label;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primaryContainer, Theme.of(context).colorScheme.tertiaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_rounded, size: 42, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

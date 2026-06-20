import 'package:flutter/material.dart';

import '../models/food_place.dart';
import 'place_image.dart';
import 'rating_stars.dart';

class PlaceCard extends StatelessWidget {
  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    this.distance,
  });

  final FoodPlace place;
  final VoidCallback onTap;
  final double? distance;

  String get distanceText {
    if (distance == null) {
      return '';
    }

    if (distance! < 1000) {
      return '${distance!.toStringAsFixed(0)} m';
    }

    return '${(distance! / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = place.imageUrls.isNotEmpty ? place.imageUrls.first : '';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          18,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          18,
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(
            12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlaceImage(
                imageUrl: imageUrl,
                width: 110,
                height: 110,
              ),
              const SizedBox(
                width: 14,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (distance != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                            child: Text(
                              distanceText,
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      place.location,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        RatingStars(
                          rating: place.averageRating,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          place.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          '(${place.reviewCount})',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Chip(
                          label: Text(
                            place.priceRange,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        Chip(
                          label: Text(
                            place.priceCategory,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        if (distance != null && distance! < 500)
                          const Chip(
                            backgroundColor: Color(0xFFB2FF59),
                            label: Text(
                              'Terdekat',
                            ),
                          ),
                      ],
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/food_place.dart';
import '../models/review.dart';
import '../services/place_service.dart';
import '../widgets/place_image.dart';
import '../widgets/rating_stars.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.placeId,
  });

  final String placeId;

  Future<void> _openGoogleMaps(
    BuildContext context,
    FoodPlace place,
  ) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${place.latitude},${place.longitude}',
    );

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal membuka Google Maps',
            ),
          ),
        );
      }
    }
  }

  Future<void> _showReviewDialog(
    BuildContext context,
    FoodPlace place,
  ) async {
    final nameController = TextEditingController();
    final commentController = TextEditingController();

    double rating = 5;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Beri Ulasan',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Komentar',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rating: ${rating.toStringAsFixed(1)}',
                    ),
                    Slider(
                      value: rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: rating.toString(),
                      onChanged: (value) {
                        setDialogState(() {
                          rating = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Batal',
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty ||
                        commentController.text.trim().isEmpty) {
                      return;
                    }

                    final review = Review(
                      userName: nameController.text.trim(),
                      comment: commentController.text.trim(),
                      rating: rating,
                    );

                    await PlaceService.addReview(
                      place.id,
                      review,
                    );

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text(
                    'Simpan',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('places')
            .doc(placeId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Tempat tidak ditemukan',
              ),
            );
          }

          final place = FoodPlace.fromFirestore(
            snapshot.data!.id,
            snapshot.data!.data()!,
          );

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: const Color(
                  0xFF07111F,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: PlaceImage(
                    imageUrl:
                        place.imageUrls.isNotEmpty ? place.imageUrls.first : '',
                    height: 280,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          RatingStars(
                            rating: place.averageRating,
                            size: 22,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            '${place.averageRating.toStringAsFixed(1)} '
                            '(${place.reviewCount} ulasan)',
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Text(
                              place.location,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.payments,
                            color: Colors.green,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            place.priceRange,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Chip(
                        label: Text(
                          place.priceCategory,
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        'Deskripsi',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        place.description,
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openGoogleMaps(
                            context,
                            place,
                          ),
                          icon: const Icon(
                            Icons.map,
                          ),
                          label: const Text(
                            'Buka di Google Maps',
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showReviewDialog(
                            context,
                            place,
                          ),
                          icon: const Icon(
                            Icons.rate_review,
                          ),
                          label: const Text(
                            'Beri Ulasan',
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        'Menu Makanan & Minuman',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (place.menuItems.isEmpty)
                        const Text(
                          'Belum ada menu',
                        )
                      else
                        Column(
                          children: place.menuItems
                              .map(
                                (item) => Card(
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.restaurant_menu,
                                    ),
                                    title: Text(
                                      item.name,
                                    ),
                                    trailing: Text(
                                      'Rp ${item.price}',
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        'Ulasan Pengunjung',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (place.reviews.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(
                              16,
                            ),
                            child: Text(
                              'Belum ada ulasan',
                            ),
                          ),
                        )
                      else
                        Column(
                          children: place.reviews
                              .map(
                                (review) => Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Text(
                                        review.userName.isNotEmpty
                                            ? review.userName[0].toUpperCase()
                                            : '?',
                                      ),
                                    ),
                                    title: Text(
                                      review.userName,
                                    ),
                                    subtitle: Text(
                                      review.comment,
                                    ),
                                    trailing: Text(
                                      review.rating.toStringAsFixed(1),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        'Fasilitas',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: place.facilities
                            .map(
                              (facility) => Chip(
                                label: Text(
                                  facility,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        'Galeri Foto',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (place.imageUrls.isEmpty)
                        const Text(
                          'Belum ada foto',
                        )
                      else
                        SizedBox(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: place.imageUrls.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 220,
                                margin: const EdgeInsets.only(
                                  right: 12,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    16,
                                  ),
                                  child: PlaceImage(
                                    imageUrl: place.imageUrls[index],
                                    width: 220,
                                    height: 140,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

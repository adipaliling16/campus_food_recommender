import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/food_repository.dart';
import '../models/review.dart';
import '../widgets/place_image.dart';
import '../widgets/rating_stars.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.placeId});

  final String placeId;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _repository = FoodRepository.instance;

  Future<void> _openGoogleMaps(String query) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
      );
    }
  }

  void _showReviewSheet() {
    final nameController = TextEditingController();
    final commentController = TextEditingController();
    double rating = 5;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Ulasan',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(labelText: 'Ulasan'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Rating'),
                  Expanded(
                    child: Slider(
                      value: rating,
                      min: 1,
                      max: 5,
                      divisions: 8,
                      label: rating.toStringAsFixed(1),
                      onChanged: (value) => setModalState(() => rating = value),
                    ),
                  ),
                  Text(rating.toStringAsFixed(1)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty ||
                        commentController.text.trim().isEmpty) {
                      return;
                    }

                    _repository.addReview(
                      widget.placeId,
                      Review(
                        userName: nameController.text.trim(),
                        comment: commentController.text.trim(),
                        rating: rating,
                      ),
                    );

                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: const Text('Simpan Ulasan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final place = _repository.getById(widget.placeId);

    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showReviewSheet,
        icon: const Icon(Icons.rate_review_rounded),
        label: const Text('Review'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PlaceImage(label: place.imageUrls.first, height: 220),
          const SizedBox(height: 16),
          Text(
            place.name,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              RatingStars(rating: place.averageRating, size: 22),
              const SizedBox(width: 8),
              Text(
                '${place.averageRating.toStringAsFixed(1)} dari ${place.reviews.length} ulasan',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.place_rounded),
              const SizedBox(width: 8),
              Expanded(child: Text(place.location)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.payments_rounded),
              const SizedBox(width: 8),
              Text(place.priceRange),
            ],
          ),
          const SizedBox(height: 18),
          Text(place.description),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.map_rounded),
              label: const Text('Buka di Google Maps'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () =>
                  _openGoogleMaps('${place.name}, ${place.location}'),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Menu',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...place.menuItems.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.fastfood_rounded)),
              title: Text(item.name),
              trailing: Text('Rp${item.price}'),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Fasilitas',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: place.facilities
                .map((facility) => Chip(label: Text(facility)))
                .toList(),
          ),
          const SizedBox(height: 22),
          Text(
            'Galeri Foto',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => PlaceImage(
                label: place.imageUrls[index],
                height: 120,
                width: 160,
              ),
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: place.imageUrls.length,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Ulasan Pengguna',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (place.reviews.isEmpty)
            const Text('Belum ada ulasan.')
          else
            ...place.reviews.map(
              (review) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(review.userName.substring(0, 1).toUpperCase()),
                  ),
                  title: Text(review.userName),
                  subtitle: Text(review.comment),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber),
                      Text(review.rating.toStringAsFixed(1)),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

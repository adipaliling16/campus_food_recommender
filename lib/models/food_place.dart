import 'menu_item.dart';
import 'review.dart';

class FoodPlace {
  FoodPlace({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.priceCategory,
    required this.priceRange,
    required this.imageUrls,
    required this.menuItems,
    required this.facilities,
    required this.reviews,
    required this.rating,
    required this.reviewCount,
  });

  final String id;

  String name;
  String description;
  String location;

  double latitude;
  double longitude;

  String priceCategory;
  String priceRange;

  List<String> imageUrls;
  List<MenuItem> menuItems;
  List<String> facilities;
  List<Review> reviews;

  double rating;
  int reviewCount;

  factory FoodPlace.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return FoodPlace(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      priceCategory: data['priceCategory'] ?? 'Murah',
      priceRange: data['priceRange'] ?? '',
      imageUrls: List<String>.from(
        data['imageUrls'] ?? [],
      ),
      facilities: List<String>.from(
        data['facilities'] ?? [],
      ),
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      menuItems: (data['menuItems'] as List<dynamic>? ?? [])
          .map(
            (item) => MenuItem(
              name: item['name'] ?? '',
              price: item['price'] ?? 0,
            ),
          )
          .toList(),
      reviews: (data['reviews'] as List<dynamic>? ?? [])
          .map(
            (review) => Review.fromMap(
              Map<String, dynamic>.from(review),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'priceCategory': priceCategory,
      'priceRange': priceRange,
      'imageUrls': imageUrls,
      'facilities': facilities,
      'rating': rating,
      'reviewCount': reviewCount,
      'menuItems': menuItems
          .map(
            (item) => {
              'name': item.name,
              'price': item.price,
            },
          )
          .toList(),
      'reviews': reviews
          .map(
            (review) => review.toMap(),
          )
          .toList(),
    };
  }

  double get averageRating {
    if (reviews.isEmpty) {
      return rating;
    }

    final total = reviews.fold<double>(
      0,
      (sum, review) => sum + review.rating,
    );

    return total / reviews.length;
  }

  int get minPrice {
    if (menuItems.isEmpty) {
      return 0;
    }

    return menuItems.map((item) => item.price).reduce(
          (a, b) => a < b ? a : b,
        );
  }

  int get maxPrice {
    if (menuItems.isEmpty) {
      return 0;
    }

    return menuItems.map((item) => item.price).reduce(
          (a, b) => a > b ? a : b,
        );
  }

  FoodPlace copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    String? priceCategory,
    String? priceRange,
    List<String>? imageUrls,
    List<MenuItem>? menuItems,
    List<String>? facilities,
    List<Review>? reviews,
    double? rating,
    int? reviewCount,
  }) {
    return FoodPlace(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      priceCategory: priceCategory ?? this.priceCategory,
      priceRange: priceRange ?? this.priceRange,
      imageUrls: imageUrls ?? this.imageUrls,
      menuItems: menuItems ?? this.menuItems,
      facilities: facilities ?? this.facilities,
      reviews: reviews ?? this.reviews,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}

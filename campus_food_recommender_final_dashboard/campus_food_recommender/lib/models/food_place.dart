import 'menu_item.dart';
import 'review.dart';

class FoodPlace {
  FoodPlace({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.priceCategory,
    required this.priceRange,
    required this.imageUrls,
    required this.menuItems,
    required this.facilities,
    required this.reviews,
  });

  final String id;
  String name;
  String description;
  String location;
  String priceCategory;
  String priceRange;
  List<String> imageUrls;
  List<MenuItem> menuItems;
  List<String> facilities;
  List<Review> reviews;

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }

  int get minPrice {
    if (menuItems.isEmpty) return 0;
    return menuItems.map((item) => item.price).reduce((a, b) => a < b ? a : b);
  }

  int get maxPrice {
    if (menuItems.isEmpty) return 0;
    return menuItems.map((item) => item.price).reduce((a, b) => a > b ? a : b);
  }
}

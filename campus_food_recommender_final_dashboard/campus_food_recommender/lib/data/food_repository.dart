import '../models/food_place.dart';
import '../models/menu_item.dart';
import '../models/review.dart';

enum SortFilter { recommended, highestRating, cheapest, expensive }

class FoodRepository {
  FoodRepository._();

  static final FoodRepository instance = FoodRepository._();

  final List<FoodPlace> _places = [
    FoodPlace(
      id: '1',
      name: 'Kantin Harmoni Kampus',
      description: 'Tempat makan favorit mahasiswa dengan menu rumahan, harga terjangkau, dan area duduk luas untuk diskusi kelompok.',
      location: 'Dekat Gedung Fakultas Informatika',
      priceCategory: 'Murah',
      priceRange: 'Rp8.000 - Rp22.000',
      imageUrls: ['kantin', 'nasi', 'diskusi'],
      menuItems: const [
        MenuItem(name: 'Nasi Ayam Geprek', price: 15000),
        MenuItem(name: 'Mie Goreng Telur', price: 12000),
        MenuItem(name: 'Es Teh Manis', price: 5000),
      ],
      facilities: const ['WiFi', 'Stop kontak', 'Mushola dekat lokasi'],
      reviews: [
        Review(userName: 'Hanif', comment: 'Porsinya banyak dan cocok buat makan siang cepat.', rating: 4.5),
        Review(userName: 'Aldo', comment: 'Harga aman untuk mahasiswa.', rating: 4.2),
      ],
    ),
    FoodPlace(
      id: '2',
      name: 'Cafe Senja Tel-U',
      description: 'Cafe nyaman untuk mengerjakan tugas, rapat organisasi, atau nongkrong setelah kelas.',
      location: 'Area Gerbang Utama Kampus',
      priceCategory: 'Sedang',
      priceRange: 'Rp15.000 - Rp45.000',
      imageUrls: ['cafe', 'kopi', 'laptop'],
      menuItems: const [
        MenuItem(name: 'Kopi Susu Kampus', price: 18000),
        MenuItem(name: 'Rice Bowl Teriyaki', price: 28000),
        MenuItem(name: 'French Fries', price: 20000),
      ],
      facilities: const ['WiFi cepat', 'AC', 'Area indoor', 'Stop kontak'],
      reviews: [
        Review(userName: 'Kenzo', comment: 'Enak untuk nugas, cuma kadang ramai sore hari.', rating: 4.7),
        Review(userName: 'Faiz', comment: 'Kopinya oke dan tempatnya bersih.', rating: 4.6),
      ],
    ),
    FoodPlace(
      id: '3',
      name: 'Warung Sambal Nusantara',
      description: 'Pilihan makanan pedas dengan berbagai lauk dan sambal khas Indonesia.',
      location: 'Jalan Telekomunikasi No. 12',
      priceCategory: 'Murah',
      priceRange: 'Rp10.000 - Rp25.000',
      imageUrls: ['sambal', 'ayam', 'lalapan'],
      menuItems: const [
        MenuItem(name: 'Ayam Penyet Sambal Ijo', price: 17000),
        MenuItem(name: 'Lele Goreng', price: 16000),
        MenuItem(name: 'Nasi Tambah', price: 4000),
      ],
      facilities: const ['Parkir motor', 'Take away'],
      reviews: [
        Review(userName: 'Adinata', comment: 'Sambalnya mantap dan pedasnya pas.', rating: 4.3),
      ],
    ),
    FoodPlace(
      id: '4',
      name: 'Ruang Kopi Belajar',
      description: 'Cafe premium dengan suasana tenang, cocok untuk belajar mandiri dan meeting kecil.',
      location: 'Ruko Sebrang Kampus',
      priceCategory: 'Mahal',
      priceRange: 'Rp25.000 - Rp70.000',
      imageUrls: ['ruang', 'kopi', 'meeting'],
      menuItems: const [
        MenuItem(name: 'Manual Brew', price: 32000),
        MenuItem(name: 'Chicken Katsu Curry', price: 42000),
        MenuItem(name: 'Croissant', price: 28000),
      ],
      facilities: const ['WiFi cepat', 'AC', 'Meeting room', 'Pembayaran QRIS'],
      reviews: [
        Review(userName: 'Dina', comment: 'Tenang banget untuk fokus belajar.', rating: 4.8),
        Review(userName: 'Rafi', comment: 'Agak mahal, tapi fasilitasnya lengkap.', rating: 4.4),
      ],
    ),
  ];

  List<FoodPlace> getAllPlaces() => List.unmodifiable(_places);

  FoodPlace getById(String id) => _places.firstWhere((place) => place.id == id);

  List<FoodPlace> searchPlaces({String query = '', SortFilter filter = SortFilter.recommended, String priceCategory = 'Semua'}) {
    final normalized = query.toLowerCase().trim();
    var results = _places.where((place) {
      final matchesQuery = normalized.isEmpty ||
          place.name.toLowerCase().contains(normalized) ||
          place.location.toLowerCase().contains(normalized) ||
          place.description.toLowerCase().contains(normalized) ||
          place.menuItems.any((item) => item.name.toLowerCase().contains(normalized));
      final matchesPrice = priceCategory == 'Semua' || place.priceCategory == priceCategory;
      return matchesQuery && matchesPrice;
    }).toList();

    switch (filter) {
      case SortFilter.highestRating:
        results.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      case SortFilter.cheapest:
        results.sort((a, b) => a.minPrice.compareTo(b.minPrice));
      case SortFilter.expensive:
        results.sort((a, b) => b.maxPrice.compareTo(a.maxPrice));
      case SortFilter.recommended:
        results.sort((a, b) => b.reviews.length.compareTo(a.reviews.length));
    }
    return results;
  }

  void addReview(String placeId, Review review) {
    getById(placeId).reviews.insert(0, review);
  }

  void addPlace(FoodPlace place) {
    _places.insert(0, place);
  }

  void updatePlace(FoodPlace updatedPlace) {
    final index = _places.indexWhere((place) => place.id == updatedPlace.id);
    if (index != -1) _places[index] = updatedPlace;
  }

  void deletePlace(String id) {
    _places.removeWhere((place) => place.id == id);
  }
}

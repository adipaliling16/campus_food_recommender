import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/food_place.dart';
import '../models/review.dart';

class PlaceService {
  PlaceService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final CollectionReference<Map<String, dynamic>> _places =
      _db.collection('places');

  /// ============================
  /// GET ALL PLACES
  /// ============================
  static Stream<List<FoodPlace>> getPlaces() {
    return _places.snapshots().map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            return FoodPlace.fromFirestore(
              doc.id,
              doc.data(),
            );
          },
        ).toList();
      },
    );
  }

  /// ============================
  /// GET PLACE BY ID
  /// ============================
  static Stream<FoodPlace?> getPlaceById(
    String id,
  ) {
    return _places.doc(id).snapshots().map(
      (doc) {
        if (!doc.exists || doc.data() == null) {
          return null;
        }

        return FoodPlace.fromFirestore(
          doc.id,
          doc.data()!,
        );
      },
    );
  }

  /// ============================
  /// ADD PLACE
  /// ============================
  static Future<String> addPlace(
    FoodPlace place,
  ) async {
    final docRef = await _places.add(
      place.toFirestore(),
    );

    return docRef.id;
  }

  /// ============================
  /// UPDATE PLACE
  /// ============================
  static Future<void> updatePlace(
    String id,
    FoodPlace place,
  ) async {
    if (id.isEmpty) {
      throw Exception(
        'ID tempat tidak boleh kosong',
      );
    }

    await _places.doc(id).set(
          place.toFirestore(),
          SetOptions(
            merge: true,
          ),
        );
  }

  /// ============================
  /// DELETE PLACE
  /// ============================
  static Future<void> deletePlace(
    String id,
  ) async {
    if (id.isEmpty) {
      throw Exception(
        'ID tempat tidak valid',
      );
    }

    await _places.doc(id).delete();
  }

  /// ============================
  /// UPDATE RATING
  /// ============================
  static Future<void> updateRating({
    required String placeId,
    required double rating,
    required int reviewCount,
  }) async {
    await _places.doc(placeId).update({
      'rating': rating,
      'reviewCount': reviewCount,
    });
  }

  /// ============================
  /// ADD REVIEW
  /// ============================
  static Future<void> addReview(
    String placeId,
    Review review,
  ) async {
    final doc = await _places.doc(placeId).get();

    if (!doc.exists || doc.data() == null) {
      throw Exception(
        'Tempat tidak ditemukan',
      );
    }

    final place = FoodPlace.fromFirestore(
      doc.id,
      doc.data()!,
    );

    final reviews = [
      ...place.reviews,
      review,
    ];

    double averageRating = 0;

    if (reviews.isNotEmpty) {
      final total = reviews.fold<double>(
        0,
        (sum, item) => sum + item.rating,
      );

      averageRating = total / reviews.length;
    }

    await _places.doc(placeId).update({
      'reviews': reviews
          .map(
            (e) => e.toMap(),
          )
          .toList(),
      'rating': averageRating,
      'reviewCount': reviews.length,
    });
  }

  /// ============================
  /// SEARCH PLACE
  /// ============================
  static Stream<List<FoodPlace>> searchPlaces(
    String keyword,
  ) {
    return getPlaces().map(
      (places) {
        final query = keyword.toLowerCase().trim();

        if (query.isEmpty) {
          return places;
        }

        return places.where(
          (place) {
            return place.name.toLowerCase().contains(query) ||
                place.location.toLowerCase().contains(query) ||
                place.description.toLowerCase().contains(query);
          },
        ).toList();
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> addReview({
    required String placeId,
    required String userName,
    required String comment,
    required double rating,
  }) async {
    await _db.collection('places').doc(placeId).collection('reviews').add({
      'userName': userName,
      'comment': comment,
      'rating': rating,
      'createdAt': Timestamp.now(),
    });

    await updatePlaceRating(placeId);
  }

  static Future<void> updatePlaceRating(
    String placeId,
  ) async {
    final reviews =
        await _db.collection('places').doc(placeId).collection('reviews').get();

    if (reviews.docs.isEmpty) {
      await _db.collection('places').doc(placeId).update({
        'rating': 0,
        'reviewCount': 0,
      });

      return;
    }

    double total = 0;

    for (final doc in reviews.docs) {
      total += (doc['rating'] as num).toDouble();
    }

    final avg = total / reviews.docs.length;

    await _db.collection('places').doc(placeId).update({
      'rating': avg,
      'reviewCount': reviews.docs.length,
    });
  }
}

class Review {
  Review({
    required this.userName,
    required this.comment,
    required this.rating,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String userName;
  final String comment;
  final double rating;
  final DateTime createdAt;

  factory Review.fromMap(
    Map<String, dynamic> data,
  ) {
    return Review(
      userName: data['userName'] ?? '',
      comment: data['comment'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      createdAt: data['createdAt'] != null
          ? DateTime.parse(
              data['createdAt'],
            )
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'comment': comment,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Review {
  Review({required this.userName, required this.comment, required this.rating, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  final String userName;
  final String comment;
  final double rating;
  final DateTime createdAt;
}

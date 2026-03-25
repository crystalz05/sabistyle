import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String productId;
  final String userId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  final String? userName; 

  const Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    this.comment,
    this.createdAt,
    this.userName,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        userId,
        rating,
        comment,
        createdAt,
        userName,
      ];
}

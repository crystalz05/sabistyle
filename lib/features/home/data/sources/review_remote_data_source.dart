import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getProductReviews(String productId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final SupabaseClient _client;

  ReviewRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  @override
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    try {
      // Primary attempt: Fetch reviews with joined profiles
      // Using left join (default) - should return reviews even if profile is missing
      final response = await _client
          .from('reviews')
          .select('*, profiles:user_id(full_name)') // Explicitly link user_id to profiles if that's the relation
          .eq('product_id', productId)
          .order('created_at', ascending: false);
      
      if (response == null || (response as List).isEmpty) {
        // Double check with a totally raw query if first one is empty
        final rawResponse = await _client
            .from('reviews')
            .select()
            .eq('product_id', productId);
        
        if (rawResponse != null && (rawResponse as List).isNotEmpty) {
           return (rawResponse as List).map((json) => ReviewModel.fromJson(Map<String, dynamic>.from(json))).toList();
        }
      }

      return (response as List).map((json) {
        final reviewJson = Map<String, dynamic>.from(json);
        if (reviewJson['profiles'] != null) {
          reviewJson['full_name'] = reviewJson['profiles']['full_name'];
        }
        return ReviewModel.fromJson(reviewJson);
      }).toList();
    } catch (e) {
      // Fallback: Simplest possible query to rule out join errors
      final response = await _client
          .from('reviews')
          .select()
          .eq('product_id', productId);
      
      return (response as List).map((json) {
        return ReviewModel.fromJson(Map<String, dynamic>.from(json));
      }).toList();
    }
  }
}

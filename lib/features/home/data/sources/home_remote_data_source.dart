import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getNewArrivals({int limit = 10});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient _client;

  HomeRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .order('display_order', ascending: true);
    
    return (response as List).map((json) => CategoryModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    final response = await _client
        .from('products')
        .select()
        .eq('is_featured', true)
        .eq('is_active', true);
        
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> getNewArrivals({int limit = 10}) async {
    final response = await _client
        .from('products')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(limit);
        
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }
}

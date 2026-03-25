import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
  Future<ProductModel> getProductById(String productId);
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getNewArrivals();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final SupabaseClient _client;

  ProductRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    final response = await _client
        .from('products')
        .select()
        .eq('category_id', categoryId)
        .eq('is_active', true);
    
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<ProductModel> getProductById(String productId) async {
    final response = await _client
        .from('products')
        .select()
        .eq('id', productId)
        .single();
    
    return ProductModel.fromJson(response);
  }
  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    // Use the custom Postgres function that ranks name matches above description matches
    final response = await _client.rpc('search_products', params: {
      'search_term': query,
    });
    
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    final response = await _client
        .from('products')
        .select()
        .eq('is_active', true)
        .eq('is_featured', true);
    
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> getNewArrivals() async {
    final response = await _client
        .from('products')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(20);
    
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }
}

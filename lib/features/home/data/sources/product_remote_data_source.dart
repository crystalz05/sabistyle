import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProductsByCategory(
    String categoryId, {
    double? minPrice,
    double? maxPrice,
    SortByPrice sortByPrice = SortByPrice.none,
  });
  Future<ProductModel> getProductById(String productId);
  Future<List<ProductModel>> searchProducts(
    String query, {
    double? minPrice,
    double? maxPrice,
    SortByPrice sortByPrice = SortByPrice.none,
  });
  Future<List<ProductModel>> getFeaturedProducts({
    double? minPrice,
    double? maxPrice,
    SortByPrice sortByPrice = SortByPrice.none,
  });
  Future<List<ProductModel>> getNewArrivals({
    double? minPrice,
    double? maxPrice,
    SortByPrice sortByPrice = SortByPrice.none,
  });
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final SupabaseClient _client;

  ProductRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  @override
  Future<List<ProductModel>> getProductsByCategory(
    String categoryId, {
    double? minPrice,
    double? maxPrice,
    SortByPrice sortByPrice = SortByPrice.none,
  }) async {
    dynamic query = _client.from('products').select().eq('category_id', categoryId).eq(
      'is_active',
      true,
    );

    if (minPrice != null) query = query.gte('price', minPrice);
    if (maxPrice != null) query = query.lte('price', maxPrice);

    if (sortByPrice == SortByPrice.asc) {
      query = query.order('price', ascending: true);
    } else if (sortByPrice == SortByPrice.desc) {
      query = query.order('price', ascending: false);
    }

    final response = await query;
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<ProductModel> getProductById(String productId) async {
    final response = await _client.from('products').select().eq('id', productId).single();

    return ProductModel.fromJson(response);
  }

  @override
  Future<List<ProductModel>> searchProducts(
    String queryStr, {
    double? minPrice,
    double? maxPrice,
    SortByPrice sortByPrice = SortByPrice.none,
  }) async {
    dynamic query = _client.rpc('search_products', params: {
      'search_term': queryStr,
    });

    if (minPrice != null) query = query.gte('price', minPrice);
    if (maxPrice != null) query = query.lte('price', maxPrice);

    if (sortByPrice == SortByPrice.asc) {
      query = query.order('price', ascending: true);
    } else if (sortByPrice == SortByPrice.desc) {
      query = query.order('price', ascending: false);
    }

    final response = await query;
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts({
    double? minPrice,
    double? maxPrice,
    SortByPrice sortByPrice = SortByPrice.none,
  }) async {
    dynamic query = _client.from('products').select().eq('is_active', true).eq(
      'is_featured',
      true,
    );

    if (minPrice != null) query = query.gte('price', minPrice);
    if (maxPrice != null) query = query.lte('price', maxPrice);

    if (sortByPrice == SortByPrice.asc) {
      query = query.order('price', ascending: true);
    } else if (sortByPrice == SortByPrice.desc) {
      query = query.order('price', ascending: false);
    }

    final response = await query;
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> getNewArrivals({
    double? minPrice,
    double? maxPrice,
    SortByPrice sortByPrice = SortByPrice.none,
  }) async {
    dynamic query = _client.from('products').select().eq('is_active', true);

    if (minPrice != null) query = query.gte('price', minPrice);
    if (maxPrice != null) query = query.lte('price', maxPrice);

    if (sortByPrice == SortByPrice.asc) {
      query = query.order('price', ascending: true);
    } else if (sortByPrice == SortByPrice.desc) {
      query = query.order('price', ascending: false);
    } else {
      query = query.order('created_at', ascending: false);
    }

    final response = await query.limit(20);
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }
}

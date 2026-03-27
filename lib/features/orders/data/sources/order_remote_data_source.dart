import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/order.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<Order>> fetchOrders();
  Future<Order> fetchOrderDetail(String orderId);
  Future<void> cancelOrder(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final SupabaseClient _client;

  OrderRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<Order>> fetchOrders() async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*, product:products(name, images))')
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => OrderModel.fromJson(json)).toList();
  }

  @override
  Future<Order> fetchOrderDetail(String orderId) async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*, product:products(name, images))')
        .eq('id', orderId)
        .eq('user_id', _userId)
        .single();

    return OrderModel.fromJson(response);
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await _client
        .from('orders')
        .update({'status': 'cancelled'})
        .eq('id', orderId)
        .eq('user_id', _userId)
        .neq('status', 'shipped')
        .neq('status', 'delivered')
        .neq('status', 'cancelled');
  }
}

import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> fetchOrders();
  Future<Order> fetchOrderDetail(String orderId);
  Future<void> cancelOrder(String orderId);
}

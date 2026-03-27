import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../sources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _dataSource;

  OrderRepositoryImpl({required OrderRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<List<Order>> fetchOrders() => _dataSource.fetchOrders();

  @override
  Future<Order> fetchOrderDetail(String orderId) =>
      _dataSource.fetchOrderDetail(orderId);

  @override
  Future<void> cancelOrder(String orderId) => _dataSource.cancelOrder(orderId);
}

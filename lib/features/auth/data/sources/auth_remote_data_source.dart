import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel> login(String email, String password) async {
    // Simulated API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (email == "test@example.com" && password == "password") {
      return const UserModel(
        id: "1",
        email: "test@example.com",
        name: "Test User",
      );
    } else {
      throw const ServerFailure("Invalid credentials");
    }
  }
}

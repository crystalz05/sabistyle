import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure("An unexpected error occurred"));
    }
  }

  @override
  Future<Either<Failure, User?>> getAuthenticatedUser() async {
    // Simulating checking against local storage if needed
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return const Right(null);
  }
}

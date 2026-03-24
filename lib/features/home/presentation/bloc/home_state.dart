import 'package:equatable/equatable.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Category> categories;
  final List<Product> featuredProducts;
  final List<Product> newArrivals;

  const HomeLoaded({
    required this.categories,
    required this.featuredProducts,
    required this.newArrivals,
  });

  @override
  List<Object?> get props => [categories, featuredProducts, newArrivals];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

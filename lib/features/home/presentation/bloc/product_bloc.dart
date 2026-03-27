import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

// Events
abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class FetchProductsByCategory extends ProductEvent {
  final String categoryId;
  final double? minPrice;
  final double? maxPrice;
  final SortByPrice sortByPrice;

  const FetchProductsByCategory(
    this.categoryId, {
    this.minPrice,
    this.maxPrice,
    this.sortByPrice = SortByPrice.none,
  });

  @override
  List<Object?> get props => [categoryId, minPrice, maxPrice, sortByPrice];
}

class FetchProductDetail extends ProductEvent {
  final String productId;
  const FetchProductDetail(this.productId);
  @override
  List<Object?> get props => [productId];
}

class FetchFeaturedProducts extends ProductEvent {
  final double? minPrice;
  final double? maxPrice;
  final SortByPrice sortByPrice;

  const FetchFeaturedProducts({
    this.minPrice,
    this.maxPrice,
    this.sortByPrice = SortByPrice.none,
  });

  @override
  List<Object?> get props => [minPrice, maxPrice, sortByPrice];
}

class FetchNewArrivals extends ProductEvent {
  final double? minPrice;
  final double? maxPrice;
  final SortByPrice sortByPrice;

  const FetchNewArrivals({
    this.minPrice,
    this.maxPrice,
    this.sortByPrice = SortByPrice.none,
  });

  @override
  List<Object?> get props => [minPrice, maxPrice, sortByPrice];
}

// States
abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}
class ProductLoading extends ProductState {}
class ProductsLoaded extends ProductState {
  final List<Product> products;
  const ProductsLoaded(this.products);
  @override
  List<Object?> get props => [products];
}
class ProductDetailLoaded extends ProductState {
  final Product product;
  const ProductDetailLoaded(this.product);
  @override
  List<Object?> get props => [product];
}
class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _repository;

  ProductBloc({required ProductRepository repository})
      : _repository = repository,
        super(ProductInitial()) {
    on<FetchProductsByCategory>(_onFetchProductsByCategory);
    on<FetchProductDetail>(_onFetchProductDetail);
    on<FetchFeaturedProducts>(_onFetchFeaturedProducts);
    on<FetchNewArrivals>(_onFetchNewArrivals);
  }

  Future<void> _onFetchProductsByCategory(
    FetchProductsByCategory event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final products = await _repository.getProductsByCategory(
        event.categoryId,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        sortByPrice: event.sortByPrice,
      );
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onFetchFeaturedProducts(
    FetchFeaturedProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final products = await _repository.getFeaturedProducts(
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        sortByPrice: event.sortByPrice,
      );
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onFetchNewArrivals(
    FetchNewArrivals event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final products = await _repository.getNewArrivals(
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        sortByPrice: event.sortByPrice,
      );
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onFetchProductDetail(
    FetchProductDetail event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final product = await _repository.getProductById(event.productId);
      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}

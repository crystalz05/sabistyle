import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _repository;

  HomeBloc({required HomeRepository repository})
      : _repository = repository,
        super(HomeInitial()) {
    on<FetchHomeData>(_onFetchHomeData);
  }

  Future<void> _onFetchHomeData(
    FetchHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      // Execute all fetches in parallel to minimize load time
      final results = await Future.wait([
        _repository.getCategories(),
        _repository.getFeaturedProducts(),
        _repository.getNewArrivals(limit: 10),
      ]);

      emit(HomeLoaded(
        categories: results[0] as List<Category>,
        featuredProducts: results[1] as List<Product>,
        newArrivals: results[2] as List<Product>,
      ));
    } catch (e) {
      // Since exceptions are mapped to AppException by the repository logic
      emit(HomeError(e.toString()));
    }
  }
}

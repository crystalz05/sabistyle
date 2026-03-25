import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

// Events
abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class LoadSearchHistory extends SearchEvent {}

class AddToSearchHistory extends SearchEvent {
  final String query;
  const AddToSearchHistory(this.query);
  @override
  List<Object?> get props => [query];
}

class ClearSearch extends SearchEvent {}

// States
abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  final List<String> history;
  const SearchInitial({this.history = const []});
  @override
  List<Object?> get props => [history];
}

class SearchLoading extends SearchState {}

class SearchResultsLoaded extends SearchState {
  final List<Product> results;
  const SearchResultsLoaded(this.results);
  @override
  List<Object?> get props => [results];
}

class SearchEmpty extends SearchState {}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ProductRepository _repository;

  SearchBloc({required ProductRepository repository})
      : _repository = repository,
        super(const SearchInitial()) {
    on<LoadSearchHistory>(_onLoadSearchHistory);
    on<AddToSearchHistory>(_onAddToSearchHistory);
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 400))
          .switchMap(mapper),
    );
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadSearchHistory(
    LoadSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final history = await _repository.getSearchHistory();
      emit(SearchInitial(history: history));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onAddToSearchHistory(
    AddToSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _repository.saveSearchQuery(event.query);
      final history = await _repository.getSearchHistory();
      emit(SearchInitial(history: history));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      // Load history inline instead of dispatching a nested event
      try {
        final history = await _repository.getSearchHistory();
        emit(SearchInitial(history: history));
      } catch (e) {
        emit(SearchInitial());
      }
      return;
    }

    if (event.query.trim().length < 2) return; // don't search single characters

    emit(SearchLoading());
    try {
      final results = await _repository.searchProducts(event.query);
      if (results.isEmpty) {
        emit(SearchEmpty());
      } else {
        // Save history on successful search
        await _repository.saveSearchQuery(event.query);
        emit(SearchResultsLoaded(results));
      }
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onClearSearch(ClearSearch event, Emitter<SearchState> emit) async {
    try {
      final history = await _repository.getSearchHistory();
      emit(SearchInitial(history: history));
    } catch (e) {
      emit(SearchInitial());
    }
  }
}

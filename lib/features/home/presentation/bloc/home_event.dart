import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches all data needed for the home screen in parallel:
/// 1. Categories
/// 2. Featured Products
/// 3. New Arrivals
class FetchHomeData extends HomeEvent {}

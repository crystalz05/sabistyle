import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class AddressEvent extends Equatable {
  const AddressEvent();
  @override
  List<Object?> get props => [];
}

class FetchAddresses extends AddressEvent {}

class AddAddress extends AddressEvent {
  final Address address;
  const AddAddress(this.address);
  @override
  List<Object?> get props => [address];
}

class UpdateAddress extends AddressEvent {
  final Address address;
  const UpdateAddress(this.address);
  @override
  List<Object?> get props => [address];
}

class DeleteAddress extends AddressEvent {
  final String addressId;
  const DeleteAddress(this.addressId);
  @override
  List<Object?> get props => [addressId];
}

class SetDefaultAddress extends AddressEvent {
  final String addressId;
  const SetDefaultAddress(this.addressId);
  @override
  List<Object?> get props => [addressId];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class AddressState extends Equatable {
  const AddressState();
  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressesLoaded extends AddressState {
  final List<Address> addresses;
  const AddressesLoaded(this.addresses);
  @override
  List<Object?> get props => [addresses];
}

class AddressError extends AddressState {
  final String message;
  const AddressError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository _repository;

  AddressBloc({required AddressRepository repository})
    : _repository = repository,
      super(AddressInitial()) {
    on<FetchAddresses>(_onFetchAddresses);
    on<AddAddress>(_onAddAddress);
    on<UpdateAddress>(_onUpdateAddress);
    on<DeleteAddress>(_onDeleteAddress);
    on<SetDefaultAddress>(_onSetDefaultAddress);
  }

  Future<void> _onFetchAddresses(
    FetchAddresses event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      final addresses = await _repository.fetchAddresses();
      emit(AddressesLoaded(addresses));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onAddAddress(
    AddAddress event,
    Emitter<AddressState> emit,
  ) async {
    try {
      await _repository.addAddress(event.address);
      add(FetchAddresses());
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onUpdateAddress(
    UpdateAddress event,
    Emitter<AddressState> emit,
  ) async {
    try {
      await _repository.updateAddress(event.address);
      add(FetchAddresses());
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onDeleteAddress(
    DeleteAddress event,
    Emitter<AddressState> emit,
  ) async {
    try {
      await _repository.deleteAddress(event.addressId);
      add(FetchAddresses());
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onSetDefaultAddress(
    SetDefaultAddress event,
    Emitter<AddressState> emit,
  ) async {
    try {
      await _repository.setDefault(event.addressId);
      add(FetchAddresses());
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }
}

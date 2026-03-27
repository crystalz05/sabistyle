import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/repositories/profile_repository.dart';

// ── Events ─────────────────────────────────────────────────────────────────────

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class FetchProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String fullName;
  final String? phone;

  const UpdateProfile({required this.fullName, this.phone});

  @override
  List<Object?> get props => [fullName, phone];
}

class UploadAvatar extends ProfileEvent {
  final String filePath;
  const UploadAvatar(this.filePath);
  @override
  List<Object?> get props => [filePath];
}

// ── States ─────────────────────────────────────────────────────────────────────

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final AppUser user;
  const ProfileLoaded(this.user);
  @override
  List<Object?> get props => [user];
}

/// Emitted during save/upload — the previous user data is preserved so the UI
/// can continue showing existing values while showing a loading indicator.
class ProfileUpdating extends ProfileState {
  final AppUser user;
  const ProfileUpdating(this.user);
  @override
  List<Object?> get props => [user];
}

class ProfileUpdated extends ProfileState {
  final AppUser user;
  const ProfileUpdated(this.user);
  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;
  final AppUser? previousUser;
  const ProfileError(this.message, {this.previousUser});
  @override
  List<Object?> get props => [message, previousUser];
}

// ── Bloc ───────────────────────────────────────────────────────────────────────

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc({required ProfileRepository repository})
      : _repository = repository,
        super(ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadAvatar>(_onUploadAvatar);
  }

  Future<void> _onFetchProfile(
    FetchProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await _repository.fetchProfile();
      emit(ProfileLoaded(user));
    } on AppException catch (e) {
      emit(ProfileError(e.message));
    } catch (_) {
      emit(const ProfileError('Could not load profile. Please try again.'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state is ProfileLoaded
        ? (state as ProfileLoaded).user
        : state is ProfileUpdated
            ? (state as ProfileUpdated).user
            : null;

    if (current != null) emit(ProfileUpdating(current));

    try {
      final updated = await _repository.updateProfile(
        fullName: event.fullName,
        phone: event.phone,
      );
      emit(ProfileUpdated(updated));
    } on AppException catch (e) {
      emit(ProfileError(e.message, previousUser: current));
    } catch (_) {
      emit(ProfileError(
        'Could not update profile. Please try again.',
        previousUser: current,
      ));
    }
  }

  Future<void> _onUploadAvatar(
    UploadAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state is ProfileLoaded
        ? (state as ProfileLoaded).user
        : state is ProfileUpdated
            ? (state as ProfileUpdated).user
            : null;

    if (current != null) emit(ProfileUpdating(current));

    try {
      final updated = await _repository.uploadAvatar(event.filePath);
      emit(ProfileUpdated(updated));
    } on AppException catch (e) {
      emit(ProfileError(e.message, previousUser: current));
    } catch (_) {
      emit(ProfileError(
        'Could not upload photo. Please try again.',
        previousUser: current,
      ));
    }
  }
}

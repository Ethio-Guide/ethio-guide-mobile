import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/update_password.dart';
import '../../domain/usecases/update_profile.dart';
 
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfile getUserProfile;
  final LogoutUser logoutUser;
  final UpdatePassword updatePassword;
  final UpdateProfile updateProfile;

  ProfileBloc({
    required this.getUserProfile,
    required this.logoutUser,
    required this.updatePassword,
    required this.updateProfile,
  }) : super(const ProfileState()) {
    on<FetchProfileData>(_onFetchProfileData);
    on<LogoutTapped>(_onLogoutTapped);
    on<PasswordUpdateSubmitted>(_onPasswordUpdateSubmitted);
     on<PasswordVisibilityToggled>(_onPasswordVisibilityToggled); 
     on<EditModeToggled>(_onEditModeToggled);
  on<EditModeCancelled>(_onEditModeCancelled);
  on<ProfileSaveChanges>(_onProfileSaveChanges);
  }

  Future<void> _onFetchProfileData(FetchProfileData event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await getUserProfile();
    result.fold(
      (failure) => emit(state.copyWith(status: ProfileStatus.failure, errorMessage: failure.message)),
      (user) => emit(state.copyWith(status: ProfileStatus.success, user: user)),
    );
  }

  Future<void> _onLogoutTapped(LogoutTapped event, Emitter<ProfileState> emit) async {
    // We don't need a loading state for logout as it's very fast.
    final result = await logoutUser();
    result.fold(
      (failure) => emit(state.copyWith(status: ProfileStatus.failure, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: ProfileStatus.loggedOut)),
    );
  }

   Future<void> _onPasswordUpdateSubmitted(
    PasswordUpdateSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    // 1. Tell the UI we are loading
    emit(state.copyWith(status: ProfileStatus.loading));
    
    // 2. Call the use case with the parameters from the event
    final result = await updatePassword(UpdatePasswordParams(
      oldPassword: event.oldPassword,
      newPassword: event.newPassword,
    ));
    
    // 3. Handle the result
    result.fold(
      // On failure, tell the UI there was an error
      (failure) => emit(state.copyWith(status: ProfileStatus.failure, errorMessage: failure.message)),
      // On success, tell the UI the password was updated successfully
      (_) => emit(state.copyWith(status: ProfileStatus.passwordUpdateSuccess)),
    );
  }
   void _onPasswordVisibilityToggled(
    PasswordVisibilityToggled event,
    Emitter<ProfileState> emit,
  ) {
    // This simply emits a new state with the boolean value flipped.
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }
  void _onEditModeToggled(EditModeToggled event, Emitter<ProfileState> emit) {
  emit(state.copyWith(isEditing: true));
}

void _onEditModeCancelled(EditModeCancelled event, Emitter<ProfileState> emit) {
   emit(state.copyWith(isEditing: false, status: ProfileStatus.success, errorMessage: ''));
}

Future<void> _onProfileSaveChanges(ProfileSaveChanges event, Emitter<ProfileState> emit) async {
  emit(state.copyWith(status: ProfileStatus.loading));
  final result = await updateProfile(UpdateProfileParams(
    name: event.name,
    email: event.email,
    username: event.username,
  ));
  result.fold(
    (failure) => emit(state.copyWith(status: ProfileStatus.failure, errorMessage: failure.message)),
    // On success, update the user and exit edit mode
    (updatedUser) => emit(state.copyWith(status: ProfileStatus.success, user: updatedUser, isEditing: false)),
  );
}
}


import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object> get props => [];
}

// Event to tell the BLoC to fetch the user's profile data.
class FetchProfileData extends ProfileEvent {}

// Event to tell the BLoC that the user has tapped the logout button.
class LogoutTapped extends ProfileEvent {}

class PasswordUpdateSubmitted extends ProfileEvent {
  final String oldPassword;
  final String newPassword;

  const PasswordUpdateSubmitted({required this.oldPassword, required this.newPassword});
}

class PasswordVisibilityToggled extends ProfileEvent {}
class EditModeToggled extends ProfileEvent {}

// Event to cancel editing
class EditModeCancelled extends ProfileEvent {}

// Event to save the changes (this replaces ProfileUpdateSubmitted)
class ProfileSaveChanges extends ProfileEvent {
  final String name;
  final String email;
  final String username;
  const ProfileSaveChanges({required this.name, required this.email, required this.username});
}
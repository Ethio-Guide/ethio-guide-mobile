import 'package:equatable/equatable.dart';
import 'package:ethioguide/features/authentication/domain/entities/user.dart';

enum ProfileStatus { initial, loading, success, failure, loggedOut, passwordUpdateSuccess }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final User? user;
  final String errorMessage;
   final bool isPasswordVisible;
    final bool isEditing;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.errorMessage = '',
    this.isPasswordVisible = false,
     this.isEditing = false,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    User? user,
    String? errorMessage,
    bool? isPasswordVisible,
    bool? isEditing,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
       isEditing: isEditing ?? this.isEditing,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, isPasswordVisible, isEditing];
}
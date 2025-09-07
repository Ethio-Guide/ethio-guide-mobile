import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:ethioguide/core/error/failures.dart';
import 'package:ethioguide/features/authentication/domain/entities/user.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;
  UpdateProfile(this.repository);

  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      name: params.name,
      email: params.email,
      username: params.username,
      profilePicURL: params.profilePicURL,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String? name;
  final String? email;
  final String? username;
  final String? profilePicURL;

  const UpdateProfileParams({
    this.name,
    this.email,
    this.username,
    this.profilePicURL,
  });
  
  @override
  List<Object?> get props => [name, email, username, profilePicURL];
}
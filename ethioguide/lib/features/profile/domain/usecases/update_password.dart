import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:ethioguide/core/error/failures.dart';
import '../repositories/profile_repository.dart';

class UpdatePassword {
  final ProfileRepository repository;
  UpdatePassword(this.repository);

  Future<Either<Failure, void>> call(UpdatePasswordParams params) async {
    return await repository.updatePassword(
      oldPassword: params.oldPassword,
      newPassword: params.newPassword,
    );
  }
}

class UpdatePasswordParams extends Equatable {
  final String oldPassword;
  final String newPassword;

  const UpdatePasswordParams({required this.oldPassword, required this.newPassword});
  
  @override
  List<Object?> get props => [oldPassword, newPassword];
}
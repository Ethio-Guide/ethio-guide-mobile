import 'package:dio/dio.dart';
import 'package:ethioguide/core/error/exception.dart';

import 'package:ethioguide/features/authentication/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getUserProfile();
  Future<void> updatePassword({required String oldPassword, required String newPassword});
   Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? username,
    String? profilePicURL,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;
  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> getUserProfile() async {
    try {
      // Your AuthInterceptor will automatically add the required Bearer token to this request.
      final response = await dio.get('/auth/me');
      
      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Failed to get profile', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Failed to get profile.';
      throw ServerException(message: errorMessage, statusCode: e.response?.statusCode);
    }
  }
    @override
  Future<void> updatePassword({required String oldPassword, required String newPassword}) async {
    try {
      // The Bearer token will be added automatically by your AuthInterceptor.
      final response = await dio.patch( // As per the API doc, this is a PATCH request.
        '/auth/me/password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
      
      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to update password', statusCode: response.statusCode);
      }
      // A successful update returns a 200 OK with no data, so we just return.
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Failed to update password.';
      throw ServerException(message: errorMessage, statusCode: e.response?.statusCode);
    }
  }
   @override
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? username,
    String? profilePicURL,
  }) async {
    try {
      // Build the request body, only including fields that are not null.
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (profilePicURL != null) data['profilePicURL'] = profilePicURL;
      if (username != null) {
        data['userDetail'] = {'username': username};
      }

      final response = await dio.patch(
        '/auth/me', // The endpoint for updating the profile
        data: data,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        // The API returns the updated user object.
        return UserModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Failed to update profile', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Failed to update profile.';
      throw ServerException(message: errorMessage, statusCode: e.response?.statusCode);
    }
  }
}

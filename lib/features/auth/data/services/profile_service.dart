import 'dart:io';

import 'package:dio/dio.dart';
import 'package:trash2cash/core/constants/api_constants.dart';
import 'package:trash2cash/core/constants/api_exceptions.dart';
import 'package:trash2cash/core/constants/dio_client.dart';
import 'package:trash2cash/core/network/network_info.dart';
import 'package:trash2cash/features/auth/data/model/user_model.dart';

class ProfileService {
  final DioClient dioClient;
  final NetworkInfo networkInfo;

  ProfileService({
    required this.dioClient,
    required this.networkInfo,
  });

  Future<UserModel> getProfile() async {
    if (!await networkInfo.isConnected) {
      throw ApiException.networkError('No internet');
    }

    final response = await dioClient.get(ApiConstants.profile);

    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data);
    }

    throw ApiException.serverError(
      response.statusCode ?? 500,
      'Failed to load profile',
    );
  }

  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    File? imageFile,
  }) async {
    final formData = FormData();

    if (firstName != null) {
      formData.fields.add(MapEntry('first_name', firstName));
    }
    if (lastName != null) {
      formData.fields.add(MapEntry('last_name', lastName));
    }
    if (imageFile != null) {
      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(imageFile.path),
        ),
      );
    }

    final response = await dioClient.dio.put(
      ApiConstants.profile,
      data: formData,
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data['user']);
    }

    throw ApiException.serverError(
      response.statusCode ?? 500,
      'Update failed',
    );
  }
}

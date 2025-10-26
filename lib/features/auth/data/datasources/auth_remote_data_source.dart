// lib/features/auth/data/datasources/auth_remote_data_source.dart
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
// Sửa lại đường dẫn cho đúng
import '../../../../core/errors/exceptions.dart';
import '../models/token_model.dart';

abstract class AuthRemoteDataSource {
  Future<TokenModel> loginWithGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GoogleSignIn googleSignIn;
  final http.Client client;

  // 1. ĐÃ XÓA BIẾN googleWebClientId VÌ NÓ ĐÃ ĐƯỢC CHUYỂN SANG MAIN.DART

  AuthRemoteDataSourceImpl({required this.googleSignIn, required this.client});

  @override
  Future<TokenModel> loginWithGoogle() async {
    try {
      // 2. ĐÃ SỬA HÀM SIGNIN()
      // Nó sẽ tự động dùng ID được cung cấp trong main.dart
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw GoogleSignInException('Google sign-in was cancelled by user.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw GoogleSignInException('Failed to get ID Token from Google.');
      }

      // 3. Gọi API Spring Boot của bạn
      const String url =
          'https://bookingstudioswd-be.onrender.com/auth/google/android-callback';
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      // 4. Xử lý kết quả
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('✅ Response Body từ Backend: $jsonResponse');
        print('✅ Token (JWT): ${jsonResponse["data"]}');
        return TokenModel.fromJson(jsonResponse);
      } else {
        throw ServerException(
          'Failed to login. Status code: ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } on GoogleSignInException {
      rethrow;
    } catch (e) {
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }
}

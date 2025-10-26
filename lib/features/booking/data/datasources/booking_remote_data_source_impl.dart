// lib/features/booking/data/datasources/booking_remote_data_source_impl.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/exception.dart';
import '../models/booking_model.dart';
import 'booking_remote_data_source.dart';

const CACHED_TOKEN_KEY = 'CACHED_TOKEN';

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage secureStorage;
  final String _baseUrl = "https://bookingstudioswd-be.onrender.com";

  BookingRemoteDataSourceImpl({
    required this.client,
    required this.secureStorage,
  });

  Future<String> _getJwt() async {
    final jsonString = await secureStorage.read(key: CACHED_TOKEN_KEY);
    if (jsonString == null) {
      print('[BookingDataSource] No cached token');
      throw NetworkException();
    }
    final map = json.decode(jsonString);
    final raw = map['data'] ?? map['jwt'];
    if (raw is String && raw.isNotEmpty) return raw;
    print('[BookingDataSource] Invalid cached token structure: $map');
    throw ServerException();
  }

  @override
  Future<List<BookingModel>> getBookings() async {
    final url = Uri.parse('$_baseUrl/api/staff/bookings');
    print('[BookingDataSource] GET: $url');

    try {
      final jwt = await _getJwt();
      final headers = <String, String>{
        'Accept': 'application/json',
        'Authorization': 'Bearer $jwt', // ✅ Bearer
      };

      final response = await client.get(url, headers: headers);
      print('[BookingDataSource] Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('[BookingDataSource] ERROR body: ${response.body}');
        throw ServerException();
      }

      // ✅ JSON guard (tránh parse HTML Swagger)
      final contentType = (response.headers['content-type'] ?? '').toLowerCase();
      final bodyStart = response.body.trimLeft();
      final looksLikeHtml = bodyStart.startsWith('<!DOCTYPE') || bodyStart.startsWith('<html');
      if (!contentType.contains('application/json') || looksLikeHtml) {
        print('[BookingDataSource] Received HTML (Swagger) instead of JSON. Wrong endpoint or redirect.');
        throw ServerException();
      }

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final data = jsonResponse['data'];
      if (data is! List) {
        print('[BookingDataSource] "data" is not a List. body=${response.body}');
        throw ServerException();
      }

      final bookings = data
          .map<BookingModel>((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();

      print('[BookingDataSource] Parsed ${bookings.length} bookings.');
      return bookings;
    } on SocketException catch (e) {
      print('[BookingDataSource] SocketException: $e');
      throw NetworkException();
    } on http.ClientException catch (e) {
      print('[BookingDataSource] ClientException: $e');
      throw NetworkException();
    } catch (e) {
      print('[BookingDataSource] Unknown error: $e');
      throw ServerException();
    }
  }
}

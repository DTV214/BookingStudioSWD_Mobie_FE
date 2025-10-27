import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/exception.dart';
import '../models/studio_assign_model.dart';
import '../models/addition_time_result_model.dart';
import 'studio_assign_remote_data_source.dart';

const _baseUrl = 'https://bookingstudioswd-be.onrender.com';
const _cachedTokenKey = 'CACHED_TOKEN';

class StudioAssignRemoteDataSourceImpl implements StudioAssignRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  StudioAssignRemoteDataSourceImpl({
    required this.client,
    required this.secureStorage,
  });

  Future<String> _getJwt() async {
    final jsonString = await secureStorage.read(key: _cachedTokenKey);
    if (jsonString == null) throw NetworkException();
    final map = json.decode(jsonString);
    final raw = map['data'] ?? map['jwt'];
    if (raw is String && raw.isNotEmpty) return raw;
    throw ServerException();
  }

  @override
  Future<List<StudioAssignModel>> getByBookingId(String bookingId) async {
    final jwt = await _getJwt();
    final url = Uri.parse('$_baseUrl/api/studio-assigns/booking/$bookingId');

    final resp = await client.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $jwt',
    });

    if (resp.statusCode != 200) throw ServerException();

    final contentType = (resp.headers['content-type'] ?? '').toLowerCase();
    final bodyStart = resp.body.trimLeft();
    final looksLikeHtml = bodyStart.startsWith('<!DOCTYPE') || bodyStart.startsWith('<html');
    if (!contentType.contains('application/json') || looksLikeHtml) throw ServerException();

    final Map<String, dynamic> jsonResponse = json.decode(resp.body);
    final data = jsonResponse['data'];
    if (data is! List) throw ServerException();

    return data
        .map<StudioAssignModel>((e) => StudioAssignModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> setStatus({required String assignId, required String status}) async {
    final jwt = await _getJwt();
    final url = Uri.parse('$_baseUrl/api/studio-assigns/status/$assignId');
    final body = json.encode({'status': status});

    final resp = await client.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: body,
    );

    if (resp.statusCode != 200) throw ServerException();
  }

  @override
  Future<AdditionTimeResultModel> addAdditionTime({
    required String assignId,
    required int additionMinutes,
  }) async {
    final jwt = await _getJwt();
    final url = Uri.parse('$_baseUrl/api/studio-assigns/$assignId/addition-time');

    // ✅ Dùng PATCH (không phải POST)
    final resp = await client.patch(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: json.encode({'additionMinutes': additionMinutes}),
    );

    // Chấp nhận 200/201 (BE nào chỉ trả 200 thì cũng ok)
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw ServerException();
    }

    final contentType = (resp.headers['content-type'] ?? '').toLowerCase();
    final bodyStart = resp.body.trimLeft();
    final looksLikeHtml = bodyStart.startsWith('<!DOCTYPE') || bodyStart.startsWith('<html');
    if (!contentType.contains('application/json') || looksLikeHtml) {
      throw ServerException();
    }

    final Map<String, dynamic> root = json.decode(resp.body);
    final data = root['data'];
    if (data is! Map<String, dynamic>) {
      throw ServerException();
    }

    return AdditionTimeResultModel.fromJson(data);
  }

}

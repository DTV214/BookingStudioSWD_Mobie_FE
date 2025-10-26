import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/exception.dart';
import '../models/service_assign_model.dart';
import 'service_assign_remote_data_source.dart';

const _baseUrl = 'https://bookingstudioswd-be.onrender.com';
const _tokenKey = 'CACHED_TOKEN';

class ServiceAssignRemoteDataSourceImpl implements ServiceAssignRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  ServiceAssignRemoteDataSourceImpl({
    required this.client,
    required this.secureStorage,
  });

  Future<String> _getJwt() async {
    final raw = await secureStorage.read(key: _tokenKey);
    if (raw == null) throw NetworkException();
    final map = json.decode(raw) as Map<String, dynamic>;
    final token = map['data'] ?? map['jwt'];
    if (token is String && token.isNotEmpty) return token;
    throw ServerException();
  }

  @override
  Future<List<ServiceAssignModel>> getByStudioAssignId(String studioAssignId) async {
    final jwt = await _getJwt();
    final url = Uri.parse('$_baseUrl/api/service-assigns/studio-assign/$studioAssignId');

    final resp = await client.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $jwt',
    });

    if (resp.statusCode != 200) throw ServerException();

    // tránh HTML swagger
    final ct = (resp.headers['content-type'] ?? '').toLowerCase();
    final bodyStart = resp.body.trimLeft();
    if (!ct.contains('application/json') ||
        bodyStart.startsWith('<!DOCTYPE') ||
        bodyStart.startsWith('<html')) {
      throw ServerException();
    }

    final map = json.decode(resp.body) as Map<String, dynamic>;
    final data = map['data'];
    if (data is! List) throw ServerException();

    return data
        .map<ServiceAssignModel>((e) => ServiceAssignModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

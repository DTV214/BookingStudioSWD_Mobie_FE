import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/exception.dart';
import '../models/payment_model.dart';
import '../models/final_payment_model.dart';
import 'payment_remote_data_source.dart';

const _baseUrl = 'https://bookingstudioswd-be.onrender.com';
const _cachedTokenKey = 'CACHED_TOKEN';

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  PaymentRemoteDataSourceImpl({
    required this.client,
    required this.secureStorage,
  });

  Future<String> _getJwt() async {
    final jsonString = await secureStorage.read(key: _cachedTokenKey);
    if (jsonString == null) {
      throw NetworkException();
    }
    final map = json.decode(jsonString) as Map<String, dynamic>;
    final raw = map['data'] ?? map['jwt'];
    if (raw is! String || raw.isEmpty) {
      throw ServerException();
    }
    return raw;
  }

  @override
  Future<List<PaymentModel>> getByBookingId(String bookingId) async {
    final jwt = await _getJwt();
    // GIỮ NGUYÊN endpoint hiện có của bạn:
    final url = Uri.parse('$_baseUrl/api/payments/staff/booking/$bookingId');

    final resp = await client.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $jwt',
    });

    if (resp.statusCode != 200) {
      throw ServerException();
    }

    final contentType = (resp.headers['content-type'] ?? '').toLowerCase();
    final bodyStart = resp.body.trimLeft();
    final looksLikeHtml =
        bodyStart.startsWith('<!DOCTYPE') || bodyStart.startsWith('<html');
    if (!contentType.contains('application/json') || looksLikeHtml) {
      throw ServerException();
    }

    final Map<String, dynamic> jsonResponse = json.decode(resp.body);
    final data = jsonResponse['data'];
    if (data is! List) {
      throw ServerException();
    }

    return data
        .map<PaymentModel>(
            (e) => PaymentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FinalPaymentModel> createFinalPayment({
    required String bookingId,
    required String paymentMethod,
  }) async {
    final jwt = await _getJwt();
    // THEO YÊU CẦU: /api/payments/booking/{bookingId}/final
    final url = Uri.parse('$_baseUrl/api/payments/booking/$bookingId/final');

    final resp = await client.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: json.encode({
        'paymentMethod': paymentMethod, // 'VNPAY' | 'MOMO' | 'CASH'
      }),
    );

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw ServerException();
    }

    final contentType = (resp.headers['content-type'] ?? '').toLowerCase();
    final bodyStart = resp.body.trimLeft();
    final looksLikeHtml =
        bodyStart.startsWith('<!DOCTYPE') || bodyStart.startsWith('<html');
    if (!contentType.contains('application/json') || looksLikeHtml) {
      throw ServerException();
    }

    final Map<String, dynamic> jsonResponse = json.decode(resp.body);
    final data = jsonResponse['data'];
    if (data is! Map<String, dynamic>) {
      throw ServerException();
    }

    return FinalPaymentModel.fromJson(data);
  }
}

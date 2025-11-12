// lib/features/booking/presentation/widgets/payment_status_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/payment.dart';

const _baseUrl = 'https://bookingstudioswd-be.onrender.com';
const _cachedTokenKey = 'CACHED_TOKEN';

class PaymentStatusPage extends StatefulWidget {
  final Payment payment;

  const PaymentStatusPage({super.key, required this.payment});

  @override
  State<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage> {
  final _statuses = const ['PENDING', 'SUCCESS', 'FAILED'];
  late String _selectedStatus;
  bool _loading = false;
  String? _errorDetail;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.payment.status.toUpperCase();
    if (!_statuses.contains(_selectedStatus)) {
      _selectedStatus = 'PENDING';
    }
  }

  // ===================== API helpers =====================
  Future<String> _getJwt() async {
    final storage = const FlutterSecureStorage();
    final jsonString = await storage.read(key: _cachedTokenKey);
    if (jsonString == null) throw Exception('No cached token');
    final map = json.decode(jsonString) as Map<String, dynamic>;
    final raw = map['data'] ?? map['jwt'];
    if (raw is! String || raw.isEmpty) throw Exception('Invalid token');
    return raw;
  }

  bool _isSuccess(http.Response resp) {
    if (resp.statusCode >= 200 && resp.statusCode < 300) return true;
    if (resp.statusCode == 204) return true;
    return false;
  }

  String _clipBody(String body, [int max = 200]) {
    final s = body.trim();
    if (s.length <= max) return s;
    return '${s.substring(0, max)}...';
  }

  Future<void> _updateStatus() async {
    setState(() {
      _loading = true;
      _errorDetail = null;
    });

    try {
      final jwt = await _getJwt();
      final id = widget.payment.id;
      final newStatus = _selectedStatus;

      final candidates = <Future<http.Response> Function()>[
        // Staff endpoints
            () => http.patch(
          Uri.parse('$_baseUrl/api/payments/staff/$id/status'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
          body: jsonEncode({'status': newStatus}),
        ),
            () => http.put(
          Uri.parse('$_baseUrl/api/payments/staff/$id/status'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
          body: jsonEncode({'status': newStatus}),
        ),
        // Generic endpoints
            () => http.patch(
          Uri.parse('$_baseUrl/api/payments/$id/status'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
          body: jsonEncode({'status': newStatus}),
        ),
            () => http.put(
          Uri.parse('$_baseUrl/api/payments/$id/status'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
          body: jsonEncode({'status': newStatus}),
        ),
        // POST fallback
            () => http.post(
          Uri.parse('$_baseUrl/api/payments/staff/update-status'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
          body: jsonEncode({'paymentId': id, 'status': newStatus}),
        ),
            () => http.post(
          Uri.parse('$_baseUrl/api/payments/update-status'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
          body: jsonEncode({'id': id, 'status': newStatus}),
        ),
        // Key variations
            () => http.patch(
          Uri.parse('$_baseUrl/api/payments/staff/$id/status'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
          body: jsonEncode({'paymentStatus': newStatus}),
        ),
            () => http.put(
          Uri.parse('$_baseUrl/api/payments/staff/$id/status'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
          body: jsonEncode({'paymentStatus': newStatus}),
        ),
        // Query string
            () => http.patch(
          Uri.parse('$_baseUrl/api/payments/staff/$id/status?status=$newStatus'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
        ),
            () => http.put(
          Uri.parse('$_baseUrl/api/payments/staff/$id/status?status=$newStatus'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
        ),
      ];

      http.Response? lastResp;
      for (final call in candidates) {
        try {
          final resp = await call();
          lastResp = resp;
          if (_isSuccess(resp)) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cập nhật trạng thái thành công.')),
            );
            Navigator.of(context).pop(true);
            return;
          }
        } catch (_) {
          lastResp = null; // thử candidate tiếp
        }
      }

      final code = lastResp?.statusCode.toString() ?? 'No Response';
      final body = lastResp?.body ?? '';
      setState(() {
        _errorDetail =
        'Update failed. HTTP $code\n${_clipBody(body)}\n\nGợi ý: kiểm tra lại route update-status trên BE.';
      });
    } catch (e) {
      setState(() {
        _errorDetail = 'Exception: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // ===================== UI helpers =====================
  String _money(int vnd) =>
      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(vnd);

  String _date(DateTime dt) =>
      DateFormat('dd/MM/yyyy HH:mm').format(dt);

  (Color, Color, String) _statusStyle(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return (Colors.green, Colors.green.withOpacity(.12), 'Thành công');
      case 'FAILED':
        return (Colors.red, Colors.red.withOpacity(.12), 'Thất bại');
      default:
        return (Colors.orange, Colors.orange.withOpacity(.12), 'Chờ xử lý');
    }
  }

  (IconData, String, Color, Color) _methodStyle(String methodRaw) {
    final m = methodRaw.toLowerCase().trim();
    switch (m) {
      case 'vnpay':
        return (Icons.account_balance_wallet_outlined, 'VNPay', Colors.blue.shade50, Colors.blue);
      case 'momo':
        return (Icons.phone_iphone, 'MoMo', Colors.pink.shade50, Colors.pink);
      case 'cash':
        return (Icons.payments_outlined, 'Tiền mặt', Colors.green.shade50, Colors.green);
      default:
        return (Icons.payment, methodRaw.toUpperCase(), Colors.grey.shade200, Colors.grey[800]!);
    }
  }

  Widget _badge(String text, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _statusSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _statuses.map((s) {
        final selected = _selectedStatus == s;
        final (fg, bg, label) = _statusStyle(s);
        return ChoiceChip(
          selected: selected,
          label: Text(s == 'PENDING' ? 'PENDING' : s),
          labelStyle: TextStyle(
            color: selected ? Colors.white : fg,
            fontWeight: FontWeight.w600,
          ),
          selectedColor: fg,
          backgroundColor: bg,
          onSelected: _loading ? null : (_) => setState(() => _selectedStatus = s),
        );
      }).toList(),
    );
  }

  // ===================== BUILD =====================
  @override
  Widget build(BuildContext context) {
    final p = widget.payment;
    final theme = Theme.of(context);
    final (statusFg, statusBg, statusLabel) = _statusStyle(p.status);
    final (icon, methodLabel, methodBg, methodFg) = _methodStyle(p.paymentMethod);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Cập nhật trạng thái thanh toán'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _loading ? null : _updateStatus,
            icon: _loading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_outlined),
            label: Text(_loading ? 'Đang cập nhật...' : 'Cập nhật trạng thái'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Summary card
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Method chip + amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(color: methodBg, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            Icon(icon, color: methodFg, size: 16),
                            const SizedBox(width: 8),
                            Text(methodLabel, style: TextStyle(color: methodFg, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      Text(
                        _money(p.amount),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ID + status badge
                  Row(
                    children: [
                      Expanded(
                        child: Text('Mã: ${p.id}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87)),
                      ),
                      const SizedBox(width: 12),
                      _badge(statusLabel, statusFg, statusBg),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ===== Details card
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long_outlined, color: Colors.black54),
                      const SizedBox(width: 8),
                      Text('Thông tin chi tiết', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24),
                  _infoRow('Booking', p.bookingId),
                  _infoRow('Loại', p.paymentType),
                  _infoRow('Thời gian', _date(p.paymentDate)),
                  _infoRow('Tài khoản', '${p.accountName} • ${p.accountEmail}'),
                  _infoRow('Booking status', p.bookingStatus.toUpperCase()),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ===== Update status card
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sync_alt_outlined, color: Colors.black54),
                      const SizedBox(width: 8),
                      Text('Cập nhật trạng thái', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text('Trạng thái mới', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _statusSelector(),
                  if (_errorDetail != null) ...[
                    const SizedBox(height: 16),
                    Text(_errorDetail!, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 80), // chừa khoảng dưới cho nút
        ],
      ),
    );
  }
}

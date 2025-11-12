// lib/features/booking/presentation/widgets/payment_status_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _statuses = const ['PENDING', 'SUCCESS', 'FAILED'];

  late String _selectedStatus;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.payment.status.toUpperCase();
  }

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'SUCCESS':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      case 'PENDING':
      default:
        return Colors.orange;
    }
  }

  String _statusLabelVi(String s) {
    switch (s.toUpperCase()) {
      case 'SUCCESS':
        return 'Thành công';
      case 'FAILED':
        return 'Thất bại';
      case 'PENDING':
      default:
        return 'Chờ xử lý';
    }
  }

  String _methodLabel(String m) {
    switch (m.toUpperCase()) {
      case 'MOMO':
        return 'MoMo';
      case 'VNPAY':
        return 'VNPay';
      case 'CASH':
        return 'Tiền mặt';
      default:
        return m.toUpperCase();
    }
  }

  Future<String> _getJwt() async {
    final storage = const FlutterSecureStorage();
    final jsonString = await storage.read(key: _cachedTokenKey);
    if (jsonString == null) {
      throw Exception('No cached token');
    }
    final map = json.decode(jsonString) as Map<String, dynamic>;
    final raw = map['data'] ?? map['jwt'];
    if (raw is! String || raw.isEmpty) {
      throw Exception('Invalid token');
    }
    return raw;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text(
          'Cập nhật trạng thái thanh toán thành "${_selectedStatus}"?\n'
              'Hành động này sẽ ảnh hưởng đến đơn: ${widget.payment.bookingId}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Đồng ý')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _submitting = true);
    try {
      final jwt = await _getJwt();
      final url = Uri.parse('$_baseUrl/api/payments/${widget.payment.id}/status');

      final resp = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: json.encode({'status': _selectedStatus}),
      );

      // Nếu backend dùng PUT thay vì POST, bạn có thể fallback tự động:
      if (resp.statusCode == 405) {
        final putResp = await http.put(
          url,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
          body: json.encode({'status': _selectedStatus}),
        );
        if (putResp.statusCode != 200 && putResp.statusCode != 204) {
          throw Exception('HTTP ${putResp.statusCode}');
        }
      } else if (resp.statusCode != 200 && resp.statusCode != 204) {
        throw Exception('HTTP ${resp.statusCode}');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật trạng thái thanh toán.')),
      );
      Navigator.pop(context, true); // báo về trang trước để reload
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.payment;
    final primary = const Color(0xFF6A40D3);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text('Cập nhật trạng thái thanh toán'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Payment info card
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _rowTile(
                      icon: Icons.receipt_long_outlined,
                      label: 'Mã thanh toán',
                      value: p.id,
                    ),
                    const SizedBox(height: 8),
                    _rowTile(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Phương thức',
                      value: _methodLabel(p.paymentMethod),
                    ),
                    const SizedBox(height: 8),
                    _rowTile(
                      icon: Icons.sell_outlined,
                      label: 'Số tiền',
                      value: NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(p.amount),
                      valueStyle: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    _rowTile(
                      icon: Icons.today_outlined,
                      label: 'Thời gian',
                      value: DateFormat('dd/MM/yyyy HH:mm').format(p.paymentDate),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.verified_outlined, color: Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        const Text('Trạng thái hiện tại', style: TextStyle(color: Colors.grey)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusColor(p.status).withOpacity(.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _statusLabelVi(p.status),
                            style: TextStyle(
                              color: _statusColor(p.status),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Update form card
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune_rounded, color: primary),
                          const SizedBox(width: 8),
                          Text(
                            'Chọn trạng thái mới',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        items: _statuses
                            .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text('$s  —  ${_statusLabelVi(s)}'),
                        ))
                            .toList(),
                        onChanged: _submitting ? null : (v) => setState(() => _selectedStatus = v ?? _selectedStatus),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          labelText: 'Trạng thái',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Quick actions
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _quickButton('PENDING', Icons.hourglass_bottom_outlined),
                          _quickButton('SUCCESS', Icons.check_circle_outline),
                          _quickButton('FAILED', Icons.cancel_outlined),
                        ],
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: _submitting
                              ? const SizedBox(
                              width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.save_outlined),
                          label: Text(_submitting ? 'Đang lưu...' : 'Lưu thay đổi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _submitting ? null : _submit,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _submitting ? null : () => Navigator.pop(context, false),
              icon: const Icon(Icons.arrow_back_ios_new, size: 16),
              label: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickButton(String status, IconData icon) {
    final active = _selectedStatus == status;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: active ? Colors.white : Colors.black54),
          const SizedBox(width: 6),
          Text(status, style: TextStyle(color: active ? Colors.white : Colors.black87)),
        ],
      ),
      selected: active,
      onSelected: _submitting ? null : (_) => setState(() => _selectedStatus = status),
      selectedColor: _statusColor(status),
      backgroundColor: Colors.grey.shade200,
      labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _rowTile({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

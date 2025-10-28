import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/usecases/get_payments_by_booking_usecase.dart';
import '../../presentation/providers/payment_provider.dart';

// Data layer local DI
import '../../data/datasources/payment_remote_data_source_impl.dart';
import '../../data/repositories/payment_repository_impl.dart';

class PaymentSection extends StatelessWidget {
  final String bookingId;

  const PaymentSection({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    // Local DI (tránh phụ thuộc main.dart)
    final remote = PaymentRemoteDataSourceImpl(
      client: http.Client(),
      secureStorage: const FlutterSecureStorage(),
    );
    final repo = PaymentRepositoryImpl(remote: remote);
    final usecase = GetPaymentsByBooking(repo);

    return ChangeNotifierProvider<PaymentProvider>(
      create: (_) => PaymentProvider(getUsecase: usecase)..fetch(bookingId),
      child: Consumer<PaymentProvider>(
        builder: (context, provider, _) {
          if (provider.state == PaymentState.loading ||
              provider.state == PaymentState.initial) {
            return _card(
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (provider.state == PaymentState.error) {
            return _card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(context, onRefresh: () {
                      provider.fetch(bookingId);
                    }),
                    const SizedBox(height: 12),
                    Text(
                      'Không tải được thanh toán: ${provider.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          }

          final payments = provider.payments;
          return _card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context, onRefresh: () {
                    provider.fetch(bookingId);
                  }),
                  const Divider(height: 24),
                  if (payments.isEmpty)
                    const Text('Chưa có thanh toán cho lịch đặt này.')
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: payments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final p = payments[index];

                        // Format
                        final amountStr = NumberFormat.currency(
                          locale: 'vi_VN',
                          symbol: 'đ',
                        ).format(p.amount);
                        final dateStr = DateFormat('dd/MM/yyyy HH:mm')
                            .format(p.paymentDate);

                        // Status badge
                        final (statusColor, statusBg, statusLabel) =
                        _statusStyle(p.status);

                        // Method chip + icon
                        final (methodIcon, methodLabel, methodBg, methodFg) =
                        _methodStyle(p.paymentMethod);

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: method chip + status badge
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: methodBg,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(methodIcon,
                                            size: 16, color: methodFg),
                                        const SizedBox(width: 6),
                                        Text(
                                          methodLabel,
                                          style: TextStyle(
                                            color: methodFg,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      statusLabel,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),
                              _row(Icons.category_outlined,
                                  'Loại thanh toán: ${p.paymentType}'),
                              const SizedBox(height: 6),
                              _row(Icons.access_time_outlined,
                                  'Thời gian: $dateStr'),
                              const SizedBox(height: 6),
                              _row(Icons.monetization_on_outlined,
                                  'Số tiền: $amountStr'),
                              const SizedBox(height: 6),
                              _row(Icons.person_outline,
                                  '${p.accountName} • ${p.accountEmail}'),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------ Helpers UI ------------
  static Widget _header(BuildContext context, {required VoidCallback onRefresh}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Danh sách Thanh toán",
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          tooltip: 'Tải lại',
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
        ),
      ],
    );
  }

  static Widget _card({required Widget child}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: child,
    );
  }

  static (Color, Color, String) _statusStyle(String status) {
    switch (status) {
      case 'PENDING':
        return (Colors.orange, Colors.orange.shade50, 'Chờ xử lý');
      case 'SUCCESS':
        return (Colors.green, Colors.green.shade50, 'Thành công');
      case 'FAILED':
        return (Colors.red, Colors.red.shade50, 'Thất bại');
      default:
        return (Colors.grey, Colors.grey.shade200, status);
    }
  }

  /// Trả về (icon, label, bgColor, fgColor) theo method từ API:
  ///  - VNPAY("vnpay"), MOMO("momo"), CASH("cash")
  static (IconData, String, Color, Color) _methodStyle(String methodRaw) {
    final m = (methodRaw).toLowerCase().trim();
    switch (m) {
      case 'vnpay':
        return (Icons.account_balance_wallet_outlined, 'VNPay',
        Colors.blue.shade50, Colors.blue);
      case 'momo':
        return (Icons.phone_iphone, 'MoMo',
        Colors.pink.shade50, Colors.pink);
      case 'cash':
        return (Icons.payments_outlined, 'Tiền mặt',
        Colors.green.shade50, Colors.green);
      default:
        return (Icons.payment, methodRaw.toUpperCase(),
        Colors.grey.shade200, Colors.grey[800]!);
    }
  }

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

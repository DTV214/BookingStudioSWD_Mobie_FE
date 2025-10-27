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
            return Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child:
                Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (provider.state == PaymentState.error) {
            return Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Không tải được thanh toán: ${provider.message}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final payments = provider.payments;
          return Card(
            elevation: 0,
            color: Colors.white,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Danh sách Thanh toán",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 24),
                  if (payments.isEmpty)
                    const Text('Chưa có thanh toán cho lịch đặt này.')
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: payments.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final p = payments[index];
                        final amountStr = NumberFormat.currency(
                            locale: 'vi_VN', symbol: 'đ')
                            .format(p.amount);
                        final dateStr = DateFormat('dd/MM/yyyy HH:mm')
                            .format(p.paymentDate);
                        final (color, bg, label) = _statusStyle(p.status);

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border:
                            Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: method + status
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    p.paymentMethod,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius:
                                      BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
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

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

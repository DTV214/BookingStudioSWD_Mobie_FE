import 'package:equatable/equatable.dart';

class FinalPayment extends Equatable {
  final String bookingId;
  /// 'VNPAY' | 'MOMO' | 'CASH'
  final String paymentMethod;
  /// Số tiền còn thiếu cần thanh toán
  final int amountDue;
  /// Trạng thái tạo final payment: PENDING / SUCCESS / FAILED ... (tuỳ BE)
  final String status;
  /// Nếu cổng thanh toán sinh link (VNPAY/MOMO) thì trả về
  final String? paymentUrl;

  const FinalPayment({
    required this.bookingId,
    required this.paymentMethod,
    required this.amountDue,
    required this.status,
    this.paymentUrl,
  });

  @override
  List<Object?> get props => [bookingId, paymentMethod, amountDue, status, paymentUrl];
}

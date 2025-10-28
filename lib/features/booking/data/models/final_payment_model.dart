import '../../domain/entities/final_payment.dart';

class FinalPaymentModel extends FinalPayment {
  const FinalPaymentModel({
    required super.bookingId,
    required super.paymentMethod,
    required super.amountDue,
    required super.status,
    super.paymentUrl,
  });

  /// Map linh hoạt: amountDue / remaining / amount; payUrl / paymentUrl / url; bookingId / bookingID / booking_id
  factory FinalPaymentModel.fromJson(Map<String, dynamic> json) {
    final method = (json['paymentMethod'] ?? json['method'] ?? '').toString();
    final status = (json['status'] ?? '').toString();
    final paymentUrl = (json['paymentUrl'] ?? json['payUrl'] ?? json['url']) as String?;

    int amount = 0;
    final dynamic a1 = json['amountDue'];
    final dynamic a2 = json['remaining'];
    final dynamic a3 = json['amount'];
    if (a1 is num) amount = a1.toInt();
    else if (a2 is num) amount = a2.toInt();
    else if (a3 is num) amount = a3.toInt();

    final bookingId = (json['bookingId'] ?? json['bookingID'] ?? json['booking_id'] ?? '').toString();

    return FinalPaymentModel(
      bookingId: bookingId,
      paymentMethod: method,
      amountDue: amount,
      status: status,
      paymentUrl: paymentUrl,
    );
  }
}

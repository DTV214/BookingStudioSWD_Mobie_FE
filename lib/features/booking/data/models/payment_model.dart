import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required String id,
    required String paymentMethod,
    required String status,
    required String paymentType,
    required DateTime paymentDate,
    required int amount,
    required String bookingId,
    required String bookingStatus,
    required String accountEmail,
    required String accountName,
  }) : super(
    id: id,
    paymentMethod: paymentMethod,
    status: status,
    paymentType: paymentType,
    paymentDate: paymentDate,
    amount: amount,
    bookingId: bookingId,
    bookingStatus: bookingStatus,
    accountEmail: accountEmail,
    accountName: accountName,
  );

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
      paymentType: json['paymentType'] as String,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      amount: (json['amount'] as num).toInt(),
      bookingId: json['bookingId'] as String,
      bookingStatus: json['bookingStatus'] as String,
      accountEmail: json['accountEmail'] as String,
      accountName: json['accountName'] as String,
    );
  }
}

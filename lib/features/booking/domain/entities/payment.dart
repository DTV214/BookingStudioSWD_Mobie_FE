import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String id;
  final String paymentMethod;   // MOMO / CASH / ...
  final String status;          // PENDING / SUCCESS / FAILED ...
  final String paymentType;     // FULL_PAYMENT / DEPOSIT ...
  final DateTime paymentDate;
  final int amount;
  final String bookingId;
  final String bookingStatus;
  final String accountEmail;
  final String accountName;

  const Payment({
    required this.id,
    required this.paymentMethod,
    required this.status,
    required this.paymentType,
    required this.paymentDate,
    required this.amount,
    required this.bookingId,
    required this.bookingStatus,
    required this.accountEmail,
    required this.accountName,
  });

  @override
  List<Object> get props => [
    id,
    paymentMethod,
    status,
    paymentType,
    paymentDate,
    amount,
    bookingId,
    bookingStatus,
    accountEmail,
    accountName,
  ];
}

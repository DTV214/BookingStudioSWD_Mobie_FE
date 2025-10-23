// lib/features/booking/domain/entities/booking.dart

import 'package:equatable/equatable.dart';
import 'booking_status.dart'; // Import enum chúng ta vừa tạo

class Booking extends Equatable {
  final String id;
  final DateTime bookingDate;
  final DateTime updatedDate;
  final String? note;
  final int total;
  final BookingStatus status;
  final String bookingType;
  final String accountEmail;
  final String studioName;
  final String studioTypeName;
  final int? updatedAmount;

  // --- Các trường UI cần ---
  // API (ảnh) của bạn có `accountName` (vd: "HoaiCo")
  // UI (BookingCard) của bạn cần `customerName`.
  // Chúng ta sẽ map `accountName` -> `customerName`.
  final String customerName;

  // UI (BookingCard) của bạn cần `phone`.
  // API (ảnh) của bạn không có trường này.
  // Chúng ta định nghĩa nó là `String?` (nullable)
  // Lớp Data sẽ phải xử lý việc này (có thể trả về null)
  final String? phone;

  const Booking({
    required this.id,
    required this.bookingDate,
    required this.updatedDate,
    this.note,
    required this.total,
    required this.status,
    required this.bookingType,
    required this.accountEmail,
    required this.studioName,
    required this.studioTypeName,
    this.updatedAmount,
    required this.customerName, // Lấy từ 'accountName' của API
    this.phone,
  });

  // Sử dụng Equatable để dễ dàng so sánh các đối tượng Booking
  @override
  List<Object?> get props => [
    id,
    bookingDate,
    updatedDate,
    note,
    total,
    status,
    bookingType,
    accountEmail,
    studioName,
    studioTypeName,
    updatedAmount,
    customerName,
    phone,
  ];
}

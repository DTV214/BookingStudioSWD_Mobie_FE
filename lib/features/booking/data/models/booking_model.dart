// lib/features/booking/data/models/booking_model.dart

import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_status.dart';

// BookingModel là một lớp con của Booking (Entity)
// Nó có thêm các phương thức để xử lý dữ liệu thô (JSON)
class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.bookingDate,
    required super.updatedDate,
    super.note,
    required super.total,
    required super.status,
    required super.bookingType,
    required super.accountEmail,
    required super.studioName,
    required super.studioTypeName,
    super.updatedAmount,
    required super.customerName,
    super.phone,
  });

  // Factory constructor để tạo BookingModel từ JSON
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      // SỬA LỖI 5: Xử lý 'null' cho các trường String bắt buộc
      id: (json['id'] as String?) ?? 'ID_KHONG_XAC_DINH',

      // SỬA LỖI 6: Xử lý 'null' cho DateTime
      // Gán một ngày mặc định (năm 1970) nếu API trả về null
      bookingDate: DateTime.parse(
        (json['bookingDate'] as String?) ?? DateTime(1970).toIso8601String(),
      ),
      updatedDate: DateTime.parse(
        (json['updatedDate'] as String?) ?? DateTime(1970).toIso8601String(),
      ),

      note: json['note'] as String?,

      // SỬA LỖI 1: Chuyển 'double' thành 'int' và xử lý 'null'
      total: (json['total'] as num? ?? 0).toInt(),

      // Gọi hàm trợ giúp để chuyển String status từ API thành Enum
      status: _mapStatus(json['status'] as String?),

      // SỬA LỖI 5 (tiếp theo):
      bookingType: (json['bookingType'] as String?) ?? 'Không rõ',
      accountEmail: (json['accountEmail'] as String?) ?? 'Không rõ',

      // SỬA LỖI 3 (QUAN TRỌNG): Xử lý 'null' cho 'studioTypeName'
      studioName:
          (json['studioTypeName'] as String?) ?? 'Studio không xác định',
      studioTypeName:
          (json['studioTypeName'] as String?) ?? 'Loại không xác định',

      updatedAmount: json['updatedAmount'] as int?,

      // SỬA LỖI 4 (QUAN TRỌNG): Xử lý 'null' cho 'accountName'
      customerName: (json['accountName'] as String?) ?? 'Khách hàng ẩn',

      // API của bạn (trong ảnh) không có 'phone', nên chúng ta gán null
      phone: json['phone'] as String?, // Giả sử API có thể có hoặc không
    );
  }

  // Hàm trợ giúp (helper) để map String sang Enum
  static BookingStatus _mapStatus(String? apiStatus) {
    switch ((apiStatus ?? '').toUpperCase()) {
      case 'IN_PROGRESS':
        return BookingStatus.inProgress;
      case 'COMPLETED':
        return BookingStatus.completed;
      case 'CANCELLED':
        return BookingStatus.cancelled;
      case 'AWAITING_REFUND':
        return BookingStatus.awaitingRefund;
      case 'AWAITING_PAYMENT':
        return BookingStatus.awaitingPayment;
      case 'CONFIRMED':
        return BookingStatus.confirmed;
      default:
        return BookingStatus.unknown;
    }
  }


// (Nếu cần, bạn có thể thêm hàm `toJson` ở đây để gửi dữ liệu đi)
}

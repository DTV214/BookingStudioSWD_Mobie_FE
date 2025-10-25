enum BookingStatus {
  pending, // Chờ xác nhận (API của bạn có thể trả về "IN_PROGRESS")
  confirmed, // Đã xác nhận (API của bạn có thể trả về "DONE" hoặc "CONFIRMED")
  cancelled, // Đã hủy (API của bạn có thể trả về "CANCELLED")
  unknown, // Trạng thái không xác định
}

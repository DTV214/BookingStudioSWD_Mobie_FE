import 'package:equatable/equatable.dart';

/// Kết quả sau khi thêm thời gian bổ sung cho StudioAssign.
/// BE có thể trả:
/// - updatedAmount: số tiền bổ sung sau khi cộng thêm phút
/// - additionTime: tổng số phút bổ sung tích lũy
/// - endTime: giờ kết thúc mới (nếu có)
class AdditionTimeResult extends Equatable {
  final int? updatedAmount;
  final int? additionTime;
  final DateTime? endTime;

  const AdditionTimeResult({
    this.updatedAmount,
    this.additionTime,
    this.endTime,
  });

  @override
  List<Object?> get props => [updatedAmount, additionTime, endTime];
}

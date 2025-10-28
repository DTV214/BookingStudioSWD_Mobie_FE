import '../../domain/entities/addition_time_result.dart';

class AdditionTimeResultModel extends AdditionTimeResult {
  const AdditionTimeResultModel({
    int? updatedAmount,
    int? additionTime,
    DateTime? endTime,
  }) : super(
    updatedAmount: updatedAmount,
    additionTime: additionTime,
    endTime: endTime,
  );

  /// Map linh hoạt các field từ BE:
  /// - updatedAmount / updated_amount
  /// - additionTime / addition_minutes / additionMinutes
  /// - endTime / end_time
  factory AdditionTimeResultModel.fromJson(Map<String, dynamic> json) {
    int? updatedAmount;
    final ua = json['updatedAmount'] ?? json['updated_amount'];
    if (ua is num) updatedAmount = ua.toInt();

    int? additionTime;
    final at = json['additionTime'] ?? json['addition_minutes'] ?? json['additionMinutes'];
    if (at is num) additionTime = at.toInt();

    DateTime? endTime;
    final et = json['endTime'] ?? json['end_time'];
    if (et is String && et.isNotEmpty) {
      try {
        endTime = DateTime.parse(et);
      } catch (_) {}
    }

    return AdditionTimeResultModel(
      updatedAmount: updatedAmount,
      additionTime: additionTime,
      endTime: endTime,
    );
  }
}

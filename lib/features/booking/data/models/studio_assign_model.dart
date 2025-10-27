import '../../domain/entities/studio_assign.dart';

class StudioAssignModel extends StudioAssign {
  const StudioAssignModel({
    required super.id,
    required super.bookingId,
    required super.studioId,
    required super.studioName,
    required super.locationName,
    required super.startTime,
    required super.endTime,
    required super.studioAmount,
    required super.serviceAmount,
    super.additionTime,
    required super.status,
    super.updatedAmount,
  });

  factory StudioAssignModel.fromJson(Map<String, dynamic> json) {
    return StudioAssignModel(
      id: json['id'],
      bookingId: json['bookingId'],
      studioId: json['studioId'],
      studioName: json['studioName'],
      locationName: json['locationName'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      studioAmount: (json['studioAmount'] as num).toInt(),
      serviceAmount: (json['serviceAmount'] as num).toInt(),
      additionTime: json['additionTime'] == null ? null : (json['additionTime'] as num).toInt(),
      status: json['status'],
      updatedAmount: json['updatedAmount'] == null ? null : (json['updatedAmount'] as num).toInt(),
    );
  }
}

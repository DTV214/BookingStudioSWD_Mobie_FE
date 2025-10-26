import 'package:equatable/equatable.dart';

class StudioAssign extends Equatable {
  final String id;
  final String bookingId;
  final String studioId;
  final String studioName;
  final String locationName;
  final DateTime startTime;
  final DateTime endTime;
  final int studioAmount;
  final int serviceAmount;
  final int? additionTime;
  final String status; // COMING_SOON / IN_PROGRESS / ENDED ...
  final int? updatedAmount;

  const StudioAssign({
    required this.id,
    required this.bookingId,
    required this.studioId,
    required this.studioName,
    required this.locationName,
    required this.startTime,
    required this.endTime,
    required this.studioAmount,
    required this.serviceAmount,
    this.additionTime,
    required this.status,
    this.updatedAmount,
  });

  @override
  List<Object?> get props => [id, bookingId, studioId, startTime, endTime, status];
}

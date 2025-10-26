import 'package:equatable/equatable.dart';

class ServiceAssign extends Equatable {
  final String id;
  final String studioAssignId;
  final String serviceId;
  final String serviceName;
  final int serviceFee;
  final String status;

  const ServiceAssign({
    required this.id,
    required this.studioAssignId,
    required this.serviceId,
    required this.serviceName,
    required this.serviceFee,
    required this.status,
  });

  @override
  List<Object?> get props => [id, studioAssignId, serviceId, serviceName, serviceFee, status];
}

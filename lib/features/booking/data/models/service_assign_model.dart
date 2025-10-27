import '../../domain/entities/service_assign.dart';

class ServiceAssignModel extends ServiceAssign {
  const ServiceAssignModel({
    required super.id,
    required super.studioAssignId,
    required super.serviceId,
    required super.serviceName,
    required super.serviceFee,
    required super.status,
  });

  factory ServiceAssignModel.fromJson(Map<String, dynamic> json) {
    return ServiceAssignModel(
      id: json['id'] as String,
      studioAssignId: json['studioAssignId'] as String,
      serviceId: json['serviceId'] as String,
      serviceName: json['serviceName'] as String,
      serviceFee: (json['serviceFee'] as num).toInt(),
      status: json['status'] as String,
    );
  }
}

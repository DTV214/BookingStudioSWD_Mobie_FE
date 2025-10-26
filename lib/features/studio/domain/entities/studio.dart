// lib/features/studio/domain/entities/studio.dart
import 'package:flutter/material.dart';

// Chúng ta giữ lại enum này vì nó rất hữu ích cho UI
enum StudioStatus { available, maintenance, deleted }

class Studio {
  final String id;
  final String studioName;
  final String description;
  final String imageUrl;
  final String locationName;
  final String studioTypeName;
  final StudioStatus status;
  final double acreage;
  final String startTime;
  final String endTime;

  Studio({
    required this.id,
    required this.studioName,
    required this.description,
    required this.imageUrl,
    required this.locationName,
    required this.studioTypeName,
    required this.status,
    required this.acreage,
    required this.startTime,
    required this.endTime,
  });
}

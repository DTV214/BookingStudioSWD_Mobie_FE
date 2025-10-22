import '../../domain/entities/studio.dart';

class StudioModel extends Studio {
  StudioModel({
    required String id,
    required String studioName,
    required String description,
    required String imageUrl,
    required String locationName,
    required String studioTypeName,
    required StudioStatus status,
    // --- THÊM VÀO CONSTRUCTOR CỦA MODEL ---
    required double acreage,
    required String startTime,
    required String endTime,
  }) : super(
         id: id,
         studioName: studioName,
         description: description,
         imageUrl: imageUrl,
         locationName: locationName,
         studioTypeName: studioTypeName,
         status: status,
         // --- TRUYỀN VÀO HÀM SUPER ---
         acreage: acreage,
         startTime: startTime,
         endTime: endTime,
       );

  // Hàm này dùng để chuyển JSON từ API thành object StudioModel
  factory StudioModel.fromJson(Map<String, dynamic> json) {
    return StudioModel(
      id: json['id'] ?? '',
      studioName: json['studioName'] ?? 'N/A',
      description: json['description'] ?? 'Không có mô tả',
      imageUrl: (json['imageUrl'] ?? 'https://via.placeholder.com/300x200')
          .toString()
          .replaceFirst('http://', 'https://'),
      locationName: json['locationName'] ?? 'N/A',
      studioTypeName: json['studioTypeName'] ?? 'N/A',
      status: _mapStatus(json['status']),

      // --- ĐỌC CÁC TRƯỜNG MỚI TỪ JSON ---
      // API trả về acreage là số nguyên (int), nhưng model nên là double
      acreage: (json['acreage'] as num?)?.toDouble() ?? 0.0,
      startTime: json['startTime'] ?? '00:00:00',
      endTime: json['endTime'] ?? '00:00:00',
    );
  }

  // Thêm hàm toJson để gửi dữ liệu đi
  Map<String, dynamic> toJson() {
    // Chuyển đổi enum status về lại String
    String statusString;
    switch (status) {
      case StudioStatus.available:
        statusString = 'AVAILABLE';
        break;

      case StudioStatus.maintenance:
        statusString = 'MAINTENANCE';
        break;
      default:
        statusString = 'AVAILABLE';
    }

    return {
      'studioName': studioName,
      'description': description,
      'acreage': acreage,
      'startTime': startTime,
      'endTime': endTime,
      'imageUrl': imageUrl,
      'status': statusString,
      // API (theo curl) dùng locationName và studioTypeName
      'locationName': locationName,
      'studioTypeName': studioTypeName,

      // Ghi chú: Nếu sau này API đổi sang dùng ID, ta sẽ sửa ở đây
      // 'locationId': locationId,
      // 'studioTypeId': studioTypeId,
    };
  }

  // Hàm helper để chuyển đổi
  static StudioStatus _mapStatus(String? status) {
    switch (status) {
      case 'AVAILABLE':
        return StudioStatus.available;

      case 'MAINTENANCE':
        return StudioStatus.maintenance;
      default:
        return StudioStatus.available;
    }
  }
}

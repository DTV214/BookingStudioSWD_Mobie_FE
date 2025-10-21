// lib/features/studio/presentation/widgets/studio_card.dart
import 'package:flutter/material.dart';

enum StudioStatus { available, inUse, maintenance }

class StudioCard extends StatelessWidget {
  final String imageUrl;
  final StudioStatus status;
  final String studioName;
  final String price;
  final String studioType;
  final String booking;
  final String capacity;
  final String revenue;
  final double usage; // Tỷ lệ %
  final List<String> equipments;

  const StudioCard({
    super.key,
    required this.imageUrl,
    required this.status,
    required this.studioName,
    required this.price,
    required this.studioType,
    required this.booking,
    required this.capacity,
    required this.revenue,
    required this.usage,
    required this.equipments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 12),
                _buildStats(),
                SizedBox(height: 12),
                _buildUsageBar(),
                SizedBox(height: 16),
                _buildEquipments(),
                Divider(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    String statusText;
    Color statusColor;

    switch (status) {
      case StudioStatus.available:
        statusText = "Sẵn sàng";
        statusColor = Colors.green;
        break;
      case StudioStatus.inUse:
        statusText = "Đang sử dụng";
        statusColor = Colors.orange;
        break;
      case StudioStatus.maintenance:
        statusText = "Bảo trì";
        statusColor = Colors.red;
        break;
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: Image.network(
            imageUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusText,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.4),
            child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(studioType, style: TextStyle(fontSize: 12, color: Colors.grey)),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              studioName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A40D3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem("Booking", booking),
        _buildStatItem("Sức chứa", capacity),
        _buildStatItem("Doanh thu", revenue),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildUsageBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Tỷ lệ sử dụng",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              "$usage%",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: usage / 100, // giá trị từ 0.0 đến 1.0
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A40D3)),
        ),
      ],
    );
  }

  Widget _buildEquipments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Thiết bị", style: TextStyle(fontSize: 12, color: Colors.grey)),
        SizedBox(height: 8),
        Wrap(
          // Tự động xuống hàng nếu ko đủ chỗ
          spacing: 8,
          runSpacing: 8,
          children: equipments
              .map(
                (e) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(e, style: TextStyle(fontSize: 12)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton.icon(
          icon: Icon(Icons.info_outline, size: 18),
          label: Text("Xem chi tiết"),
          onPressed: () {},
          style: TextButton.styleFrom(foregroundColor: Colors.blue),
        ),
        TextButton.icon(
          icon: Icon(Icons.edit_outlined, size: 18),
          label: Text("Chỉnh sửa"),
          onPressed: () {},
          style: TextButton.styleFrom(foregroundColor: Color(0xFF6A40D3)),
        ),
      ],
    );
  }
}

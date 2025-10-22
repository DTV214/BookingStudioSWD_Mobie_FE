import 'package:flutter/material.dart';
import 'package:swd_mobie_flutter/features/studio/presentation/widgets/studio_edit_page.dart';
import '../../domain/entities/studio.dart';
// 1. Import trang edit mới của bạn

class StudioCard extends StatelessWidget {
  final Studio studio;

  const StudioCard({super.key, required this.studio});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Dùng Stack để đặt thẻ trạng thái "chồng" lên ảnh
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16), // Tăng bo góc
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            // Dùng Column cho nội dung bên dưới ảnh
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(), // Ảnh
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(), // Tên, loại studio
                      SizedBox(height: 12),
                      _buildInfo(), // Địa điểm
                      SizedBox(height: 12),
                      _buildDescription(), // Mô tả
                      Divider(height: 32, thickness: 0.5),
                      _buildActionButtons(context), // Nút bấm
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Đặt thẻ trạng thái ở góc trên bên phải
          Positioned(top: 12, right: 12, child: _buildStatusTag()),
        ],
      ),
    );
  }

  // Widget hiển thị ảnh và ảnh lỗi
  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Image.network(
        studio.imageUrl,
        height: 160, // Tăng chiều cao ảnh
        width: double.infinity,
        fit: BoxFit.cover,
        // Cải thiện phần hiển thị ảnh lỗi
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 160,
            width: double.infinity,
            color: Colors.grey[100],
            child: Icon(
              Icons.camera_alt_outlined, // Dùng icon camera
              color: Colors.grey[400],
              size: 48, // Tăng kích thước
            ),
          );
        },
      ),
    );
  }

  // Widget hiển thị thẻ trạng thái (Available, InUse, Maintenance)
  Widget _buildStatusTag() {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (studio.status) {
      case StudioStatus.available:
        statusText = "Sẵn sàng";
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
 
      case StudioStatus.maintenance:
        statusText = "Bảo trì";
        statusColor = Colors.red;
        statusIcon = Icons.build_outlined;
        break;
    
      default:
        statusText = "Không rõ";
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600, // In đậm
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị Tên và Loại Studio
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          studio.studioTypeName.toUpperCase(), // VIẾT HOA
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF6A40D3),
            fontWeight: FontWeight.w700, // In đậm
            letterSpacing: 0.5, // Giãn cách chữ
          ),
        ),
        SizedBox(height: 6),
        Text(
          studio.studioName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600, // Đậm vừa
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Widget hiển thị thông tin (Địa điểm)
  Widget _buildInfo() {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            studio.locationName,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Widget hiển thị mô tả
  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mô tả",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          studio.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4,
          ), // Giãn dòng
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Widget hiển thị nút bấm
  Widget _buildActionButtons(BuildContext context) {
    return Align(
      // 1. Chỉ còn 1 nút, căn ra giữa hoặc cuối
      // Dùng Align để nó không chiếm toàn bộ chiều rộng
      alignment: Alignment.center,
      child: FilledButton.icon(
        // 2. Dùng FilledButton để có nền
        icon: Icon(Icons.edit_outlined, size: 18),
        label: Text(
          "Chỉnh sửa thông tin",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          // 3. THÊM HÀNH ĐỘNG ĐIỀU HƯỚNG
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudioEditPage(
                studio: studio, // Truyền đối tượng studio qua
              ),
            ),
          );
        },
        style: Theme.of(context).filledButtonTheme.style?.copyWith(
          // Style này lấy từ AppTheme, chúng ta chỉ cần ghi đè nếu muốn
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
    );
  }
}

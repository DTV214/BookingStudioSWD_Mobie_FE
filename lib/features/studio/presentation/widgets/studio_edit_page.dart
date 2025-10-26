import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/studio.dart';
import '../providers/studio_provider.dart';

class StudioEditPage extends StatefulWidget {
  final Studio studio;
  const StudioEditPage({super.key, required this.studio});

  @override
  State<StudioEditPage> createState() => _StudioEditPageState();
}

class _StudioEditPageState extends State<StudioEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _acreageController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _imageUrlController;
  late StudioStatus _selectedStatus;
  late StudioStatus _initialStatus;
  @override
  void initState() {
    super.initState();
    final studio = widget.studio;
    _nameController = TextEditingController(text: studio.studioName);
    _descController = TextEditingController(text: studio.description);
    _acreageController = TextEditingController(text: studio.acreage.toString());
    _startTimeController = TextEditingController(text: studio.startTime);
    _endTimeController = TextEditingController(text: studio.endTime);
    _imageUrlController = TextEditingController(text: studio.imageUrl);
    _selectedStatus = studio.status;
    _initialStatus = widget.studio.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _acreageController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi nhấn nút "Lưu"
  Future<void> _saveForm() async {
    // 1. Kiểm tra xem status có thay đổi không
    if (_selectedStatus == _initialStatus) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không có thay đổi trạng thái nào để lưu.')),
      );
      return; // Không làm gì nếu không đổi
    }

    final provider = context.read<StudioProvider>();

    // 2. Gọi hàm updateStudioStatus (PATCH)
    print("Trạng thái đã thay đổi. Gọi updateStudioStatus (PATCH)...");
    final bool success = await provider.updateStudioStatus(
      widget.studio.id,
      _selectedStatus,
    );

    // 3. Xử lý kết quả
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật trạng thái thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi cập nhật trạng thái: ${provider.errorMessage}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  // --- THÊM HÀM XỬ LÝ NÚT VÔ HIỆU HÓA ---
  Future<void> _deleteStudio() async {
    final provider = context.read<StudioProvider>();

    // 1. Hiển thị Dialog xác nhận
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận'),
        content: Text(
          'Bạn có chắc chắn muốn vô hiệu hóa studio này? (Trạng thái sẽ đổi thành DELETED)',
        ),
        actions: [
          TextButton(
            child: Text('Hủy bỏ'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: Text('Xác nhận', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    // 2. Nếu người dùng không xác nhận, hủy
    if (confirmed == null || confirmed == false) {
      return;
    }

    // 3. Nếu xác nhận, gọi API
    final bool success = await provider.deleteStudio(widget.studio.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã vô hiệu hóa studio thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      // Đóng trang 2 lần để quay về trang danh sách
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${provider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<StudioProvider>().isSaving;
    final studio = widget.studio; // Lấy studio gốc để hiển thị

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cập nhật Trạng thái", // Đổi tiêu đề
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // Không cần Form nữa
        // child: Form(
        //   key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- BIẾN CÁC TRƯỜNG THÀNH READ-ONLY ---
            _buildReadOnlyField(
              label: "ID Studio",
              value: studio.id,
              icon: Icons.vpn_key,
            ),
            SizedBox(height: 16),
            _buildReadOnlyField(
              label: "Tên Studio",
              value: studio.studioName,
              icon: Icons.title,  
            ),
            SizedBox(height: 16),
            _buildReadOnlyField(
              label: "Mô tả",
              value: studio.description,
              icon: Icons.description,
            ), // Cho phép hiển thị nhiều dòng
            SizedBox(height: 16),
            _buildReadOnlyField(
              label: "Link ảnh",
              value: studio.imageUrl,
              icon: Icons.image,
            ),
            SizedBox(height: 16),
            _buildReadOnlyField(
              label: "Diện tích (m²)",
              value: studio.acreage.toString(),
              icon: Icons.square_foot,
            ),
            SizedBox(height: 16),
            // --- GIỮ LẠI DROPDOWN STATUS ---
            _buildStatusDropdown(),
            SizedBox(height: 16),
            // Giờ (Read-only)
            Row(
              children: [
                Expanded(
                  child: _buildReadOnlyField(
                    label: "Giờ mở cửa",
                    value: studio.startTime,
                    icon: Icons.access_time,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildReadOnlyField(
                    label: "Giờ đóng cửa",
                    value: studio.endTime,
                    icon: Icons.timer_off_outlined,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildReadOnlyField(
              label: "Địa điểm",
              value: studio.locationName,
              icon: Icons.location_on,
            ),
            SizedBox(height: 16),
            _buildReadOnlyField(
              label: "Loại Studio",
              value: studio.studioTypeName,
              icon: Icons.category,
            ),
            SizedBox(height: 32),

            // --- SỬA LẠI NÚT LƯU ---
            FilledButton.icon(
              icon: isSaving ? _buildLoadingIndicator() : Icon(Icons.save),
              label: Text(
                isSaving ? "Đang xử lý..." : "Lưu Trạng Thái", // Đổi text nút
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              // Vô hiệu hóa nếu đang lưu HOẶC status không đổi
              onPressed: (isSaving || _selectedStatus == _initialStatus)
                  ? null
                  : _saveForm,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                // Làm mờ nút nếu không có gì thay đổi
                backgroundColor:
                    (_selectedStatus == _initialStatus && !isSaving)
                    ? Theme.of(context).primaryColor.withOpacity(0.5)
                    : Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 16),

            // --- NÚT VÔ HIỆU HÓA (Giữ nguyên) ---
            // Chỉ hiển thị nếu studio chưa bị xóa
            if (_initialStatus != StudioStatus.deleted)
              FilledButton.icon(
                icon: isSaving
                    ? _buildLoadingIndicator()
                    : Icon(Icons.delete_forever),
                label: Text(
                  isSaving ? "Đang xử lý..." : "Vô hiệu hóa Studio",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onPressed: isSaving ? null : _deleteStudio,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
          ],
        ),
        // ), // Đóng Form
      ),
    );
  }
  // ... (_buildTextFormField và _buildReadOnlyField giữ nguyên) ...

Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Nền xám
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700]),
          SizedBox(width: 12),
          Expanded(
            // <-- Vẫn cần Expanded
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[800], fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  // CẢI TIẾN: Thêm 2 dòng này
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, // Đảm bảo chỉ hiển thị trên 1 dòng
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // --- SỬA LẠI DROPDOWN ---
  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<StudioStatus>(
      value: _selectedStatus,
      // ... (decoration giữ nguyên) ...
      decoration: InputDecoration(
        labelText: "Trạng thái",
        prefixIcon: Icon(Icons.toggle_on, color: Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),

      // Lọc bỏ 'unknown', 'inUse', 'deleted'
      items: StudioStatus.values
          .where(
            (s) => s == StudioStatus.available || s == StudioStatus.maintenance,
          )
          .map((StudioStatus status) {
            // ... (code tạo Row với Icon + Text giữ nguyên) ...
            String text;
            IconData iconData;
            Color color;
            switch (status) {
              case StudioStatus.available:
                text = 'Sẵn sàng';
                iconData = Icons.check_circle_outline;
                color = Colors.green;
                break;
              case StudioStatus.maintenance:
                text = 'Bảo trì';
                iconData = Icons.build_outlined;
                color = Colors.orange.shade800;
                break;
              default:
                text = '';
                iconData = Icons.error;
                color = Colors.grey;
            }
            return DropdownMenuItem<StudioStatus>(
              value: status,
              child: Row(
                children: [
                  Icon(iconData, color: color, size: 20),
                  SizedBox(width: 10),
                  Text(text),
                ],
              ),
            );
          })
          .toList(),
      onChanged: (StudioStatus? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedStatus = newValue;
          });
        }
      },
    );
  }
}

// Helper widget cho vòng quay loading
Widget _buildLoadingIndicator() {
  return Container(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
  );
}

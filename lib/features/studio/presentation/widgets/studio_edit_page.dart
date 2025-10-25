import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/studio.dart';
import '../providers/studio_provider.dart';

class StudioEditPage extends StatefulWidget {
  // Trang này nhận 1 studio cụ thể để chỉnh sửa
  final Studio studio;

  const StudioEditPage({super.key, required this.studio});

  @override
  State<StudioEditPage> createState() => _StudioEditPageState();
}

class _StudioEditPageState extends State<StudioEditPage> {
  // 1. Khóa Form để validation
  final _formKey = GlobalKey<FormState>();

  // 2. Các TextEditingController để quản lý input
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _acreageController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _imageUrlController;

  // Trạng thái (status) là 1 dropdown
  late StudioStatus _selectedStatus;

  // 3. Khởi tạo controller với dữ liệu từ studio
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
  }

  // 4. Hủy các controller khi widget bị xóa
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

  // 5. Hàm xử lý khi nhấn nút "Lưu"
  Future<void> _saveForm() async {
    // Kiểm tra Form có hợp lệ không
    if (!_formKey.currentState!.validate()) {
      return; // Nếu không hợp lệ, không làm gì cả
    }

    // Lấy provider (listen: false vì đang ở trong 1 hàm)
    final provider = context.read<StudioProvider>();

    // 6. Tạo một đối tượng Studio mới với dữ liệu đã cập nhật
    final updatedStudio = Studio(
      id: widget.studio.id, // Giữ ID cũ
      studioName: _nameController.text,
      description: _descController.text,
      acreage: double.tryParse(_acreageController.text) ?? 0.0,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      imageUrl: _imageUrlController.text,
      status: _selectedStatus,
      // Các trường này chúng ta không cho sửa ở đây
      locationName: widget.studio.locationName,
      studioTypeName: widget.studio.studioTypeName,
    );

    // 7. Gọi hàm saveStudio từ provider
    final bool success = await provider.saveStudio(updatedStudio);

    // 8. Xử lý kết quả (rất quan trọng)
    if (!mounted) return; // Luôn kiểm tra "mounted" sau 1 lời gọi await

    if (success) {
      // Nếu thành công:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật studio thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      // Đóng trang chỉnh sửa và quay lại trang danh sách
      Navigator.of(context).pop();
    } else {
      // Nếu thất bại:
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
    // Lắng nghe trạng thái `isSaving`
    final isSaving = context.watch<StudioProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chỉnh Sửa Studio",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Chữ và icon màu đen
        elevation: 1,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFormField(
                controller: _nameController,
                label: "Tên Studio",
                icon: Icons.title,
                validator: (value) =>
                    value!.isEmpty ? "Vui lòng nhập tên studio" : null,
              ),
              SizedBox(height: 16),
              _buildTextFormField(
                controller: _descController,
                label: "Mô tả",
                icon: Icons.description,
                maxLines: 4,
              ),
              SizedBox(height: 16),
              _buildTextFormField(
                controller: _imageUrlController,
                label: "Link ảnh (Image URL)",
                icon: Icons.image,
                validator: (value) =>
                    value!.isEmpty ? "Vui lòng nhập link ảnh" : null,
              ),
              SizedBox(height: 16),
              _buildTextFormField(
                controller: _acreageController,
                label: "Diện tích (m²)",
                icon: Icons.square_foot,
                keyboardType: TextInputType.number,
                validator: (value) => (double.tryParse(value!) == null)
                    ? "Vui lòng nhập số hợp lệ"
                    : null,
              ),
              SizedBox(height: 16),
              // Trạng thái (Dropdown)
              _buildStatusDropdown(),
              SizedBox(height: 16),
              // Giờ (chia 2 cột)
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _startTimeController,
                      label: "Giờ mở cửa (HH:mm:ss)",
                      icon: Icons.access_time,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _endTimeController,
                      label: "Giờ đóng cửa (HH:mm:ss)",
                      icon: Icons.timer_off_outlined,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Hiển thị các trường không cho sửa
              _buildReadOnlyField(
                label: "Địa điểm",
                value: widget.studio.locationName,
                icon: Icons.location_on,
              ),
              SizedBox(height: 16),
              _buildReadOnlyField(
                label: "Loại Studio",
                value: widget.studio.studioTypeName,
                icon: Icons.category,
              ),
              SizedBox(height: 32),
              // Nút "Lưu"
              FilledButton.icon(
                icon: isSaving
                    ? Container(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(Icons.save),
                label: Text(
                  isSaving ? "Đang lưu..." : "Lưu thay đổi",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onPressed: isSaving
                    ? null
                    : _saveForm, // Vô hiệu hóa khi đang lưu
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget cho ô nhập liệu
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng không để trống';
            }
            return null;
          },
    );
  }

  // Helper widget cho các trường chỉ đọc
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
          Column(
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget cho ô chọn Trạng thái
  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<StudioStatus>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: "Trạng thái",
        prefixIcon: Icon(Icons.toggle_on, color: Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: StudioStatus.values.map((StudioStatus status) {
        // Chuyển Enum thành chữ Tiếng Việt
        String text;
        switch (status) {
          case StudioStatus.available:
            text = 'Sẵn sàng';
            break;

          case StudioStatus.maintenance:
            text = 'Bảo trì';
            break;
        }
        return DropdownMenuItem<StudioStatus>(value: status, child: Text(text));
      }).toList(),
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

// lib/features/booking/presentation/widgets/service_assign_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/service_assign_provider.dart';
import '../../domain/entities/service_assign.dart';

// ==== Provider + Usecase cho cập nhật trạng thái Studio Assign ====
import '../providers/studio_assign_status_provider.dart';
import '../../domain/usecases/set_studio_assign_status_usecase.dart';
import '../../domain/repositories/studio_assign_repository.dart';
import '../../../booking/data/datasources/studio_assign_remote_data_source_impl.dart';
import '../../../booking/data/repositories/studio_assign_repository_impl.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tóm tắt đầy đủ một studio-assign (booking_assign) để mang sang trang chi tiết.
class AssignSummary {
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
  /// COMING_SOON / IS_HAPPENING / ENDED / CANCELLED / AWAITING_REFUND (có thể cả IN_PROGRESS từ API cũ)
  final String status;
  final int? updatedAmount;

  const AssignSummary({
    required this.id,
    required this.bookingId,
    required this.studioId,
    required this.studioName,
    required this.locationName,
    required this.startTime,
    required this.endTime,
    required this.studioAmount,
    required this.serviceAmount,
    required this.additionTime,
    required this.status,
    required this.updatedAmount,
  });

  AssignSummary copyWith({String? status}) {
    return AssignSummary(
      id: id,
      bookingId: bookingId,
      studioId: studioId,
      studioName: studioName,
      locationName: locationName,
      startTime: startTime,
      endTime: endTime,
      studioAmount: studioAmount,
      serviceAmount: serviceAmount,
      additionTime: additionTime,
      status: status ?? this.status,
      updatedAmount: updatedAmount,
    );
  }
}

class ServiceAssignPage extends StatefulWidget {
  final String studioAssignId;
  final AssignSummary assign;

  const ServiceAssignPage({
    super.key,
    required this.studioAssignId,
    required this.assign,
  });

  @override
  State<ServiceAssignPage> createState() => _ServiceAssignPageState();
}

class _ServiceAssignPageState extends State<ServiceAssignPage> {
  late AssignSummary _assign;
  String? _selectedStatus;
  bool _dirty = false; // nếu có thay đổi sẽ trả true khi back

  // ENUM hợp lệ theo API
  static const List<String> kStatuses = <String>[
    'COMING_SOON',
    'IS_HAPPENING',
    'ENDED',
    'CANCELLED',
    'AWAITING_REFUND',
  ];

  @override
  void initState() {
    super.initState();
    _assign = widget.assign;
    _selectedStatus = widget.assign.status;

    // Gọi fetch service-assign 1 lần sau frame đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<ServiceAssignProvider>();
      if (prov.state == ServiceAssignState.initial) {
        prov.fetch(widget.studioAssignId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope để pop trả kết quả (dù back hệ thống hay AppBar)
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _dirty);
        return false;
      },
      child: ChangeNotifierProvider<StudioAssignStatusProvider>(
        create: (_) {
          final remote = StudioAssignRemoteDataSourceImpl(
            client: http.Client(),
            secureStorage: const FlutterSecureStorage(),
          );
          final StudioAssignRepository repo = StudioAssignRepositoryImpl(remote: remote);
          final usecase = SetStudioAssignStatusUsecase(repo);
          return StudioAssignStatusProvider(setStatusUsecase: usecase);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F6F9),
          appBar: AppBar(
            title: const Text('Dịch vụ của Studio Assign'),
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, _dirty);
              },
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ===== Header: hiện toàn bộ thông tin assign + đổi trạng thái =====
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Consumer<StudioAssignStatusProvider>(
                      builder: (_, statusProv, __) {
                        final dateRange =
                            '${DateFormat('dd/MM/yyyy HH:mm').format(_assign.startTime)} → ${DateFormat('dd/MM/yyyy HH:mm').format(_assign.endTime)}';
                        final total = _assign.studioAmount + _assign.serviceAmount;
                        final totalStr = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(total);
                        final studioStr =
                        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(_assign.studioAmount);
                        final serviceStr =
                        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(_assign.serviceAmount);
                        final updatedStr = _assign.updatedAmount == null
                            ? null
                            : NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(_assign.updatedAmount);

                        final (badgeColor, badgeBg, badgeText) = _statusStyle(_assign.status);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Studio name + status badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _assign.studioName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration:
                                  BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                                  child: Text(
                                    badgeText,
                                    style: TextStyle(
                                      color: badgeColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            _row(Icons.place_outlined, _assign.locationName),
                            const SizedBox(height: 6),
                            _row(Icons.access_time, dateRange),
                            const Divider(height: 24),

                            // Giá chi tiết
                            _row(Icons.monetization_on_outlined, 'Studio: $studioStr'),
                            const SizedBox(height: 6),
                            _row(Icons.design_services_outlined, 'Dịch vụ: $serviceStr'),
                            const SizedBox(height: 6),
                            if (updatedStr != null) _row(Icons.price_change_outlined, 'Bổ sung: $updatedStr'),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('TỔNG'),
                                Text(totalStr, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Dropdown chọn status mới
                            Row(
                              children: [
                                const Icon(Icons.flag_outlined, size: 20, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedStatus,
                                    decoration: const InputDecoration(
                                      labelText: 'Trạng thái Studio Assign',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    items: kStatuses.map((s) {
                                      return DropdownMenuItem<String>(
                                        value: s,
                                        child: Text(_statusDisplayText(s)),
                                      );
                                    }).toList(),
                                    onChanged: statusProv.state == StudioAssignStatusState.loading
                                        ? null
                                        : (v) {
                                      setState(() {
                                        _selectedStatus = v;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Button cập nhật
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: statusProv.state == StudioAssignStatusState.loading
                                    ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                                    : const Icon(Icons.save_outlined),
                                label: Text(
                                  statusProv.state == StudioAssignStatusState.loading
                                      ? 'Đang cập nhật...'
                                      : 'Cập nhật trạng thái',
                                ),
                                onPressed: (statusProv.state == StudioAssignStatusState.loading ||
                                    _selectedStatus == null ||
                                    _selectedStatus == _assign.status)
                                    ? null
                                    : () async {
                                  await statusProv.updateStatus(
                                    assignId: widget.studioAssignId,
                                    status: _selectedStatus!,
                                  );

                                  if (!mounted) return;

                                  if (statusProv.state == StudioAssignStatusState.success) {
                                    setState(() {
                                      _assign = _assign.copyWith(status: _selectedStatus);
                                      _dirty = true; // đánh dấu có thay đổi
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Đã cập nhật trạng thái thành công.')),
                                    );
                                  } else if (statusProv.state == StudioAssignStatusState.error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(statusProv.message)),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ===== Danh sách Service Assign (Provider sẵn có) =====
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Consumer<ServiceAssignProvider>(
                      builder: (_, prov, __) {
                        if (prov.state == ServiceAssignState.loading ||
                            prov.state == ServiceAssignState.initial) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (prov.state == ServiceAssignState.error) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              prov.message,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        final items = prov.items;
                        if (items.isEmpty) {
                          return const Text('Không có dịch vụ nào.');
                        }
                        return _ServiceAssignList(items: items);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  // Badge cho trạng thái assign
  (Color, Color, String) _statusStyle(String status) {
    switch (status) {
      case 'COMING_SOON':
        return (Colors.orange, Colors.orange.shade50, 'Coming Soon');
      case 'IS_HAPPENING':
      case 'IN_PROGRESS': // tương thích tên cũ từ BE
        return (Colors.blue, Colors.blue.shade50, 'Is Happening');
      case 'ENDED':
        return (Colors.green, Colors.green.shade50, 'Ended');
      case 'CANCELLED':
        return (Colors.red, Colors.red.shade50, 'Cancelled');
      case 'AWAITING_REFUND':
        return (Colors.deepPurple, Colors.deepPurple.shade50, 'Awaiting Refund');
      default:
        return (Colors.grey, Colors.grey.shade200, status);
    }
  }

  String _statusDisplayText(String status) {
    switch (status) {
      case 'COMING_SOON':
        return 'Coming Soon';
      case 'IS_HAPPENING':
        return 'Is Happening';
      case 'ENDED':
        return 'Ended';
      case 'CANCELLED':
        return 'Cancelled';
      case 'AWAITING_REFUND':
        return 'Awaiting Refund';
      default:
        return status;
    }
  }
}

class _ServiceAssignList extends StatelessWidget {
  final List<ServiceAssign> items;
  const _ServiceAssignList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final it = items[index];
        final price = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(it.serviceFee);
        final (tagColor, tagBg) = _statusColor(it.status);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.build_circle_outlined, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(it.serviceName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('Phí dịch vụ: $price'),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  it.status,
                  style: TextStyle(color: tagColor, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  (Color, Color) _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return (Colors.green, Colors.green.shade50);
      case 'INACTIVE':
        return (Colors.grey, Colors.grey.shade200);
      default:
        return (Colors.blueGrey, Colors.blueGrey.shade50);
    }
  }
}

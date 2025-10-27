// lib/features/booking/presentation/widgets/booking_detail_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_status.dart';

// ==== ĐIỀU HƯỚNG SANG SERVICE-ASSIGN (DI cục bộ) ====
import 'service_assign_page.dart';
import '../../presentation/providers/service_assign_provider.dart';
import '../../domain/usecases/get_service_assigns_by_studio_assign_usecase.dart';
import '../../../booking/data/repositories/service_assign_repository_impl.dart';
import '../../../booking/data/datasources/service_assign_remote_data_source_impl.dart';

// ==== SECTION PAYMENT (mới, Clean Architecture) ====
import 'payment_section.dart';

// ==== Final Payment (Clean) ====
import '../../domain/usecases/create_final_payment_usecase.dart';
import '../../presentation/providers/final_payment_provider.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../data/datasources/payment_remote_data_source_impl.dart';
import '../../data/repositories/payment_repository_impl.dart';

// ==== Cấu hình chung ====
const _baseUrl = 'https://bookingstudioswd-be.onrender.com';
const _cachedTokenKey = 'CACHED_TOKEN';

// ==== Model tạm cho assign (đủ dùng cho UI) ====
class _AssignItem {
  final String id;
  final String bookingId;
  final String studioId;
  final String studioName;
  final String locationName;
  final DateTime startTime;
  final DateTime endTime;
  final int studioAmount;
  final int serviceAmount;
  final int? additionTime; // có thể null
  final String status; // COMING_SOON / IS_HAPPENING / IN_PROGRESS / ENDED ...
  final int? updatedAmount;

  _AssignItem({
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

  factory _AssignItem.fromJson(Map<String, dynamic> json) {
    return _AssignItem(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      studioId: json['studioId'] as String,
      studioName: json['studioName'] as String,
      locationName: json['locationName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      studioAmount: (json['studioAmount'] as num).toInt(),
      serviceAmount: (json['serviceAmount'] as num).toInt(),
      additionTime: json['additionTime'] == null ? null : (json['additionTime'] as num).toInt(),
      status: json['status'] as String,
      updatedAmount: json['updatedAmount'] == null ? null : (json['updatedAmount'] as num).toInt(),
    );
  }
}

class BookingDetailPage extends StatefulWidget {
  final Booking booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  late Future<List<_AssignItem>> _futureAssigns;
  int _reloadTick = 0; // ép rebuild PaymentSection sau khi back/tạo final

  // chọn method cho Final Payment (mặc định VNPAY)
  String _finalMethod = 'VNPAY';

  @override
  void initState() {
    super.initState();
    _futureAssigns = _fetchAssigns(widget.booking.id);
  }

  // ==== Fetch assigns theo bookingId, dùng Bearer JWT từ SecureStorage ====
  Future<List<_AssignItem>> _fetchAssigns(String bookingId) async {
    try {
      final storage = const FlutterSecureStorage();
      final jsonString = await storage.read(key: _cachedTokenKey);
      if (jsonString == null) {
        throw Exception('No cached token');
      }
      final map = json.decode(jsonString) as Map<String, dynamic>;
      final raw = map['data'] ?? map['jwt'];
      if (raw is! String || raw.isEmpty) {
        throw Exception('Invalid cached token structure');
      }
      final jwt = raw;

      final url = Uri.parse('$_baseUrl/api/studio-assigns/booking/$bookingId');
      debugPrint('[Assigns] GET: $url');

      final resp = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $jwt',
      });

      debugPrint('[Assigns] Status: ${resp.statusCode}');
      if (resp.statusCode != 200) {
        debugPrint('[Assigns] ERROR body: ${resp.body}');
        throw Exception('HTTP ${resp.statusCode}');
      }

      // JSON guard
      final contentType = (resp.headers['content-type'] ?? '').toLowerCase();
      final bodyStart = resp.body.trimLeft();
      final looksLikeHtml = bodyStart.startsWith('<!DOCTYPE') || bodyStart.startsWith('<html');
      if (!contentType.contains('application/json') || looksLikeHtml) {
        debugPrint('[Assigns] Not JSON content.');
        throw Exception('Non-JSON content');
      }

      final Map<String, dynamic> jsonResponse = json.decode(resp.body);
      final data = jsonResponse['data'];
      if (data is! List) {
        debugPrint('[Assigns] "data" is not a List. body=${resp.body}');
        throw Exception('Invalid data');
      }

      final items = data
          .map<_AssignItem>((e) => _AssignItem.fromJson(e as Map<String, dynamic>))
          .toList();
      debugPrint('[Assigns] Parsed ${items.length} assigns.');
      return items;
    } catch (e) {
      debugPrint('[Assigns] Unknown error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFF4F6F9);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Chi tiết Booking"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomerCard(context),
            const SizedBox(height: 16),
            _buildBookingInfoCard(context),
            const SizedBox(height: 16),
            _buildAssignsSection(context),
            const SizedBox(height: 16),

            // CŨ (giữ cho tương thích UI cũ)
            _buildPaymentSection(context),
            const SizedBox(height: 16),

            // MỚI: Tạo Final Payment
            _buildFinalPaymentCreator(context),
            const SizedBox(height: 16),

            // Danh sách payment thực
            PaymentSection(
              key: ValueKey(_reloadTick),
              bookingId: widget.booking.id,
            ),
          ],
        ),
      ),
    );
  }

  // ====== Final Payment Card ======
  Widget _buildFinalPaymentCreator(BuildContext context) {
    // Local DI
    final remote = PaymentRemoteDataSourceImpl(
      client: http.Client(),
      secureStorage: const FlutterSecureStorage(),
    );
    final PaymentRepository repo = PaymentRepositoryImpl(remote: remote);
    final usecase = CreateFinalPaymentUsecase(repo);

    return ChangeNotifierProvider<FinalPaymentProvider>(
      create: (_) => FinalPaymentProvider(usecase: usecase),
      child: Consumer<FinalPaymentProvider>(
        builder: (_, prov, __) {
          final isLoading = prov.state == FinalPaymentState.loading;
          final hasResult = prov.state == FinalPaymentState.success && prov.finalPayment != null;
          final fp = prov.finalPayment;

          return Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tạo thanh toán cuối (Final Payment)",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 24),

                  Row(
                    children: [
                      const Icon(Icons.payment_outlined, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _finalMethod,
                          decoration: const InputDecoration(
                            labelText: 'Phương thức',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'VNPAY', child: Text('VNPay')),
                            DropdownMenuItem(value: 'MOMO', child: Text('MoMo')),
                            DropdownMenuItem(value: 'CASH', child: Text('Tiền mặt')),
                          ],
                          onChanged: isLoading ? null : (v) {
                            if (v != null) setState(() => _finalMethod = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: isLoading
                            ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Icon(Icons.add_card_outlined),
                        label: Text(isLoading ? 'Đang tạo...' : 'Tạo Final'),
                        onPressed: isLoading ? null : () async {
                          await prov.create(
                            bookingId: widget.booking.id,
                            paymentMethod: _finalMethod,
                          );
                          if (!mounted) return;

                          if (prov.state == FinalPaymentState.success) {
                            setState(() {
                              _reloadTick++; // reload list payments
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã tạo thanh toán cuối.')),
                            );
                          } else if (prov.state == FinalPaymentState.error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(prov.message)),
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  if (prov.state == FinalPaymentState.error) ...[
                    const SizedBox(height: 12),
                    Text(prov.message, style: const TextStyle(color: Colors.red)),
                  ],

                  if (hasResult) ...[
                    const SizedBox(height: 16),
                    const Divider(height: 16),
                    _buildInfoRow(
                      Icons.monetization_on_outlined,
                      'Số tiền còn thiếu: ${NumberFormat.currency(locale: "vi_VN", symbol: "đ").format(fp!.amountDue)}',
                    ),
                    const SizedBox(height: 6),
                    _buildInfoRow(Icons.account_balance_wallet_outlined, 'Phương thức: ${_displayMethod(fp.paymentMethod)}'),
                    const SizedBox(height: 6),
                    _buildInfoRow(Icons.info_outline, 'Trạng thái tạo: ${_displayPaymentStatus(fp.status)}'),
                    if (fp.paymentUrl != null && fp.paymentUrl!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _buildInfoRow(Icons.link, 'Liên kết thanh toán: ${fp.paymentUrl}'),
                      // Có thể dùng url_launcher để mở link
                    ],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _displayMethod(String raw) {
    switch (raw.toLowerCase()) {
      case 'vnpay': return 'VNPay';
      case 'momo':  return 'MoMo';
      case 'cash':  return 'Tiền mặt';
      default:      return raw.toUpperCase();
    }
  }

  String _displayPaymentStatus(String raw) {
    switch (raw.toUpperCase()) {
      case 'PENDING': return 'Chờ xử lý';
      case 'SUCCESS': return 'Thành công';
      case 'FAILED':  return 'Thất bại';
      default:        return raw;
    }
  }

  // ====== UI cũ giữ nguyên ======

  Widget _buildCustomerCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.booking.customerName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.email_outlined, widget.booking.accountEmail),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone_outlined, widget.booking.phone ?? "Chưa có SĐT"),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingInfoCard(BuildContext context) {
    Color statusColor;
    String statusText;
    switch (widget.booking.status) {
      case BookingStatus.inProgress:
        statusColor = Colors.blue;
        statusText = "Đang thực hiện";
        break;
      case BookingStatus.completed:
        statusColor = Colors.green;
        statusText = "Hoàn tất";
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        statusText = "Đã hủy";
        break;
      case BookingStatus.awaitingRefund:
        statusColor = Colors.deepPurple;
        statusText = "Chờ hoàn tiền";
        break;
      default:
        statusColor = Colors.grey;
        statusText = "Không rõ";
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Thông tin Lịch đặt",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.music_note_outlined, widget.booking.studioName),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.category_outlined, widget.booking.studioTypeName),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              DateFormat('dd/MM/yyyy').format(widget.booking.bookingDate),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time_outlined,
              DateFormat('HH:mm').format(widget.booking.bookingDate),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.article_outlined,
              widget.booking.note ?? "Không có ghi chú",
            ),
          ],
        ),
      ),
    );
  }

  // ====== Khu vực ASSIGNS (có điều hướng) ======
  Widget _buildAssignsSection(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Phân bổ phòng & thời gian",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            FutureBuilder<List<_AssignItem>>(
              future: _futureAssigns,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Không tải được danh sách phân bổ: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                final items = snapshot.data ?? const <_AssignItem>[];
                if (items.isEmpty) {
                  return const Text('Chưa có phân bổ cho lịch đặt này.');
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final it = items[index];
                    final timeRange =
                        '${DateFormat('dd/MM/yyyy HH:mm').format(it.startTime)} → ${DateFormat('dd/MM/yyyy HH:mm').format(it.endTime)}';
                    final price = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                        .format(it.studioAmount + it.serviceAmount);
                    final (badgeColor, badgeBg, badgeText) = _statusStyle(it.status);

                    return InkWell(
                      onTap: () async {
                        // DI cục bộ cho ServiceAssignPage
                        final remote = ServiceAssignRemoteDataSourceImpl(
                          client: http.Client(),
                          secureStorage: const FlutterSecureStorage(),
                        );
                        final repo = ServiceAssignRepositoryImpl(remote: remote);
                        final usecase = GetServiceAssignsByStudioAssign(repo);

                        // Gói thông tin assign
                        final assignSummary = AssignSummary(
                          id: it.id,
                          bookingId: it.bookingId,
                          studioId: it.studioId,
                          studioName: it.studioName,
                          locationName: it.locationName,
                          startTime: it.startTime,
                          endTime: it.endTime,
                          studioAmount: it.studioAmount,
                          serviceAmount: it.serviceAmount,
                          additionTime: it.additionTime,
                          status: it.status,
                          updatedAmount: it.updatedAmount,
                        );

                        final changed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider<ServiceAssignProvider>(
                              create: (_) => ServiceAssignProvider(getUsecase: usecase),
                              child: ServiceAssignPage(
                                studioAssignId: it.id,
                                assign: assignSummary,
                              ),
                            ),
                          ),
                        );

                        if (changed == true && mounted) {
                          setState(() {
                            _futureAssigns = _fetchAssigns(widget.booking.id);
                            _reloadTick++; // ép reload PaymentSection
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: StudioName + Status badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    it.studioName,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                                  child: Text(
                                    badgeText,
                                    style: TextStyle(color: badgeColor, fontWeight: FontWeight.w600, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            _buildInfoRow(Icons.place_outlined, it.locationName),
                            const SizedBox(height: 6),
                            _buildInfoRow(Icons.access_time, timeRange),
                            const SizedBox(height: 6),
                            _buildInfoRow(Icons.monetization_on_outlined, price),
                            if (it.updatedAmount != null) ...[
                              const SizedBox(height: 6),
                              _buildInfoRow(
                                Icons.price_change_outlined,
                                'Bổ sung: ${NumberFormat.currency(locale: "vi_VN", symbol: "đ").format(it.updatedAmount)}',
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Map status string -> badge
  (Color, Color, String) _statusStyle(String status) {
    switch (status) {
      case 'COMING_SOON':
        return (Colors.orange, Colors.orange.shade50, 'Sắp diễn ra');
      case 'IS_HAPPENING':
      case 'IN_PROGRESS':
        return (Colors.blue, Colors.blue.shade50, 'Đang diễn ra');
      case 'ENDED':
        return (Colors.green, Colors.green.shade50, 'Đã kết thúc');
      case 'CANCELLED':
        return (Colors.red, Colors.red.shade50, 'Đã hủy');
      case 'AWAITING_REFUND':
        return (Colors.deepPurple, Colors.deepPurple.shade50, 'Chờ hoàn tiền');
      default:
        return (Colors.grey, Colors.grey.shade200, status);
    }
  }

  // (GIỮ NGUYÊN) Section thanh toán cũ
  Widget _buildPaymentSection(BuildContext context) {
    final priceString = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(widget.booking.total);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Thông tin Thanh toán",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.monetization_on_outlined, color: Colors.green),
              title: const Text("Tổng tiền"),
              trailing: Text(
                priceString,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.credit_card_outlined, color: Colors.grey),
              title: const Text("Phương thức thanh toán"),
              trailing: const Text("Đang tải...", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 15, color: Colors.black87)),
        ),
      ],
    );
  }
}

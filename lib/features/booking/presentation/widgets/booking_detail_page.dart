// lib/features/booking/presentation/widgets/booking_detail_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/entities/payment.dart';

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

// ==== Trang cập nhật status payment (mới) ====
import 'payment_status_page.dart';

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

  /// Tổng tiền hiện tại tính từ assigns mới nhất
  int _currentTotal = 0;

  /// Trạng thái tổng của booking (badge ở "Thông tin Lịch đặt")
  late BookingStatus _bookingStatus;

  int _reloadTick = 0; // ép rebuild PaymentSection sau khi back/tạo final

  // chọn method cho Final Payment (mặc định VNPAY)
  String _finalMethod = 'VNPAY';

  // danh sách payment để hiển thị và điều hướng cập nhật
  late Future<List<Payment>> _futurePayments;

  @override
  void initState() {
    super.initState();
    _currentTotal = widget.booking.total;
    _bookingStatus = widget.booking.status;

    _futureAssigns = _fetchAssigns(widget.booking.id);
    _futurePayments = _fetchPayments(widget.booking.id);

    _reloadBookingStatusFromServer();
  }

  /// Map status raw từ BE -> enum BookingStatus
  BookingStatus _mapApiStatus(String raw) {
    final s = (raw.trim()).toUpperCase();
    switch (s) {
      case 'IN_PROGRESS':
      case 'IS_HAPPENING':
      case 'COMING_SOON':
        return BookingStatus.inProgress;
      case 'CONFIRMED':
        return BookingStatus.confirmed;
      case 'COMPLETED':
      case 'DONE':
        return BookingStatus.completed;
      case 'CANCELLED':
        return BookingStatus.cancelled;
      case 'AWAITING_REFUND':
        return BookingStatus.awaitingRefund;
      case 'AWAITING_PAYMENT':
        return BookingStatus.awaitingPayment;
      default:
        return BookingStatus.unknown;
    }
  }

  Future<void> _refreshAll() async {
    setState(() {
      _futureAssigns = _fetchAssigns(widget.booking.id);
      _futurePayments = _fetchPayments(widget.booking.id);
      _reloadTick++; // ép PaymentSection reload
    });
    await _reloadBookingStatusFromServer();
  }

  int _calcTotalFromAssigns(List<_AssignItem> items) {
    int sum = 0;
    for (final it in items) {
      sum += it.studioAmount;
      sum += it.serviceAmount;
      if (it.updatedAmount != null) sum += it.updatedAmount!;
    }
    return sum;
  }

  Future<List<_AssignItem>> _fetchAssigns(String bookingId) async {
    try {
      final storage = const FlutterSecureStorage();
      final jsonString = await storage.read(key: _cachedTokenKey);
      if (jsonString == null) throw Exception('No cached token');
      final map = json.decode(jsonString) as Map<String, dynamic>;
      final raw = map['data'] ?? map['jwt'];
      if (raw is! String || raw.isEmpty) throw Exception('Invalid token');
      final jwt = raw;

      final url = Uri.parse('$_baseUrl/api/studio-assigns/booking/$bookingId');
      final resp = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $jwt',
      });

      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}');
      }

      final contentType = (resp.headers['content-type'] ?? '').toLowerCase();
      final bodyStart = resp.body.trimLeft();
      final looksLikeHtml = bodyStart.startsWith('<!DOCTYPE') || bodyStart.startsWith('<html');
      if (!contentType.contains('application/json') || looksLikeHtml) {
        throw Exception('Non-JSON content');
      }

      final Map<String, dynamic> jsonResponse = json.decode(resp.body);
      final data = jsonResponse['data'];
      if (data is! List) throw Exception('Invalid data');

      final items = data
          .map<_AssignItem>((e) => _AssignItem.fromJson(e as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          _currentTotal = items.isEmpty ? widget.booking.total : _calcTotalFromAssigns(items);
        });
      }

      return items;
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy list payments của booking (để hiển thị và bấm “Cập nhật” đi trang khác)
  Future<List<Payment>> _fetchPayments(String bookingId) async {
    final storage = const FlutterSecureStorage();
    final jsonString = await storage.read(key: _cachedTokenKey);
    if (jsonString == null) throw Exception('No cached token');
    final map = json.decode(jsonString) as Map<String, dynamic>;
    final raw = map['data'] ?? map['jwt'];
    if (raw is! String || raw.isEmpty) throw Exception('Invalid token');
    final jwt = raw;

    // Endpoint staff đồng bộ với DataSource bạn đã dùng
    final url = Uri.parse('$_baseUrl/api/payments/staff/booking/$bookingId');
    final resp = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $jwt',
    });

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }

    final contentType = (resp.headers['content-type'] ?? '').toLowerCase();
    final bodyStart = resp.body.trimLeft();
    final looksLikeHtml = bodyStart.startsWith('<!DOCTYPE') || bodyStart.startsWith('<html');
    if (!contentType.contains('application/json') || looksLikeHtml) {
      throw Exception('Non-JSON content');
    }

    final Map<String, dynamic> jsonResponse = json.decode(resp.body);
    final data = jsonResponse['data'];
    if (data is! List) throw Exception('Invalid data');

    return data.map<Payment>((e) {
      final j = e as Map<String, dynamic>;
      return Payment(
        id: j['id'] as String,
        paymentMethod: j['paymentMethod'] as String,
        status: j['status'] as String,
        paymentType: j['paymentType'] as String,
        paymentDate: DateTime.parse(j['paymentDate'] as String),
        amount: (j['amount'] as num).toInt(),
        bookingId: j['bookingId'] as String,
        bookingStatus: j['bookingStatus'] as String,
        accountEmail: j['accountEmail'] as String,
        accountName: j['accountName'] as String,
      );
    }).toList();
  }

  Future<void> _reloadBookingStatusFromServer() async {
    try {
      final storage = const FlutterSecureStorage();
      final jsonString = await storage.read(key: _cachedTokenKey);
      if (jsonString == null) throw Exception('No cached token');
      final map = json.decode(jsonString) as Map<String, dynamic>;
      final raw = map['data'] ?? map['jwt'];
      if (raw is! String || raw.isEmpty) throw Exception('Invalid token');
      final jwt = raw;

      final url = Uri.parse('$_baseUrl/api/bookings/${widget.booking.id}');
      final resp = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $jwt',
      });
      if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');

      final contentType = (resp.headers['content-type'] ?? '').toLowerCase();
      final bodyStart = resp.body.trimLeft();
      final looksLikeHtml = bodyStart.startsWith('<!DOCTYPE') || bodyStart.startsWith('<html');
      if (!contentType.contains('application/json') || looksLikeHtml) throw Exception('Non-JSON');

      final Map<String, dynamic> jsonResponse = json.decode(resp.body);
      final data = jsonResponse['data'];
      if (data is! Map<String, dynamic>) throw Exception('Invalid data');

      final rawStatus = (data['status'] as String?) ?? '';
      final mapped = _mapApiStatus(rawStatus);

      if (!mounted) return;
      if (rawStatus.trim().isNotEmpty && mapped != BookingStatus.unknown) {
        setState(() => _bookingStatus = mapped);
      }
    } catch (_) {
      // ignore
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
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAll,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

              // CŨ (giữ cho tương thích UI cũ) — dùng _currentTotal (đã cập nhật)
              _buildPaymentSection(context),
              const SizedBox(height: 16),

              // MỚI: Tạo Final Payment
              _buildFinalPaymentCreator(context),
              const SizedBox(height: 16),

              // Danh sách payment thực (widget cũ)
              PaymentSection(
                key: ValueKey(_reloadTick),
                bookingId: widget.booking.id,
              ),

              const SizedBox(height: 16),

              // ✅ Danh sách payment để điều hướng sang trang cập nhật — UI đẹp
              _buildPaymentsNavigator(context),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Helpers cho Payment UI =====
  Color _payStatusColor(String s) {
    switch (s.toUpperCase()) {
      case 'SUCCESS':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      case 'PENDING':
      default:
        return Colors.orange;
    }
  }

  String _payStatusLabelVi(String s) {
    switch (s.toUpperCase()) {
      case 'SUCCESS':
        return 'Thành công';
      case 'FAILED':
        return 'Thất bại';
      case 'PENDING':
      default:
        return 'Chờ xử lý';
    }
  }

  String _payTypeLabelVi(String t) {
    switch (t.toUpperCase()) {
      case 'DEPOSIT':
        return 'Đặt cọc';
      case 'FULL_PAYMENT':
        return 'Thanh toán đủ';
      case 'FINAL':
        return 'Thanh toán cuối';
      default:
        return t.toUpperCase();
    }
  }

  String _payMethodLabel(String m) {
    switch (m.toUpperCase()) {
      case 'MOMO':
        return 'MoMo';
      case 'VNPAY':
        return 'VNPay';
      case 'CASH':
        return 'Tiền mặt';
      default:
        return m.toUpperCase();
    }
  }

  IconData _payMethodIcon(String m) {
    switch (m.toUpperCase()) {
      case 'MOMO':
        return Icons.phone_iphone_rounded;
      case 'VNPAY':
        return Icons.account_balance_rounded;
      case 'CASH':
        return Icons.payments_rounded;
      default:
        return Icons.credit_card_rounded;
    }
  }

  Widget _chip(String text, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }

  // Danh sách payments + nút điều hướng “Cập nhật trạng thái” (UI đẹp hơn)
  Widget _buildPaymentsNavigator(BuildContext context) {
    final accent = const Color(0xFF6A40D3);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long_outlined, color: accent),
                const SizedBox(width: 8),
                Text(
                  "Thanh toán của booking",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            FutureBuilder<List<Payment>>(
              future: _futurePayments,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) {
                  return Text(
                    'Không tải được danh sách: ${snap.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                }
                final list = snap.data ?? const <Payment>[];
                if (list.isEmpty) {
                  return const Text('Chưa có thanh toán nào.');
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final p = list[i];
                    final methodIcon = _payMethodIcon(p.paymentMethod);
                    final methodLabel = _payMethodLabel(p.paymentMethod);
                    final statusColor = _payStatusColor(p.status);
                    final statusBg = statusColor.withOpacity(.12);
                    final typeLabel = _payTypeLabelVi(p.paymentType);
                    final amountStr = NumberFormat.currency(locale: "vi_VN", symbol: "đ").format(p.amount);
                    final timeStr = DateFormat('dd/MM/yyyy HH:mm').format(p.paymentDate);

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar phương thức
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: accent.withOpacity(.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(methodIcon, color: accent),
                          ),
                          const SizedBox(width: 12),

                          // Nội dung chính
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Dòng 1: Method + Amount
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        methodLabel,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '• $amountStr',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Dòng 2: Chips trạng thái & loại
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _chip(_payStatusLabelVi(p.status), statusColor, statusBg),
                                    _chip(typeLabel, Colors.blue, Colors.blue.withOpacity(.1)),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Dòng 3: Thời gian
                                Row(
                                  children: [
                                    const Icon(Icons.schedule_rounded, size: 14, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        timeStr,
                                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // Dòng 4: Booking status (raw)
                                Row(
                                  children: [
                                    const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Booking: ${p.bookingStatus.toUpperCase()}',
                                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // Dòng 5: Mã payment
                                Row(
                                  children: [
                                    const Icon(Icons.tag_outlined, size: 14, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Mã: ${p.id}',
                                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Nút cập nhật
                          Column(
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('Cập nhật'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () async {
                                  final changed = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PaymentStatusPage(payment: p),
                                    ),
                                  );
                                  if (changed == true && mounted) {
                                    await _refreshAll();
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
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

    switch (_bookingStatus) {
      case BookingStatus.inProgress:
        statusColor = Colors.blue;
        statusText = "Đang thực hiện";
        break;
      case BookingStatus.confirmed:
        statusColor = Colors.teal;
        statusText = "Đã xác nhận";
        break;
      case BookingStatus.completed:
        statusColor = Colors.green;
        statusText = "Hoàn tất";
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        statusText = "Đã hủy";
        break;
      case BookingStatus.awaitingPayment:
        statusColor = Colors.orange;
        statusText = "Chờ thanh toán";
        break;
      case BookingStatus.awaitingRefund:
        statusColor = Colors.deepPurple;
        statusText = "Chờ hoàn tiền";
        break;
      case BookingStatus.unknown:
        statusColor = Colors.grey;
        statusText = "Không rõ";
        break;
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
                        .format(it.studioAmount + it.serviceAmount + (it.updatedAmount ?? 0));
                    final (badgeColor, badgeBg, badgeText) = _statusStyle(it.status);

                    return InkWell(
                      onTap: () async {
                        final remote = ServiceAssignRemoteDataSourceImpl(
                          client: http.Client(),
                          secureStorage: const FlutterSecureStorage(),
                        );
                        final repo = ServiceAssignRepositoryImpl(remote: remote);
                        final usecase = GetServiceAssignsByStudioAssign(repo);

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
                          await _refreshAll();
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

  // (GIỮ NGUYÊN) Section thanh toán tổng quan — nhưng dùng _currentTotal đã cập nhật
  Widget _buildPaymentSection(BuildContext context) {
    final priceString = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(_currentTotal);

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

  Widget _buildFinalPaymentCreator(BuildContext context) {
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
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Icon(Icons.add_card_outlined),
                        label: Text(isLoading ? 'Đang tạo...' : 'Tạo Final'),
                        onPressed: isLoading
                            ? null
                            : () async {
                          await prov.create(
                            bookingId: widget.booking.id,
                            paymentMethod: _finalMethod,
                          );
                          if (!mounted) return;

                          if (prov.state == FinalPaymentState.success) {
                            await _refreshAll();
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
      case 'vnpay':
        return 'VNPay';
      case 'momo':
        return 'MoMo';
      case 'cash':
        return 'Tiền mặt';
      default:
        return raw.toUpperCase();
    }
  }

  String _displayPaymentStatus(String raw) {
    switch (raw.toUpperCase()) {
      case 'PENDING':
        return 'Chờ xử lý';
      case 'SUCCESS':
        return 'Thành công';
      case 'FAILED':
        return 'Thất bại';
      default:
        return raw;
    }
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

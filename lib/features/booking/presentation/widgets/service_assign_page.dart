import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/service_assign_provider.dart';
import '../../domain/entities/service_assign.dart';

class ServiceAssignPage extends StatelessWidget {
  final String studioAssignId;
  final String? title;
  final String? subtitle;

  const ServiceAssignPage({
    super.key,
    required this.studioAssignId,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    // gọi fetch 1 lần khi build lần đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<ServiceAssignProvider>();
      if (prov.state == ServiceAssignState.initial) {
        prov.fetch(studioAssignId);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Dịch vụ của Studio Assign'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (title != null || subtitle != null)
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(title ?? 'Studio Assign', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: subtitle == null ? null : Text(subtitle!),
                ),
              ),
            const SizedBox(height: 12),

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
    );
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
                child: Text(it.status, style: TextStyle(color: tagColor, fontWeight: FontWeight.w600, fontSize: 12)),
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  void _showCancelTicketDialog(BuildContext context, String ticketId, String title) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16161F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 22),
              SizedBox(width: 8),
              Text('XÁC NHẬN HỦY VÉ', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn hủy vé bộ phim "$title" không? Hệ thống sẽ tự động hoàn tiền và gửi thông báo xác nhận về hộp thư của bạn.',
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('QUAY LẠI', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang xử lý hoàn vé và cập nhật hệ thống thông báo...')),
                );

                try {
                  // 1. Bắn thông báo hủy vé liên thông vào đúng bộ sưu tập 'user_notifications'
                  await FirebaseFirestore.instance.collection('user_notifications').add({
                    'title': 'HỦY VÉ HOÀN TIỀN THÀNH CÔNG 💸',
                    'content': 'Stella Cinema xác nhận yêu cầu hủy vé phim "$title" của Quý khách đã được phê duyệt thành công. Số tiền hoàn lại đã được gửi trả về tài khoản nguồn của bạn.',
                    'time': 'Vừa xong',
                    'type': 'system',
                    'isRead': false,
                    'created_at': Timestamp.now(),
                  });

                  // 2. Xóa tài liệu vé khỏi bộ sưu tập 'tickets'
                  await FirebaseFirestore.instance.collection('tickets').doc(ticketId).delete();

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã hủy vé thành công! Vui lòng kiểm tra Trung tâm thông báo. 🎉')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi hệ thống khi hủy vé: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('XÁC NHẬN HỦY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16161F),
        elevation: 0,
        centerTitle: true,
        title: const Text('KHO VÉ CỦA TÔI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tickets').orderBy('created_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.confirmation_number_outlined, color: Colors.white24, size: 54),
                  SizedBox(height: 12),
                  Text('Bạn chưa có vé nào trong kho lưu trữ.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            );
          }

          final tickets = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticketDoc = tickets[index];
              final ticketData = ticketDoc.data() as Map<String, dynamic>;

              final String ticketId = ticketDoc.id;
              final String title = ticketData['title'] ?? 'Phim Stella Cinema';
              final String posterUrl = ticketData['posterUrl'] ?? '';
              final List<dynamic> seats = ticketData['seats'] ?? [];
              final int amount = ticketData['total_amount'] ?? 0;
              final formatAmount = amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 200 + (index * 80)),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16161F),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16)),
                            child: posterUrl.isNotEmpty
                                ? Image.network(posterUrl, width: 85, height: 115, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 85, height: 115, color: const Color(0xFF222232), child: const Icon(Icons.movie, color: Colors.white24)))
                                : Container(width: 85, height: 115, color: const Color(0xFF222232), child: const Icon(Icons.movie, color: Colors.white24)),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 6),
                                  Text('Ghế ngồi: ${seats.join(", ")}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                                  const SizedBox(height: 6),
                                  Text('Tổng tiền: $formatAmount đ', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: const BoxDecoration(color: Color(0xFF1E1E2A), borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Hệ thống rạp Stella Cinema', style: TextStyle(color: Colors.white38, fontSize: 10, fontStyle: FontStyle.italic)),
                            TextButton.icon(
                              onPressed: () => _showCancelTicketDialog(context, ticketId, title),
                              icon: const Icon(Icons.cancel_presentation_rounded, color: Colors.redAccent, size: 16),
                              label: const Text('HỦY VÉ', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'my_tickets_screen.dart'; // Đảm bảo đường dẫn này đúng với dự án của bạn

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> movieData;
  final List<String> selectedSeats;
  final int totalPrice;

  const PaymentScreen({
    super.key,
    required this.movieData,
    required this.selectedSeats,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF16161F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.lightGreenAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.lightGreenAccent, size: 48),
                ),
                const SizedBox(height: 20),
                const Text(
                  'THANH TOÁN THÀNH CÔNG',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Giao dịch của bạn đã hoàn tất. Vé xem phim đã được chuyển vào kho vé của bạn thành công!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MyTicketsScreen()),
                            (route) => route.isFirst,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('XEM KHO VÉ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleConfirmPayment() async {
    setState(() => _isProcessing = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.amber)),
    );

    try {
      final String movieTitle = widget.movieData['title'] ?? 'Phim Stella Cinema';
      final String posterUrl = widget.movieData['posterUrl'] ?? '';

      // 🔥 FIX CHÍ MẠNG 1: Đẩy dữ liệu vào kho vé 'tickets' như cũ
      await FirebaseFirestore.instance.collection('tickets').add({
        'title': movieTitle,
        'posterUrl': posterUrl,
        'seats': widget.selectedSeats,
        'total_amount': widget.totalPrice,
        'payment_status': 'COMPLETED',
        'created_at': Timestamp.now(),
      });

      // 🔥 FIX CHÍ MẠNG 2: Bắn liên thông ngay 1 thông báo đặt vé sang collection 'user_notifications'
      await FirebaseFirestore.instance.collection('user_notifications').add({
        'title': 'ĐẶT VÉ THÀNH CÔNG 🎉',
        'content': 'Chúc mừng Quý khách đã đặt thành công các ghế: ${widget.selectedSeats.join(", ")} cho bộ phim "$movieTitle". Xin vui lòng đến quầy nhận vé trước 15 phút.',
        'time': 'Vừa xong',
        'type': 'ticket',
        'isRead': false,
        'created_at': Timestamp.now(), // Thêm trường này để sắp xếp orderBy chuẩn đét
      });

      if (!mounted) return;
      Navigator.pop(context); // Tắt cổng xoay Loading

      // Hiện Popup thành công giữa màn hình sang chảnh
      _showSuccessDialog();

    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi liên thông Firebase: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatPrice = widget.totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16161F),
        title: const Text('QUÉT MÃ CHUYỂN KHOẢN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF16161F), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng tiền thanh toán:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text('$formatPrice đ', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text('QUÉT MÃ ĐỂ TỰ ĐỘNG LÀM LỆNH CHUYỂN TIỀN', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=247Banking_StellaCinema_Amount_$formatPrice',
                width: 180,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1E1E2A), borderRadius: BorderRadius.circular(12)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Ngân hàng: TPBank (Ngân hàng Tiên Phong)', style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.6)),
                  Text('• Số tài khoản: 0000 9999 888', style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.6)),
                  Text('• Tên tài khoản: STELLA CINEMA GROUP', style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.6)),
                ],
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handleConfirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('XÁC NHẬN ĐÃ CHUYỂN KHOẢN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
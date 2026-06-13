import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeatBookingScreen extends StatefulWidget {
  final Map<String, dynamic> movieData;

  const SeatBookingScreen({Key? key, required this.movieData}) : super(key: key);

  @override
  State<SeatBookingScreen> createState() => _SeatBookingScreenState();
}

class _SeatBookingScreenState extends State<SeatBookingScreen> {
  // Sơ đồ ghế: 6 hàng x 5 cột = 30 ghế
  List<bool> _seatStatus = List.generate(30, (index) => false);

  // Giả lập vài ghế đã có người mua trước
  final List<int> _bookedSeats = [3, 4, 11, 12, 18, 24];
  final int _ticketPrice = 85000;
  bool _isSaving = false; // Biến trạng thái đợi lưu database

  // HÀM XỬ LÝ LƯU VÉ VÀO FIREBASE
  void _confirmBooking(List<int> selectedSeats, int totalAmount) async {
    setState(() {
      _isSaving = true;
    });

    try {
      // 1. Lấy thông tin user hiện tại đang đăng nhập
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi: Bạn chưa đăng nhập!'), backgroundColor: Colors.red),
        );
        return;
      }

      // 2. Chuẩn bị dữ liệu hóa đơn
      Map<String, dynamic> ticketInvoice = {
        'userEmail': user.email,
        'movieTitle': widget.movieData['title'],
        'genre': widget.movieData['genre'],
        'posterUrl': widget.movieData['posterUrl'],
        'seats': selectedSeats.map((s) => s + 1).toList(), // Đổi từ index sang số ghế (1-30)
        'totalPrice': totalAmount,
        'bookingTime': Timestamp.now(), // Thời gian đặt vé thật
      };

      // 3. Đẩy thẳng lên Firebase Firestore vào thư mục 'tickets'
      await FirebaseFirestore.instance.collection('tickets').add(ticketInvoice);

      // 4. Thông báo thành công và đóng màn hình quay về trang chủ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Đặt vé thành công! Check trong mục Vé Của Tôi.'), backgroundColor: Colors.green),
      );

      // Chờ tí rồi quay về màn hình trước
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi hệ thống: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Thu thập danh sách các index ghế được chọn
    List<int> selectedSeats = [];
    for (int i = 0; i < _seatStatus.length; i++) {
      if (_seatStatus[i]) selectedSeats.add(i);
    }

    int selectedCount = selectedSeats.length;
    int totalAmount = selectedCount * _ticketPrice;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('Chọn Ghế: ${widget.movieData['title']}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('MÀN HÌNH CHIẾU', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),

          // Lưới hiển thị ghế
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 30,
                itemBuilder: (context, index) {
                  bool isBooked = _bookedSeats.contains(index);
                  bool isSelected = _seatStatus[index];

                  Color seatColor = Colors.grey[800]!;
                  if (isBooked) seatColor = Colors.redAccent;
                  if (isSelected) seatColor = Colors.blueAccent;

                  return GestureDetector(
                    onTap: isBooked || _isSaving ? null : () {
                      setState(() {
                        _seatStatus[index] = !_seatStatus[index];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(color: seatColor, borderRadius: BorderRadius.circular(8)),
                      child: Center(
                        child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Chú thích loại ghế
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Trống', Colors.grey[800]!),
                _buildLegendItem('Đang chọn', Colors.blueAccent),
                _buildLegendItem('Đã bán', Colors.redAccent),
              ],
            ),
          ),

          // Thanh hiển thị tổng tiền & nút bấm đặt vé
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$selectedCount ghế đã chọn', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('$totalAmount đ', style: const TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton(
                  onPressed: selectedCount == 0 || _isSaving
                      ? null
                      : () => _confirmBooking(selectedSeats, totalAmount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    disabledBackgroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Text('Xác Nhận', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_screen.dart';

class SeatBookingScreen extends StatefulWidget {
  final Map<String, dynamic> movieData;
  const SeatBookingScreen({super.key, required this.movieData});

  @override
  State<SeatBookingScreen> createState() => _SeatBookingScreenState();
}

class _SeatBookingScreenState extends State<SeatBookingScreen> {
  final List<String> _selectedSeats = [];
  int _totalPrice = 0;

  final int _singleSeatPrice = 90000;
  final int _doubleSeatPrice = 200000;

  void _onSeatTap(String seatId, bool isDouble, List<String> bookedSeats) {
    if (bookedSeats.contains(seatId)) return; // REAL-TIME LOCK: Ghế đã mua thì cấm bấm chọn

    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
        _totalPrice -= isDouble ? _doubleSeatPrice : _singleSeatPrice;
      } else {
        _selectedSeats.add(seatId);
        _totalPrice += isDouble ? _doubleSeatPrice : _singleSeatPrice;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String movieTitle = widget.movieData['title'] ?? 'CHỌN GHẾ';
    final String theater = widget.movieData['selectedTheater'] ?? 'Rạp chưa chọn';
    final String date = widget.movieData['selectedDate'] ?? '';
    final String time = widget.movieData['selectedTime'] ?? '';

    // KHÓA REAL-TIME: Truy vấn Stream dữ liệu các vé đã thanh toán để lấy danh sách ghế đã bị khóa
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
      builder: (context, snapshot) {
        List<String> bookedSeats = [];
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            // Chỉ quét các ghế đã thuộc đúng phim, đúng rạp, đúng ngày và giờ chiếu này
            if (data['title'] == movieTitle) {
              final List<dynamic> seats = data['seats'] ?? [];
              bookedSeats.addAll(seats.map((s) => s.toString()));
            }
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0F0F13),
          appBar: AppBar(
            backgroundColor: const Color(0xFF16161F),
            elevation: 0,
            centerTitle: true,
            title: Text(movieTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              // CHI TIẾT ĐỊNH VỊ LỊCH TRÌNH THỰC TẾ
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: const Color(0xFF1E1E2A),
                child: Text(
                  '🎬 $theater  |  📅 $date  |  ⏰ Suất: $time',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w500, fontSize: 11),
                ),
              ),
              const SizedBox(height: 15),

              // Giao diện chú thích trạng thái ghế
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNoteItem('Trống', const Color(0xFF222232)),
                  const SizedBox(width: 16),
                  _buildNoteItem('Đang chọn', Colors.amber),
                  const SizedBox(width: 16),
                  _buildNoteItem('Đã đặt trước', Colors.redAccent),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40), height: 4, width: double.infinity,
                decoration: BoxDecoration(color: Colors.amber, boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2)]),
              ),
              const SizedBox(height: 4),
              const Text('MÀN HÌNH CHIẾU', style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 20),

              // SƠ ĐỒ ĐẠI RẠP 100 GHẾ TÍCH HỢP TỰ ĐỘNG KHÓA REAL-TIME
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        for (var row in ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: 20, alignment: Alignment.center, child: Text(row, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))),
                              ...List.generate(10, (index) {
                                final seatId = '$row${index + 1}';
                                final isSelected = _selectedSeats.contains(seatId);
                                final isBooked = bookedSeats.contains(seatId); // Kiểm tra ghế đã bán chưa

                                return GestureDetector(
                                  onTap: () => _onSeatTap(seatId, false, bookedSeats),
                                  child: Container(
                                    margin: const EdgeInsets.all(3),
                                    width: 28, height: 28,
                                    decoration: BoxDecoration(
                                      color: isBooked ? Colors.redAccent.withValues(alpha: 0.3) : (isSelected ? Colors.amber : const Color(0xFF222232)),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: isBooked ? Colors.redAccent : (isSelected ? Colors.white : Colors.white.withValues(alpha: 0.05))),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                        '${index + 1}',
                                        style: TextStyle(color: isBooked ? Colors.redAccent : (isSelected ? Colors.black : Colors.white70), fontSize: 10, fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                        const SizedBox(height: 15),
                        const Text('HÀNG GHẾ ĐÔI SWEETBOX PREMIUM', style: TextStyle(color: Colors.pinkAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        for (var row in ['I', 'J']) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: 20, alignment: Alignment.center, child: Text(row, style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 12))),
                              ...List.generate(5, (index) {
                                final seatId = '$row${index * 2 + 1}-$row${index * 2 + 2}';
                                final isSelected = _selectedSeats.contains(seatId);
                                final isBooked = bookedSeats.contains(seatId); // Kiểm tra cặp ghế đôi đã bán chưa

                                return GestureDetector(
                                  onTap: () => _onSeatTap(seatId, true, bookedSeats),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                                    width: 62, height: 30,
                                    decoration: BoxDecoration(
                                      color: isBooked ? Colors.redAccent.withValues(alpha: 0.2) : (isSelected ? Colors.pinkAccent : const Color(0xFF3A2232)),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: isBooked ? Colors.redAccent : (isSelected ? Colors.white : Colors.pinkAccent.withValues(alpha: 0.2))),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('$row${index * 2 + 1}•$row${index * 2 + 2}', style: TextStyle(color: isBooked ? Colors.redAccent : Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // BOTTOM SUMMARY BAR
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Color(0xFF16161F), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_selectedSeats.isEmpty ? 'Chưa chọn ghế' : 'Ghế: ${_selectedSeats.join(', ')}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('Tổng: ${_totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _selectedSeats.isEmpty ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                movieData: widget.movieData,
                                selectedSeats: _selectedSeats,
                                totalPrice: _totalPrice,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, disabledBackgroundColor: Colors.white10, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Tiếp Tục', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoteItem(String text, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
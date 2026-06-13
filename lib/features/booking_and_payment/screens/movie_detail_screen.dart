import 'package:flutter/material.dart';
// Import màn hình chọn ghế
import 'seat_booking_screen.dart';

class MovieDetailScreen extends StatelessWidget {
  final Map<String, dynamic> movieData;

  const MovieDetailScreen({Key? key, required this.movieData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = movieData['title'] ?? 'Không có tên';
    final genre = movieData['genre'] ?? 'Chưa rõ';
    final rating = movieData['rating'] ?? '0.0';
    final posterUrl = movieData['posterUrl'] ?? '';
    final description = movieData['description'] ??
        'Bộ phim tâm lý kịch tính xuất sắc nhất năm, mang lại nhiều cung bậc cảm xúc cho khán giả với những cú twist bất ngờ và diễn xuất đỉnh cao của dàn diễn viên.';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: const Color(0xFF1E1E1E),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: posterUrl.isNotEmpty
                  ? Image.network(posterUrl, fit: BoxFit.cover)
                  : const Icon(Icons.movie, size: 100, color: Colors.white54),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          genre,
                          style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Nội dung phim',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 40),

                  // NÚT ĐẶT VÉ ĐÃ ĐƯỢC KÍCH HOẠT NHẢY TRANG
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        // Điều hướng sang màn hình SeatBookingScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SeatBookingScreen(movieData: movieData),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Đặt Vé Ngay',
                        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../booking_and_payment/screens/showtime_selection_screen.dart'; // ĐÃ IMPORT: Màn hình chọn Rạp/Ngày/Suất chiếu trung gian
import '../../booking_and_payment/screens/my_tickets_screen.dart';
import '../../notifications/screens/notification_screen.dart';
import '../../chat_ai/screens/cinema_ai_chatbot_screen.dart';
import '../../maps/screens/theater_maps_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;

  final List<String> bannerImages = [
    'https://galaxycine.vn/_next/image?url=https%3A%2F%2Fcdn.galaxycine.vn%2Fmedia%2F2024%2F2%2F20%2Ftai-tu-dien-trai-lee-do-hyun-khien-fan-viet-dung-ngoi-khong-yen-trong-quat-mo-trung-doc-1_1708422340574.jpg&w=1920&q=75',
    'https://galaxycine.vn/_next/image?url=https%3A%2F%2Fcdn.galaxycine.vn%2Fmedia%2F2024%2F1%2F25%2Fmai-1_1706173004810.jpg&w=1920&q=75',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _autoScrollBanners();
  }

  void _autoScrollBanners() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      if (_bannerController.hasClients) {
        _currentBannerIndex = (_currentBannerIndex + 1) % bannerImages.length;
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
        _autoScrollBanners();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('S', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14)),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'STELLA',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16161F),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on_rounded, color: Colors.lightGreenAccent, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TheaterMapsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.psychology_rounded, color: Colors.cyanAccent, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CinemaAiChatbotScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white70, size: 26),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.confirmation_number_rounded, color: Colors.amber, size: 24),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyTicketsScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Container(
                height: 180,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                clipBehavior: Clip.antiAlias,
                child: PageView.builder(
                  controller: _bannerController,
                  itemCount: bannerImages.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      bannerImages[index],
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: const Color(0xFF222232),
                        child: const Icon(Icons.movie_creation_rounded, color: Colors.white30, size: 40),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.amber,
                  indicatorWeight: 3,
                  labelColor: Colors.amber,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Đang Chiếu'),
                    Tab(text: 'Sắp Chiếu'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMovieGrid(isShowingNow: true),
            _buildMovieGrid(isShowingNow: false),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieGrid({required bool isShowingNow}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('movies').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.amber));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Không có phim nào khả dụng.', style: TextStyle(color: Colors.grey)));
        }

        final allMovies = snapshot.data!.docs;
        final movies = isShowingNow
            ? allMovies.sublist(0, (allMovies.length / 2).ceil())
            : allMovies.sublist((allMovies.length / 2).ceil());

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: movies.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 16,
            childAspectRatio: 0.58,
          ),
          itemBuilder: (context, index) {
            final movieData = movies[index].data() as Map<String, dynamic>;
            final title = movieData['title'] ?? 'Phim không tên';
            final genre = movieData['genre'] ?? 'Hành Động';
            final rating = movieData['rating'] ?? '9.8';
            final posterUrl = movieData['posterUrl'] ?? '';

            return GestureDetector(
              onTap: () {
                // ĐÃ ĐỒNG BỘ: Bấm vào thẻ phim sẽ chuyển sang trang chọn rạp/suất chiếu trung gian
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShowtimeSelectionScreen(movieData: movieData)),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF16161F),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 3))],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: posterUrl.isNotEmpty
                                ? Image.network(posterUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.movie, size: 50, color: Colors.white24))
                                : const Icon(Icons.movie, size: 50, color: Colors.white24),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                              child: const Text('2D | SUB', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                                  const SizedBox(width: 2),
                                  Text(rating, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            genre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // ĐÃ ĐỒNG BỘ: Bấm vào nút Mua vé cũng chuyển sang trang chọn rạp/suất chiếu trung gian
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ShowtimeSelectionScreen(movieData: movieData)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text('Mua Vé', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
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
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF0F0F13),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
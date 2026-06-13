import 'package:flutter/material.dart';

class CinemaAiChatbotScreen extends StatefulWidget {
  const CinemaAiChatbotScreen({super.key});

  @override
  State<CinemaAiChatbotScreen> createState() => _CinemaAiChatbotScreenState();
}

class _CinemaAiChatbotScreenState extends State<CinemaAiChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Danh sách tin nhắn giả lập chạy thời gian thực trên ứng dụng di động
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'ai',
      'text': 'Xin chào ní! Tôi là Trợ lý AI của Galaxy Cinema G5. Hôm nay ní muốn tìm phim gì để giải trí nào? 🎬'
    },
  ];

  // Logic phản hồi của AI dựa trên từ khóa hệ thống
  String _getAiResponse(String userText) {
    String text = userText.toLowerCase();

    if (text.contains('phim') && (text.contains('hot') || text.contains('hay'))) {
      return 'Hiện tại rạp đang cháy vé phim "Mai" của Trấn Thành (Tâm lý, Tình cảm - 8.5★). Ní có muốn tôi dẫn thẳng ra trang đặt vé luôn không? 🔥';
    } else if (text.contains('giá vé') || text.contains('bao nhiêu') || text.contains('tiền')) {
      return 'Dạ giá vé chuẩn hệ thống: Ghế Thường là 90k, Ghế VIP góc rộng là 110k, còn Cặp ghế đôi Sweetbox cuối rạp cho người yêu là 250k nhé ní! 🎫';
    } else if (text.contains('km') || text.contains('khuyến mãi') || text.contains('ưu đãi')) {
      return 'Hôm nay đang có chương trình đồng giá vé 70k cho học sinh sinh viên khi mua vé trước 12h trưa đó ní ơi! 🎁';
    } else if (text.contains('bảo mật') || text.contains('otp')) {
      return 'Hệ thống G5 sở hữu cơ chế bảo mật tối cao, tích hợp mã OTP gửi thẳng về Email cá nhân khi ní thực hiện thanh toán trực tuyến qua Ví MoMo hoặc cổng VNPAY nha!';
    }

    return 'Dạ tôi đã ghi nhận ý kiến của ní. Ní có thể hỏi thêm về "Phim hay hiện nay", "Giá vé rạp" hoặc các cổng "Thanh toán bảo mật OTP" để tôi tư vấn rõ hơn nhé! Đồ án Group 5 bao mượt!';
  }

  void _sendMessage() {
    final String text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _messageController.clear();
    });

    // Tự động cuộn xuống dưới cùng khi người dùng gửi tin nhắn
    _scrollToBottom();

    // Giả lập hệ thống AI suy nghĩ một chút rồi phản hồi mượt mà
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'ai',
          'text': _getAiResponse(text),
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13), // Đồng bộ nền tối với toàn hệ thống
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
              child: const Icon(Icons.psychology_rounded, color: Colors.black, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TRỢ LÝ AI TƯ VẤN', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Trực tuyến thời gian thực', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16161F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Khu vực hiển thị nội dung đoạn hội thoại chat
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final chat = _messages[index];
                bool isAi = chat['sender'] == 'ai';

                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isAi ? const Color(0xFF16161F) : Colors.amber,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isAi ? 0 : 16),
                        bottomRight: Radius.circular(isAi ? 16 : 0),
                      ),
                      border: isAi ? Border.all(color: Colors.white10, width: 0.5) : null,
                    ),
                    child: Text(
                      chat['text']!,
                      style: TextStyle(
                        color: isAi ? Colors.white70 : Colors.black, // ĐÃ SỬA: Thay thế whiteEE thành white70 chuẩn chỉ
                        fontSize: 13,
                        fontWeight: isAi ? FontWeight.normal : FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Thanh nhập nội dung tin nhắn dưới đáy màn hình di động
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Color(0xFF16161F)),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Nhắn tin hỏi AI phim hay, giá vé...',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF0F0F13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: const CircleAvatar(
                      backgroundColor: Colors.amber,
                      radius: 20,
                      child: Icon(Icons.send_rounded, color: Colors.black, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
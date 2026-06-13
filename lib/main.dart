import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Lớp cấu hình dịch vụ thông báo đẩy của dự án
class LocalNotificationService {
  static NavigatorState? navigatorState;

  static Future<void> initialize() async {
    print("Local Notification Service đã khởi tạo thành công!");
  }
}

void main() async {
  // Thần chú chống treo logo bắt buộc khi chạy APK độc lập
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 🔥 ĐIỀN CỨNG THÔNG SỐ: Diệt tận gốc lỗi [core/no-app]
    // (Mở file android/app/google-services.json để lấy thông tin điền vào nhé)
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "THAY_BẰNG_API_KEY_CỦA_BẠN",             // Tìm dòng "current_key" trong file json
        appId: "THAY_BẰNG_APP_ID_CỦA_BẠN",               // Tìm dòng "mobilesdk_app_id" trong file json
        messagingSenderId: "THAY_BẰNG_SENDER_ID_CỦA_BẠN", // Tìm dòng "project_number" trong file json
        projectId: "datvexemphimgroup5",                 // Tên project ID của bạn
      ),
    );

    // Kích hoạt dịch vụ thông báo đẩy
    await LocalNotificationService.initialize();
  } catch (e) {
    print("Lỗi khởi tạo hệ thống: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stella Cinema',
      theme: ThemeData.dark(), // Giao diện tối rạp phim
      home: const MainAppWrapper(),
    );
  }
}

class MainAppWrapper extends StatefulWidget {
  const MainAppWrapper({super.key});

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> {
  @override
  void initState() {
    super.initState();

    // 👁️ MẮT THẦN: Lắng nghe real-time biến động từ Firestore collection 'user_notifications'
    FirebaseFirestore.instance
        .collection('user_notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            String title = data['title'] ?? 'Thông báo mới';
            String content = data['content'] ?? '';

            // Hàm gọi hiển thị popup thông báo đẩy local nằm ở đây
            print("ĐÃ HỨNG THÔNG BÁO REAL-TIME: $title - $content");
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Chào mừng bạn đến với Stella Cinema!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
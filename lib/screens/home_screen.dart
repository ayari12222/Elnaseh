import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:torch_light/torch_light.dart';
import 'feed_screen.dart';
import 'admin_screen.dart';
import 'sos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isSOSActive = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Widget> _screens = [
    const FeedScreen(),
    const Center(child: Text('شاشة الدردشة (قريباً)', style: TextStyle(color: Colors.white))),
    const Center(child: Text('شاشة الأجهزة (قريباً)', style: TextStyle(color: Colors.white))),
  ];

  // دالة تشغيل وإنذار الطوارئ
  void _toggleSOS() async {
    if (_isSOSActive) {
      // إيقاف الإنذار
      await _audioPlayer.stop();
      try { await TorchLight.disableTorch(); } catch (e) {}
      setState(() => _isSOSActive = false);
    } else {
      // تشغيل الإنذار
      setState(() => _isSOSActive = true);
      
      // 1. تشغيل الصوت (سنستخدم نغمة النظام كإنذار مبدئي)
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // ملاحظة: يمكنك لاحقاً إضافة ملف صوتي خاص بك إلى مجلد assets
      // await _audioPlayer.play(AssetSource('sos_alert.mp3'));
      
      // 2. تشغيل فلاش الكاميرا
      try {
        await TorchLight.enableTorch();
      } catch (e) {
        print('الفلاش غير متوفر: $e');
      }

      // 3. (اختياري) إرسال إشارة SOS عبر الشبكة
      // سنضيف كود إرسال إحداثيات الموقع لاحقاً
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    TorchLight.disableTorch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSOSActive ? '🚨 وضع الطوارئ نشط 🚨' : 'Elnaseh Feed', 
          style: TextStyle(fontWeight: FontWeight.bold, color: _isSOSActive ? Colors.red : Colors.white)),
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminScreen()),
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'المنشورات'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'الدردشة'),
          BottomNavigationBarItem(icon: Icon(Icons.devices), label: 'الأجهزة'),
        ],
      ),
      // زر الطوارئ العائم
      floatingActionButton: FloatingActionButton.large(
        onPressed: _toggleSOS,
        backgroundColor: _isSOSActive ? Colors.red : Colors.redAccent,
        child: Icon(
          _isSOSActive ? Icons.warning : Icons.sos,
          size: 40,
          color: Colors.white,
        ),
      ),
      
    );
  }
}

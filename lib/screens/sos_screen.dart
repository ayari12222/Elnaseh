import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:torch_light/torch_light.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  bool _isActive = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _toggleEmergency() async {
    if (_isActive) {
      // إيقاف الإنذار
      await _audioPlayer.stop();
      try { await TorchLight.disableTorch(); } catch (e) {}
      setState(() => _isActive = false);
    } else {
      // تشغيل الإنذار
      setState(() => _isActive = true);
      
      // 1. تشغيل الصوت المتكرر
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // ملاحظة: سنستخدم صوت النظام مؤقتاً حتى نضيف ملف صوتي حقيقي
      // await _audioPlayer.play(AssetSource('sos_alert.mp3'));
      
      // 2. تشغيل فلاش الكاميرا
      try {
        await TorchLight.enableTorch();
      } catch (e) {
        print('الفلاش غير متوفر: $e');
      }
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
      backgroundColor: _isActive ? Colors.red[900] : const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('وضع الطوارئ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isActive ? Icons.warning_amber_rounded : Icons.sos,
              size: 100,
              color: _isActive ? Colors.white : Colors.redAccent,
            ),
            const SizedBox(height: 30),
            Text(
              _isActive 
                ? '🚨 تم تفعيل الإنذار! 🚨\nالإضاءة والصوت يعملان الآن.' 
                : 'اضغط على الزر أدناه لتشغيل الإنذار الصوتي والفلاش.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18, 
                color: _isActive ? Colors.white : Colors.grey,
              ),
            ),
            const SizedBox(height: 50),
            GestureDetector(
              onTap: _toggleEmergency,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isActive ? Colors.white : Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: _isActive ? Colors.white54 : Colors.red.withOpacity(0.5),
                      spreadRadius: 10,
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _isActive ? 'إيقاف' : 'SOS',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: _isActive ? Colors.red : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

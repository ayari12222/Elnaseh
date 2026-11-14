import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // سنضع هنا رابط مشروعك في Supabase لاحقاً
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // دالة لنشر المنشور على الإنترنت
  Future<void> postToCloud(String text, String? imageBase64) async {
    try {
      await Supabase.instance.client.from('posts').insert({
        'text': text,
        'image_base64': imageBase64,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('خطأ في النشر على الإنترنت: $e');
    }
  }
}

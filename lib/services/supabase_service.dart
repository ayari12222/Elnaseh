import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // الرابط الخاص بمشروعك
  static const String supabaseUrl = 'https://gilgyoujxoodrceinaqv.supabase.co';
  
  // المفتاح العام (Publishable Key)
  static const String supabaseAnonKey = 'sb_publishable_5bjDTI-VLxxlDGwdSaUxCw_RJ65315C';

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

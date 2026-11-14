import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mesh_network/flutter_mesh_network.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/mesh_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final MeshService _meshService = MeshService();
  final List<Map<String, dynamic>> _posts = [];
  StreamSubscription<MeshMessage>? _meshSubscription;
  RealtimeChannel? _supabaseChannel;

  @override
  void initState() {
    super.initState();
    _startMeshAndListen();
    _listenToCloud();
  }

  // 1. الاستماع للبلوتوث
  Future<void> _startMeshAndListen() async {
    await _meshService.startMesh('مستخدم_${DateTime.now().second}');
    _meshSubscription = _meshService.incomingPosts.listen((message) {
      try {
        final data = jsonDecode(message.payload);
        setState(() {
          _posts.insert(0, {
            'text': data['text'] ?? '',
            'image': data['image'],
            'sender': message.senderName,
          });
        });
      } catch (e) {
        // إذا كانت رسالة نصية عادية
        setState(() {
          _posts.insert(0, {
            'text': message.payload,
            'image': null,
            'sender': message.senderName,
          });
        });
      }
    });
  }

  // 2. الاستماع للإنترنت (Supabase)
  void _listenToCloud() async {
    // جلب المنشورات القديمة أولاً
    final response = await Supabase.instance.client
        .from('posts')
        .select()
        .order('created_at', ascending: false);
    
    setState(() {
      for (var row in response) {
        _posts.add({
          'text': row['text'] ?? '',
          'image': row['image_base64'],
          'sender': 'الإنترنت',
        });
      }
    });

    // الاستماع للمنشورات الجديدة فوراً
    _supabaseChannel = Supabase.instance.client
        .channel('public:posts')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'posts',
          callback: (payload) {
            setState(() {
              _posts.insert(0, {
                'text': payload.newRecord['text'] ?? '',
                'image': payload.newRecord['image_base64'],
                'sender': 'الإنترنت',
              });
            });
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _meshSubscription?.cancel();
    _supabaseChannel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _posts.isEmpty
        ? const Center(
            child: Text(
              'لا توجد منشورات بعد.\nافتح لوحة النشر (⚙️) وأرسل منشوراً!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              final post = _posts[index];
              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عرض الصورة إذا وجدت
                    if (post['image'] != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.memory(
                          base64Decode(post['image']),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['text']!,
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'بواسطة: ${post['sender']}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }
}

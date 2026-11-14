import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> mockPosts = [
      {
        'image': 'https://picsum.photos/400/300?random=1',
        'text': 'مرحباً بكم في تطبيق Elnaseh! هذا أول منشور تجريبي.',
        'sender': 'المدير',
      },
      {
        'image': 'https://picsum.photos/400/300?random=2',
        'text': 'التطبيق يعمل بدون إنترنت عبر البلوتوث.',
        'sender': 'المدير',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockPosts.length,
      itemBuilder: (context, index) {
        final post = mockPosts[index];
        return Card(
          color: const Color(0xFF1E1E1E),
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  post['image']!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post['text']!, style: const TextStyle(fontSize: 16, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('بواسطة: ${post['sender']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

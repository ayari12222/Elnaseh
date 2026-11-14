import 'package:flutter_mesh_network/flutter_mesh_network.dart';

class MeshService {
  // إنشاء شبكة باسم موحد لكي يجد الأجهزة بعضها
  final MeshNetwork _mesh = MeshNetwork(
    config: const MeshConfig(serviceName: 'elnaseh_mesh'),
  );

  // دالة لبدء الشبكة (نستخدمها عند فتح التطبيق)
  Future<void> startMesh(String myName) async {
    await _mesh.start(
      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      userName: myName,
    );
  }

  // دالة لبث المنشور لكل من يحمل التطبيق
  Future<void> broadcastPost(String postContent) async {
    // نرسل النص كرسالة بث عامة
    await _mesh.sendText(postContent);
  }

  // الاستماع للرسائل الواردة
  Stream<MeshMessage> get incomingPosts => _mesh.onMessage;
}

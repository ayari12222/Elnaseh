import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/mesh_service.dart';
import '../services/supabase_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _textController = TextEditingController();
  final MeshService _meshService = MeshService();
  final SupabaseService _supabaseService = SupabaseService();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة النشر'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedImage != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('صورة'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.video_library),
                  label: const Text('فيديو (قريباً)'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _textController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'اكتب منشورك هنا...',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFF1E1E1E),
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () async {
                if (_textController.text.isNotEmpty || _selectedImage != null) {
                  setState(() => _isLoading = true);
                  
                  String? imageBase64;
                  if (_selectedImage != null) {
                    final bytes = await _selectedImage!.readAsBytes();
                    imageBase64 = base64Encode(bytes);
                  }
                  
                  // 1. إرسال عبر البلوتوث
                  final postContent = jsonEncode({
                    'text': _textController.text,
                    'image': imageBase64,
                  });
                  await _meshService.broadcastPost(postContent);
                  
                  // 2. إرسال عبر الإنترنت (Supabase)
                  await _supabaseService.postToCloud(_textController.text, imageBase64);
                  
                  if (context.mounted) {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إرسال المنشور عبر البلوتوث والإنترنت!')),
                    );
                    _textController.clear();
                    setState(() => _selectedImage = null);
                  }
                }
              },
              icon: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                : const Icon(Icons.send),
              label: Text(_isLoading ? 'جارٍ الإرسال...' : 'نشر (بلوتوث + إنترنت)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PreviewTtsScreen extends StatefulWidget {
  final CelebModel? celeb;
  static const String routeName = "previewTts";
  static const String routePath = "/previewTts";

  const PreviewTtsScreen({super.key, required this.celeb});

  @override
  State<PreviewTtsScreen> createState() => _PreviewTtsScreenState();
}

class _PreviewTtsScreenState extends State<PreviewTtsScreen> {
  @override
  Widget build(BuildContext context) {
    final celeb = widget.celeb;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(celeb?.imagePath ?? ""),
              backgroundColor: Colors.grey[300],
              onBackgroundImageError: (exception, stackTrace) {
                print('이미지 로드 실패: $exception');
              },
              child: celeb?.imagePath == null || celeb!.imagePath.isEmpty
                  ? Icon(Icons.person, color: Colors.white, size: 20)
                  : null,
            ),
            SizedBox(width: 12),
            Text(
              celeb?.name ?? "",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: const Center(child: Text("PreviewTtsScreen")),
    );
  }
}

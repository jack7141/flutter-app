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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 20,
                bottom: 10,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xff9e9ef4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "2025년 07월 16일 수요일",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // 메세지 박스 추가
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 5, // 상단 padding 줄임
                bottom: 10,
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "민지야, 누구나 누군가의 위로가 되어줄 수 있어.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff463e8d),
                      ),
                    ),
                    Text(
                      "내 목소리로 조금이나마 행복했으면 좋겠다. 네가 웃으면 나도 좋아",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

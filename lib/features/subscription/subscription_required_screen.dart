import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubscriptionRequiredScreen extends StatelessWidget {
  final CelebModel celeb;

  const SubscriptionRequiredScreen({super.key, required this.celeb});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("구독이 필요해요")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${celeb.name}님의 메시지를 받으려면"),
            Text("구독이 필요해요!"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.push('/subscription', extra: celeb);
              },
              child: Text("${celeb.name} 구독하기"),
            ),
          ],
        ),
      ),
    );
  }
}

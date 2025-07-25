import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:flutter/material.dart';

class SendMessageChoiceCeleb extends StatefulWidget {
  static const String routeName = "sendMessageChoiceCeleb";
  static const String routePath = "/sendMessageChoiceCeleb";

  const SendMessageChoiceCeleb({super.key});

  @override
  State<SendMessageChoiceCeleb> createState() => _SendMessageChoiceCelebState();
}

class _SendMessageChoiceCelebState extends State<SendMessageChoiceCeleb> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Column(
            children: [
              Text(
                "어떤 셀럽의\n목소리를 원하나요?",
                style: TextStyle(
                  fontSize: Sizes.size28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v20,
            ],
          ),
        ),
      ),
    );
  }
}

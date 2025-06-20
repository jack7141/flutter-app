import 'package:celeb_voice/features/user_info/widgets/common_app_%20bar.dart';
import 'package:flutter/material.dart';

class PreviewTtsScreen extends StatefulWidget {
  static const String routeName = "previewTts";
  static const String routePath = "/previewTts";

  const PreviewTtsScreen({super.key});

  @override
  State<PreviewTtsScreen> createState() => _PreviewTtsScreenState();
}

class _PreviewTtsScreenState extends State<PreviewTtsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: const Center(child: Text("PreviewTtsScreen")),
    );
  }
}

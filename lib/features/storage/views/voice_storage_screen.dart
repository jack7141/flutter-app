import 'package:flutter/material.dart';

class VoiceStorageScreen extends StatefulWidget {
  static const String routeName = "voiceStorage";
  static const String routePath = "/voiceStorage";

  const VoiceStorageScreen({super.key});

  @override
  State<VoiceStorageScreen> createState() => _VoiceStorageScreenState();
}

class _VoiceStorageScreenState extends State<VoiceStorageScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Voice Storage")));
  }
}

// lib/features/main/home_screen.dart

import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/main/views_models/celeb_data.dart';
import 'package:celeb_voice/features/main/widgets/celeb_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = "home";
  static const String routePath = "/home";
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<CelebModel> celebs = CelebData.getCelebs();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: false,
        title: Image.asset(
          'assets/images/header_logo.png',
          height: 32,
          width: 180,
          fit: BoxFit.contain,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [CelebCard(index: 0, celeb: celebs[0])],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

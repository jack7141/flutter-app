import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/user_info/widgets/celeb_avatar.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  static const String routeName = "userProfile";

  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: const CommonAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Column(
            children: [
              Row(children: [CelebAvatar()]),
            ],
          ),
        ),
      ),
    );
  }
}

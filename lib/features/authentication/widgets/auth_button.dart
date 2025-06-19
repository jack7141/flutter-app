import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.icon,
    required this.text,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sizes.size14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: Sizes.size1),
        borderRadius: BorderRadius.circular(Sizes.size5),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: Sizes.size20,
                    height: Sizes.size20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Gaps.h10,
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: Sizes.size16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(icon),
                  Gaps.h10,
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: Sizes.size16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}

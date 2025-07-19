import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthButton extends StatelessWidget {
  final IconData? icon;
  final String? imagePath; // 이미지 경로 추가
  final String text;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;

  const AuthButton({
    super.key,
    this.icon,
    this.imagePath,
    required this.text,
    this.isLoading = false,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
  }) : assert(
         icon != null || imagePath != null,
         'Either icon or imagePath must be provided',
       );

  Widget _buildIcon() {
    if (imagePath != null) {
      return SizedBox(
        width: 20,
        height: 20,
        child: Image.asset(
          imagePath!,
          width: 20,
          height: 20,
          fit: BoxFit.contain,
        ),
      );
    } else if (icon != null) {
      return FaIcon(icon, color: textColor);
    }
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sizes.size14),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor ?? Colors.grey.shade300,
          width: Sizes.size1,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: Sizes.size20,
                    height: Sizes.size20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Gaps.h10,
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: Sizes.size16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildIcon(),
                  Gaps.h10,
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: Sizes.size16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

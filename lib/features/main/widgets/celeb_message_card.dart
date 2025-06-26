import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:flutter/material.dart';

class CelebMessageCard extends StatelessWidget {
  const CelebMessageCard({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.celebMessageModel,
    required this.index,
  });

  final double screenHeight;
  final double screenWidth;
  final List<Map<String, String>> celebMessageModel;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            height: screenHeight * 0.17,
            width: screenWidth * 0.3,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(
                          celebMessageModel[index - 1]['celebImage'] ?? '',
                        ),
                      ),
                      Gaps.h8,
                      Text(
                        celebMessageModel[index - 1]['celebName'] ?? '',
                        style: TextStyle(
                          fontSize: Sizes.size14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Text(
                          celebMessageModel[index - 1]['message'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Sizes.size14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

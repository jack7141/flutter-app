import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:flutter/material.dart';

class CelebCard extends StatelessWidget {
  final int index;
  final CelebModel celeb;

  const CelebCard({super.key, required this.index, required this.celeb});

  void _onTap(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 420,
        clipBehavior: Clip.none,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 10),
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 이미지
            Align(
              alignment: Alignment.bottomRight,
              child: Transform.translate(
                offset: Offset(0, -50),
                child: SizedBox(
                  width: 380,
                  height: 400,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.white,
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.6, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Hero(
                      tag: 'celeb_image_card_$index',
                      child: Image.asset(
                        celeb.imagePath,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

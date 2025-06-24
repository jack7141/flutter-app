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
        width: 320,
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
            // 이름
            Positioned(
              top: 270,
              left: 20,
              child: Text(
                celeb.name,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            // 태그들
            Positioned(
              top: 320,
              left: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: celeb.tags
                    .map(
                      (tag) => Container(
                        margin: EdgeInsets.only(right: 8),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Color(0xFF38B6E4)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF38B6E4),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            // 구독하기 버튼
            Positioned(
              bottom: 10,
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => _onTap(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Color(0xFF55D3E1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      '구독하기',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

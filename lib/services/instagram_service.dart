class InstagramImage {
  final String imageUrl;
  final String caption;
  final String timestamp;

  InstagramImage({
    required this.imageUrl,
    required this.caption,
    required this.timestamp,
  });
}

class InstagramService {
  // 셀럽별 Instagram 이미지 매핑 (임시 데이터)
  static const Map<String, List<Map<String, String>>> _celebInstagramImages = {
    '아이유': [
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/513849510_18516544972000027_8860420971693123072_n.jpg?stp=dst-jpg_e35_p640x640_sh0.08_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=107&_nc_oc=Q6cZ2QE5sdYrzsDP5_xlc_4lLnHl3QovTM7AcA-JmnIfqSBS2jmE4TFGd1vm0v2mDhn4QM4&_nc_ohc=X-EqlNafy0AQ7kNvwE_6u_J&_nc_gid=EZmFCAqzNjesgnioSyTvBw&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfQHOsk6sJ5lfLbiNchar1OmCS7Fm_u44YvxV9SRlqrKzw&oe=687D1AAB&_nc_sid=8b3546',
        'caption': '오늘도 행복한 하루 보내세요 💜',
        'timestamp': '2시간 전',
      },
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/508348886_18514701358000027_4918601686676477968_n.jpg?stp=dst-jpg_e35_s640x640_sh0.08_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=107&_nc_oc=Q6cZ2QE5sdYrzsDP5_xlc_4lLnHl3QovTM7AcA-JmnIfqSBS2jmE4TFGd1vm0v2mDhn4QM4&_nc_ohc=smVwIEPr3IUQ7kNvwHadDOr&_nc_gid=EZmFCAqzNjesgnioSyTvBw&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfSGzarAnr_rl0gQ8n_mSU5h7cwS_r55Ku7pz90JUT6nDA&oe=687D060F&_nc_sid=8b3546',
        'caption': '좋은 음악과 함께 🎵',
        'timestamp': '1일 전',
      },
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/504007656_710945781638238_5385972782269016339_n.jpg?stp=dst-jpg_e15_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=106&_nc_oc=Q6cZ2QE5sdYrzsDP5_xlc_4lLnHl3QovTM7AcA-JmnIfqSBS2jmE4TFGd1vm0v2mDhn4QM4&_nc_ohc=mlg2jKO2Y_8Q7kNvwFOVJc1&_nc_gid=EZmFCAqzNjesgnioSyTvBw&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfT6wM_Ud539hcpzHMZW6mSVwcbzTOIqF0HU_jvX_ilJyg&oe=687D1377&_nc_sid=8b3546',
        'caption': '새로운 시작 ✨',
        'timestamp': '3일 전',
      },
    ],
    '소농민': [
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/502384903_18517101970007044_7829894328300918407_n.jpg?stp=dst-jpg_e15_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=104&_nc_oc=Q6cZ2QFMM3djLhFFKhRBIjvplQKNPusqeTd1goTSTSh1NglZhXh5eunIL7ahZq45HjEa7Cw&_nc_ohc=M24sC0cJ1qYQ7kNvwHWTxeg&_nc_gid=P1sKjCtRxGg4NOaDffZncQ&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfSJ44FAre1HGHYCa9CgWSxosmCojpHk3DTTJRpX8XQ9Rg&oe=687CFC39&_nc_sid=8b3546',
        'caption': '농사일은 즐거워 🌾',
        'timestamp': '5시간 전',
      },
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/509224464_18559199065003492_7592357121981889336_n.jpg?stp=dst-jpg_e35_p640x640_sh0.08_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=104&_nc_oc=Q6cZ2QFMM3djLhFFKhRBIjvplQKNPusqeTd1goTSTSh1NglZhXh5eunIL7ahZq45HjEa7Cw&_nc_ohc=F42NBSZ4qG0Q7kNvwHkuufM&_nc_gid=P1sKjCtRxGg4NOaDffZncQ&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfQS_m8NNUO8AEFTGi3zlOFMCpKGhDulbnY9CRuF8aaQmw&oe=687CFFAA&_nc_sid=8b3546',
        'caption': '오늘 수확한 채소들 🥕',
        'timestamp': '1일 전',
      },
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/503580769_18462455266072591_5362810773093742470_n.jpg?stp=dst-jpg_e35_p640x640_sh0.08_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=107&_nc_oc=Q6cZ2QFMM3djLhFFKhRBIjvplQKNPusqeTd1goTSTSh1NglZhXh5eunIL7ahZq45HjEa7Cw&_nc_ohc=gZi-KwvItggQ7kNvwGHnrhM&_nc_gid=P1sKjCtRxGg4NOaDffZncQ&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfRPObCMgW7pvPPLZtWczHGon1BadkmKBjOgo4tkmqEGEQ&oe=687D2E5F&_nc_sid=8b3546',
        'caption': '자연과 함께하는 삶 🌿',
        'timestamp': '2일 전',
      },
    ],
  };

  static Future<List<InstagramImage>> getCelebInstagramImages(
    String celebName,
  ) async {
    await Future.delayed(Duration(milliseconds: 500)); // 네트워크 지연 시뮬레이션

    final imageData = _celebInstagramImages[celebName] ?? [];
    return imageData
        .map(
          (data) => InstagramImage(
            imageUrl: data['imageUrl']!,
            caption: data['caption']!,
            timestamp: data['timestamp']!,
          ),
        )
        .toList();
  }
}

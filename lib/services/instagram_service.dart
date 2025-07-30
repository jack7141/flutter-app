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
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/521389609_18520642561000027_8342492247774238049_n.jpg?stp=dst-jpg_e35_p640x640_sh0.08_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=1&_nc_oc=Q6cZ2QHvIeg2AaGcE0fHxZdweZ_P4fTPZtQ0p_6Bq0Mg1fvltHjjGrHjxrEXQjfql2KfMhM&_nc_ohc=PEvRtvXRI5wQ7kNvwFe04kH&_nc_gid=OcBWmyzPJjQTYJ8zYQPOWA&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfSgSrX2pnCSyAO7YRO2XCx07LSM_Z6vJ-36wnhiPcKg_A&oe=6888D377&_nc_sid=8b3546',
        'caption': '오늘도 행복한 하루 보내세요 💜',
        'timestamp': '2시간 전',
      },
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/513849510_18516544972000027_8860420971693123072_n.jpg?stp=dst-jpg_e35_p640x640_sh0.08_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=107&_nc_oc=Q6cZ2QHvIeg2AaGcE0fHxZdweZ_P4fTPZtQ0p_6Bq0Mg1fvltHjjGrHjxrEXQjfql2KfMhM&_nc_ohc=xXMIiGzhN0cQ7kNvwFaYrpC&_nc_gid=OcBWmyzPJjQTYJ8zYQPOWA&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfS5kW02dyiePG77QdC7KwPM2cUL8RhrnqpnoE0h6W07JQ&oe=6888F82B&_nc_sid=8b3546',
        'caption': '좋은 음악과 함께 🎵',
        'timestamp': '1일 전',
      },
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/508348886_18514701358000027_4918601686676477968_n.jpg?stp=dst-jpg_e35_s640x640_sh0.08_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=107&_nc_oc=Q6cZ2QHvIeg2AaGcE0fHxZdweZ_P4fTPZtQ0p_6Bq0Mg1fvltHjjGrHjxrEXQjfql2KfMhM&_nc_ohc=pRJUj6Z_j6wQ7kNvwEaVM-U&_nc_gid=OcBWmyzPJjQTYJ8zYQPOWA&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfT2WrUhpgEEb3I27IVohD6BcH6butBOYfsnvbIpZc1tYA&oe=6888E38F&_nc_sid=8b3546',
        'caption': '새로운 시작 ✨',
        'timestamp': '3일 전',
      },
    ],
    '소농민': [
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/522634425_786262191016505_6538799625124647563_n.jpg?stp=dst-jpg_e15_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=105&_nc_oc=Q6cZ2QENUEemNHW5RCHDNM5cLWlUoc02OdNGL5T4MRT2NLbkvLHOP9Dbu-LqYxrck0Qjj0M&_nc_ohc=KFfitylyZQ8Q7kNvwFIyPia&_nc_gid=PVj2bP3uSvpatZysT8-rWQ&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfQ1M7EjNSyGCI5Opmpj461BbyjN_xJNT1O89mTyXIyNyw&oe=6888D34F&_nc_sid=8b3546',
        'caption': '농사일은 즐거워 🌾',
        'timestamp': '5시간 전',
      },
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/520547198_9927417987367375_5655109689651365435_n.jpg?stp=dst-jpg_e15_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=107&_nc_oc=Q6cZ2QENUEemNHW5RCHDNM5cLWlUoc02OdNGL5T4MRT2NLbkvLHOP9Dbu-LqYxrck0Qjj0M&_nc_ohc=8_5Ae-7gv5MQ7kNvwE2U5If&_nc_gid=PVj2bP3uSvpatZysT8-rWQ&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfRF7YrhlIaaV-uYh8vFd7JiqFSIdQ-dhJsWVQqARJEntA&oe=6888C2BA&_nc_sid=8b3546',
        'caption': '오늘 수확한 채소들 🥕',
        'timestamp': '1일 전',
      },
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/502384903_18517101970007044_7829894328300918407_n.jpg?stp=dst-jpg_e15_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=104&_nc_oc=Q6cZ2QENUEemNHW5RCHDNM5cLWlUoc02OdNGL5T4MRT2NLbkvLHOP9Dbu-LqYxrck0Qjj0M&_nc_ohc=VZDVvjOkWTUQ7kNvwGixlKC&_nc_gid=PVj2bP3uSvpatZysT8-rWQ&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfQzzIjvHiV6u8hCJTbx1Umx00xjo0we2bCKZxzic_yHMA&oe=6888D9B9&_nc_sid=8b3546',
        'caption': '자연과 함께하는 삶 🌿',
        'timestamp': '2일 전',
      },
    ],
    '이연복': [
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/523408425_1430443188197322_4291189398930071529_n.heic?stp=dst-jpg_e35_s640x640_sh0.08_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=106&_nc_oc=Q6cZ2QE00F6lcPEJ1hbVOVlQ56Gc0peZb3cfCkDRx42_7OXbS-Wu9wECUg5m5z14-ylT8RA&_nc_ohc=8f4C595OX8gQ7kNvwHaTDqJ&_nc_gid=wYFP_FfqfADH7LabUld7PA&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfQUCwzTDEvyApg3MzigrMFeXv3lNcyCp-nFN78quc6v7w&oe=688F2EF5&_nc_sid=8b3546',
        'caption': '요즘 저녁 하늘이 정말 아름답고 이쁘네요 그와중에 생일이 는 사색에 잠기고 아름다운 저녁 하늘 꼭 보세요',
        'timestamp': '5시간 전',
      },
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/522057713_1518323666246822_4988982805109769024_n.jpg?stp=dst-jpg_e15_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=102&_nc_oc=Q6cZ2QE00F6lcPEJ1hbVOVlQ56Gc0peZb3cfCkDRx42_7OXbS-Wu9wECUg5m5z14-ylT8RA&_nc_ohc=jA0tmW9eUgYQ7kNvwFuRF9t&_nc_gid=wYFP_FfqfADH7LabUld7PA&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfR97xw0VMBvrRGmKCmDRb6vATJU_VKM2mxOpKgwFAjykA&oe=688F3730&_nc_sid=8b3546',
        'caption':
            '비가 오나 눈이오나 산책 은 꼭 해야 잠을 자는 우리 생일이 생일이와 비를 흠뻑 같이 맞으며 지난 날을 다시 한번 되돌아봅니다.',
        'timestamp': '1일 전',
      },
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.29350-15/520783987_797737089243572_2178168836586557830_n.heic?stp=dst-jpg_e35_p640x640_sh0.08_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=108&_nc_oc=Q6cZ2QE00F6lcPEJ1hbVOVlQ56Gc0peZb3cfCkDRx42_7OXbS-Wu9wECUg5m5z14-ylT8RA&_nc_ohc=TkR-TMTnuTsQ7kNvwHWrrWU&_nc_gid=wYFP_FfqfADH7LabUld7PA&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfR4vsWH3HRymOwaHLtk12mgXxhb1jRlYwACh6uYEG9Lrw&oe=688F56E7&_nc_sid=8b3546',
        'caption': '안녕하세요, 이연복입니다.',
        'timestamp': '2일 전',
      },
    ],
    '크리스티나': [
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/502155105_745843767871839_8717367241312653174_n.jpg?stp=dst-jpg_e15_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=103&_nc_oc=Q6cZ2QEkGcPOUcga_gLzHVnPo0KJQrVI7RkTZdSjeGzfdYVxtUlUPZh7xCgvNwb25S7FklQ&_nc_ohc=A9GhB-y3kmUQ7kNvwFY-Epi&_nc_gid=q1WGbNE41Q2RRpXt6z_Giw&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfQ0RGKL6UWhtsk-J6TARdfpHkBspNWKH1fBGHOmYq7lKg&oe=688F38B1&_nc_sid=8b3546',
        'caption': '요즘 저녁 하늘이 정말 아름답고 이쁘네요 그와중에 생일이 는 사색에 잠기고 아름다운 저녁 하늘 꼭 보세요',
        'timestamp': '5시간 전',
      },
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/503016608_3917044318607391_4952896623076070681_n.jpg?stp=dst-jpg_e15_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=103&_nc_oc=Q6cZ2QEkGcPOUcga_gLzHVnPo0KJQrVI7RkTZdSjeGzfdYVxtUlUPZh7xCgvNwb25S7FklQ&_nc_ohc=pf2PF_zw6uEQ7kNvwFYytgi&_nc_gid=q1WGbNE41Q2RRpXt6z_Giw&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfSkIHXH1Fu8wc0eQUVVxzEIe0rh_WLI6rA1_YdQF03Eyg&oe=688F2EFC&_nc_sid=8b3546',
        'caption':
            '비가 오나 눈이오나 산책 은 꼭 해야 잠을 자는 우리 생일이 생일이와 비를 흠뻑 같이 맞으며 지난 날을 다시 한번 되돌아봅니다.',
        'timestamp': '1일 전',
      },
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/525932536_18495424063065820_506160292681647571_n.jpg?stp=dst-jpg_e35_p640x640_sh0.08_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=104&_nc_oc=Q6cZ2QEkGcPOUcga_gLzHVnPo0KJQrVI7RkTZdSjeGzfdYVxtUlUPZh7xCgvNwb25S7FklQ&_nc_ohc=6f70uqN2hLMQ7kNvwFBaYtt&_nc_gid=q1WGbNE41Q2RRpXt6z_Giw&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfSLn_yiwz7gGTe3yAgZFt76vB5P7RZ0RgcHszqlQDazcA&oe=688F630D&_nc_sid=8b3546',
        'caption': '안녕하세요, 이연복입니다.',
        'timestamp': '2일 전',
      },
    ],
    // 기본 데이터 추가 (어떤 셀럽이든 보여줄 수 있도록)
    'default': [
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/504208427_18414410911101904_4222726923659514458_n.jpg?stp=dst-jpg_e35_p640x640_sh0.08_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=104&_nc_oc=Q6cZ2QHAGgZtYkys4fZCMC3gOctU2sa3u41US612F1-eBx9QFtXZPjRwfNGZ7Ui190myLLM&_nc_ohc=v-Kn159Bl4kQ7kNvwGld8J-&_nc_gid=LyKA9kjSiSDLbr5OAp86IQ&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfQrCwIBgHji7ROpUHccGoDvhLSocnXwa58AZm5hj9DqHw&oe=6888E80E&_nc_sid=8b3546',
        'caption': '멋진 하루 보내세요! ✨',
        'timestamp': '1시간 전',
      },
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/499957728_18503663611025987_2611497660276732726_n.jpg?stp=dst-jpg_e35_p640x640_sh0.08_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=111&_nc_oc=Q6cZ2QHAGgZtYkys4fZCMC3gOctU2sa3u41US612F1-eBx9QFtXZPjRwfNGZ7Ui190myLLM&_nc_ohc=3pOp8Yw-RZsQ7kNvwEWLCJi&_nc_gid=LyKA9kjSiSDLbr5OAp86IQ&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfQOuNEcl9pLN7x1p2-6FHHtPlbOVw6I2HMNh44Cw5093Q&oe=6888CB21&_nc_sid=8b3546',
        'caption': '오늘도 좋은 하루! 💝',
        'timestamp': '3시간 전',
      },
      {
        'imageUrl':
            'https://scontent-icn2-1.cdninstagram.com/v/t51.2885-15/491893471_18408447598101904_8921016126347552325_n.jpg?stp=dst-jpg_e35_p640x640_sh0.08_tt6&_nc_ht=scontent-icn2-1.cdninstagram.com&_nc_cat=104&_nc_oc=Q6cZ2QHAGgZtYkys4fZCMC3gOctU2sa3u41US612F1-eBx9QFtXZPjRwfNGZ7Ui190myLLM&_nc_ohc=o9Ske4qaO3gQ7kNvwEku6ZX&_nc_gid=LyKA9kjSiSDLbr5OAp86IQ&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfRk2DcAVWyJ3cAnByGX41Jj4e-9atLHtaQldhMWYzHWUg&oe=6888F372&_nc_sid=8b3546',
        'caption': '행복한 순간들 🌟',
        'timestamp': '5시간 전',
      },
    ],
  };

  static Future<List<InstagramImage>> getCelebInstagramImages(
    String celebName,
  ) async {
    await Future.delayed(Duration(milliseconds: 500)); // 네트워크 지연 시뮬레이션

    print("📸 [DEBUG] Instagram 요청된 셀럽 이름: '$celebName'");
    print("📸 [DEBUG] 사용 가능한 키들: ${_celebInstagramImages.keys.toList()}");

    // 정확한 이름으로 먼저 찾기
    List<Map<String, String>>? imageData = _celebInstagramImages[celebName];

    // 없으면 기본 데이터 사용
    if (imageData == null) {
      print("📸 [DEBUG] '$celebName'에 대한 데이터가 없어서 기본 데이터 사용");
      imageData = _celebInstagramImages['default']!;
    } else {
      print("📸 [DEBUG] '$celebName'에 대한 데이터 ${imageData.length}개 찾음");
    }

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

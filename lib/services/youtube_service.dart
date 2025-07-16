class YouTubeService {
  static const String _apiKey = 'AIzaSyB0bMb6RuH2RwxYhdYLlp7G70xAfC6PF_o';
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3/search';

  // 셀럽별 YouTube 채널 ID 매핑
  static const Map<String, String> _celebChannelIds = {
    '아이유': 'UC3SyT4_WLHzN7JmHQwKQZww',
    '소농민': 'UCEg25rdRZXg32iwai6N6l0w', // 임시로 같은 채널 사용
    // 추가 셀럽들...
  };

  static Future<List<YouTubeVideo>> getCelebVideos(String celebName) async {
    // API 할당량 초과로 인해 임시로 더미 데이터 사용
    if (celebName == '아이유') {
      return [
        YouTubeVideo(
          videoId: 'JleoAppaxi0',
          title: 'IU Love wins all MV',
          thumbnailUrl: 'https://i.ytimg.com/vi/JleoAppaxi0/hqdefault.jpg',
          description: 'IU 신곡 뮤직비디오',
        ),
        YouTubeVideo(
          videoId: 'o_nxIQTM_B0',
          title: 'IU Blueming Live Clip',
          thumbnailUrl: 'https://i.ytimg.com/vi/o_nxIQTM_B0/hqdefault.jpg',
          description: 'IU Blueming 라이브',
        ),
        YouTubeVideo(
          videoId: '3iM_06QeZi8',
          title: 'IU 내 손을 잡아 Live Clip',
          thumbnailUrl: 'https://i.ytimg.com/vi/3iM_06QeZi8/hqdefault.jpg',
          description: 'IU 내 손을 잡아 라이브',
        ),
      ];
    }

    if (celebName == '소농민') {
      return [
        YouTubeVideo(
          videoId: 'JleoAppaxi0',
          title: '소농민 농사 이야기',
          thumbnailUrl: 'https://i.ytimg.com/vi/JleoAppaxi0/hqdefault.jpg',
          description: '소농민의 농사 이야기',
        ),
        YouTubeVideo(
          videoId: 'o_nxIQTM_B0',
          title: '오늘의 농사일기',
          thumbnailUrl: 'https://i.ytimg.com/vi/o_nxIQTM_B0/hqdefault.jpg',
          description: '오늘의 농사일기',
        ),
        YouTubeVideo(
          videoId: '3iM_06QeZi8',
          title: '농업 노하우 공유',
          thumbnailUrl: 'https://i.ytimg.com/vi/3iM_06QeZi8/hqdefault.jpg',
          description: '농업 노하우 공유',
        ),
      ];
    }

    // API 호출 부분 임시 비활성화
    /*
    final channelId = _celebChannelIds[celebName];
    if (channelId == null) {
      print('❌ 채널 ID를 찾을 수 없습니다: $celebName');
      return [];
    }

    try {
      final url =
          '$_baseUrl?key=$_apiKey&part=snippet&channelId=$channelId&order=viewCount&maxResults=3&type=video';
      print('🔍 YouTube API 호출 중: $celebName');
      print('🔗 URL: $url');

      final response = await http.get(Uri.parse(url));

      print('📊 응답 상태 코드: ${response.statusCode}');
      print('📄 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 에러 응답 확인
        if (data.containsKey('error')) {
          print('❌ YouTube API 에러: ${data['error']}');
          return [];
        }

        final items = data['items'] as List;
        print('✅ 동영상 ${items.length}개 로드 성공');

        return items.map((item) => YouTubeVideo.fromJson(item)).toList();
      } else {
        print('❌ HTTP 에러: ${response.statusCode}');
        print('📄 에러 내용: ${response.body}');
      }
    } catch (e) {
      print('❌ YouTube API 호출 실패: $e');
    }
    */

    // 기본값으로 빈 배열 반환
    return [];
  }
}

class YouTubeVideo {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String description;

  YouTubeVideo({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.description,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    return YouTubeVideo(
      videoId: json['id']['videoId'],
      title: json['snippet']['title'],
      thumbnailUrl: json['snippet']['thumbnails']['medium']['url'],
      description: json['snippet']['description'],
    );
  }
}

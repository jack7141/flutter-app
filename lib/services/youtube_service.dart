class YouTubeService {
  static const String _apiKey = 'AIzaSyB0bMb6RuH2RwxYhdYLlp7G70xAfC6PF_o';
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3/search';

  // 셀럽별 YouTube 채널 ID 매핑
  static const Map<String, String> _celebChannelIds = {
    '아이유': 'UC3SyT4_WLHzN7JmHQwKQZww',
    '소농민': 'UCEg25rdRZXg32iwai6N6l0w',
  };

  // 기본 YouTube 비디오 데이터
  static List<YouTubeVideo> _getDefaultVideos(String celebName) {
    return [
      YouTubeVideo(
        videoId: 'JleoAppaxi0',
        title: '$celebName - 최신 영상',
        thumbnailUrl: 'https://i.ytimg.com/vi/JleoAppaxi0/hqdefault.jpg',
        description: '$celebName의 최신 영상입니다',
      ),
      YouTubeVideo(
        videoId: 'o_nxIQTM_B0',
        title: '$celebName - 인기 영상',
        thumbnailUrl: 'https://i.ytimg.com/vi/o_nxIQTM_B0/hqdefault.jpg',
        description: '$celebName의 인기 영상입니다',
      ),
      YouTubeVideo(
        videoId: '3iM_06QeZi8',
        title: '$celebName - 추천 영상',
        thumbnailUrl: 'https://i.ytimg.com/vi/3iM_06QeZi8/hqdefault.jpg',
        description: '$celebName의 추천 영상입니다',
      ),
    ];
  }

  static Future<List<YouTubeVideo>> getCelebVideos(String celebName) async {
    print("🎬 [DEBUG] YouTube 요청된 셀럽 이름: '$celebName'");
    print("🎬 [DEBUG] 사용 가능한 키들: ${_celebChannelIds.keys.toList()}");

    // API 할당량 초과로 인해 임시로 더미 데이터 사용
    if (celebName == '아이유') {
      print("🎬 [DEBUG] 아이유 전용 데이터 반환");
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
      print("🎬 [DEBUG] 소농민 전용 데이터 반환");
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

    // 다른 셀럽들을 위한 기본 데이터 반환
    print("🎬 [DEBUG] '$celebName'에 대한 전용 데이터가 없어서 기본 데이터 반환");
    return _getDefaultVideos(celebName);
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

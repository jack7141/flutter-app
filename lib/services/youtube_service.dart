import 'dart:convert';

import 'package:http/http.dart' as http;

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
    final channelId = _celebChannelIds[celebName];
    if (channelId == null) return [];

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl?key=$_apiKey&part=snippet&channelId=$channelId&order=viewCount&maxResults=3&type=video',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;

        return items.map((item) => YouTubeVideo.fromJson(item)).toList();
      }
    } catch (e) {
      print('YouTube API 호출 실패: $e');
    }

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

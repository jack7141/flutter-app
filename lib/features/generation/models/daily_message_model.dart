class DailyMessageModel {
  final String date;
  final String title;
  final String content;
  final String audioUrl;

  DailyMessageModel({
    required this.date,
    required this.title,
    required this.content,
    required this.audioUrl,
  });

  // API 응답에서 DailyMessageModel 생성 (DailyMessageService import 제거)
  factory DailyMessageModel.fromApiResponse(Map<String, dynamic> response) {
    return DailyMessageModel(
      date: _formatDate(response['postedAt']),
      title: response['generatedText'].length > 50
          ? response['generatedText'].substring(0, 50) + '...'
          : response['generatedText'],
      content: response['generatedText'],
      audioUrl: response['audioFile'],
    );
  }

  static String _formatDate(String postedAt) {
    // "2025-07-18" -> "2025년 07월 18일 수요일" 형태로 변환
    final parts = postedAt.split('-');
    if (parts.length == 3) {
      final year = parts[0];
      final month = parts[1];
      final day = parts[2];

      // 간단한 요일 계산
      final weekdays = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];
      final weekday = weekdays[DateTime.parse(postedAt).weekday % 7];

      return '$year년 $month월 $day일 $weekday';
    }
    return postedAt;
  }
}

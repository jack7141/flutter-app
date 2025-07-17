class DailyMessageModel {
  final String date;
  final String title;
  final String content;
  final String ttsFileName;

  DailyMessageModel({
    required this.date,
    required this.title,
    required this.content,
    required this.ttsFileName,
  });
}

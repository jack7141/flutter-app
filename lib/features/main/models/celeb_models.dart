class CelebModel {
  final String id;
  final String name;
  final String imagePath;
  final List<String> tags;
  final String description;
  final String status;
  final int index;

  CelebModel({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.tags,
    required this.description,
    required this.status,
    required this.index,
  });

  factory CelebModel.fromJson(Map<String, dynamic> json) {
    try {
      print("🔍 파싱 시작 - JSON: $json");

      // 안전한 문자열 변환
      String safeString(dynamic value) => value?.toString() ?? '';

      // 안전한 정수 변환
      int safeInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
      }

      // images 배열에서 첫 번째 이미지의 url 추출
      String imageUrl = '';
      try {
        final images = json['images'];
        if (images != null && images is List && images.isNotEmpty) {
          final firstImage = images[0];
          if (firstImage != null && firstImage is Map<String, dynamic>) {
            imageUrl = safeString(firstImage['url']);
          }
        }
      } catch (e) {
        print("🖼️ 이미지 파싱 에러: $e");
        imageUrl = '';
      }

      // tags 배열 안전하게 파싱
      List<String> tagList = [];
      try {
        final tags = json['tags'];
        if (tags != null && tags is List) {
          tagList = tags
              .map((tag) => safeString(tag))
              .where((tag) => tag.isNotEmpty)
              .toList();
        }
      } catch (e) {
        print("🏷️ 태그 파싱 에러: $e");
        tagList = [];
      }

      final result = CelebModel(
        id: safeString(json['id']),
        name: safeString(json['name']),
        imagePath: imageUrl,
        tags: tagList,
        description: safeString(json['description']),
        status: safeString(json['status']),
        index: safeInt(json['index']),
      );

      print("✅ 파싱 성공: ${result.name}");
      return result;
    } catch (e) {
      print("💥 CelebModel 파싱 에러: $e");
      // 기본값으로 객체 생성
      return CelebModel(
        id: 'unknown',
        name: '알 수 없음',
        imagePath: '',
        tags: [],
        description: '',
        status: 'UNKNOWN',
        index: 0,
      );
    }
  }
}

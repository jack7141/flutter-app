class CelebModel {
  final String? id;
  final String name;
  final String imagePath;
  final String description;
  final String category;
  final List<String> tags;
  final String? status;
  final int? index;

  CelebModel({
    this.id,
    required this.name,
    required this.imagePath,
    required this.description,
    required this.category,
    required this.tags,
    this.status,
    this.index,
  });

  factory CelebModel.fromJson(Map<String, dynamic> json) {
    return CelebModel(
      id: json['id'],
      name: json['name'],
      imagePath: json['imagePath'],
      description: json['description'],
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
      status: json['status'],
      index: json['index'],
    );
  }
}

class CelebModel {
  final String name;
  final String imagePath;
  final String description;
  final String category;
  final List<String> tags;

  CelebModel.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      imagePath = json['imagePath'],
      description = json['description'],
      category = json['category'],
      tags = json['tags'];
}

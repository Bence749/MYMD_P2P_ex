class FileModel {
  final String id;
  final String title;
  final String magnetLink;
  final int size;
  final String category;
  final DateTime uploadDate;
  final bool isPurchased;

  FileModel({
    required this.id,
    required this.title,
    required this.magnetLink,
    required this.size,
    required this.category,
    required this.uploadDate,
    required this.isPurchased,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'],
      title: json['title'],
      magnetLink: json['magnet_link'],
      size: json['size'],
      category: json['category'],
      uploadDate: DateTime.parse(json['upload_date']),
      isPurchased: json['is_purchased'],
    );
  }
}

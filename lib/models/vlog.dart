import 'package:hive/hive.dart';

part 'vlog.g.dart';

@HiveType(typeId: 0)
class Vlog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String category;

  @HiveField(4)
  String status;

  @HiveField(5)
  DateTime uploadDate;

  @HiveField(6)
  bool isFavorite;

  @HiveField(7)
  String platform;

  @HiveField(8)
  String thumbnailPath;

  Vlog({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.uploadDate,
    this.isFavorite = false,
    this.platform = 'YouTube',
    this.thumbnailPath = '',
  });

  Vlog copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? status,
    DateTime? uploadDate,
    bool? isFavorite,
    String? platform,
    String? thumbnailPath,
  }) {
    return Vlog(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      uploadDate: uploadDate ?? this.uploadDate,
      isFavorite: isFavorite ?? this.isFavorite,
      platform: platform ?? this.platform,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}

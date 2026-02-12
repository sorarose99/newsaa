import 'dart:convert';
import 'dart:typed_data';

enum VirtueType { benefit, time, image, video }

enum VirtueCategory { quran, hadith, formula, custom }

class Virtue {
  final String? id;
  final VirtueType type;
  final VirtueCategory? category;
  final String text;
  final String? title;
  final String? description;
  final String? url;
  final String? filePath;
  final String? imageBinary;

  Virtue({
    this.id,
    required this.type,
    this.category,
    this.text = '',
    this.title,
    this.description,
    this.url,
    this.filePath,
    this.imageBinary,
  });

  factory Virtue.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Virtue(
      id: documentId,
      type: VirtueType.values.firstWhere((e) => e.name == data['type']),
      category: data['category'] != null
          ? VirtueCategory.values.firstWhere(
              (e) => e.name == data['category'],
              orElse: () => VirtueCategory.custom,
            )
          : null,
      text: data['text'] ?? '',
      title: data['title'],
      description: data['description'],
      url: data['url'],
      filePath: data['file_path'], // Fixed from filePath to file_path
      imageBinary: data['image_binary'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'category': category?.name,
      'text': text,
      'title': title,
      'description': description,
      'url': (url != null && url!.isNotEmpty) ? url : null,
      'file_path': filePath, // Added file_path for consistency
      'image_binary': imageBinary,
    };
  }

  factory Virtue.fromJson(Map<String, dynamic> json) {
    return Virtue(
      id: json['id'] as String?,
      type: VirtueType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => VirtueType.benefit,
      ),
      category: json['category'] != null
          ? VirtueCategory.values.firstWhere(
              (e) => e.name == json['category'],
              orElse: () => VirtueCategory.custom,
            )
          : null,
      text: json['text'] as String? ?? '',
      title: json['title'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String?,
      filePath: json['file_path'] as String?,
      imageBinary: json['image_binary'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'category': category?.name,
      'text': text,
      'title': title,
      'description': description,
      'url': (url != null && url!.isNotEmpty) ? url : null,
      'file_path': (filePath != null && filePath!.isNotEmpty) ? filePath : null,
      'image_binary': imageBinary,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  static String encodeImageToBase64(List<int> imageBytes) {
    return base64Encode(imageBytes);
  }

  static Uint8List decodeImageFromBase64(String base64String) {
    return base64Decode(base64String);
  }

  Virtue copyWith({
    String? id,
    VirtueType? type,
    VirtueCategory? category,
    String? text,
    String? title,
    String? description,
    String? url,
    String? filePath,
    String? imageBinary,
  }) {
    return Virtue(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      text: text ?? this.text,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      filePath: filePath ?? this.filePath,
      imageBinary: imageBinary ?? this.imageBinary,
    );
  }
}

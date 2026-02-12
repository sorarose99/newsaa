import 'dart:convert';
import 'package:flutter/foundation.dart';

class PrayerFormula {
  final String id;
  final String titleAr;
  final String titleEn;
  final String contentAr;
  final String contentEn;
  final DateTime createdAt;
  final DateTime updatedAt;

  PrayerFormula({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.contentAr,
    required this.contentEn,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PrayerFormula.fromJson(Map<String, dynamic> json) {
    return PrayerFormula(
      id: json['id'] ?? '',
      titleAr: json['titleAr'] ?? '',
      titleEn: json['titleEn'] ?? '',
      contentAr: json['contentAr'] ?? '',
      contentEn: json['contentEn'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleAr': titleAr,
      'titleEn': titleEn,
      'contentAr': contentAr,
      'contentEn': contentEn,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class EvidenceItem {
  final String id;
  final String titleAr;
  final String titleEn;
  final String contentAr;
  final String contentEn;
  final String source;
  final DateTime createdAt;

  EvidenceItem({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.contentAr,
    required this.contentEn,
    required this.source,
    required this.createdAt,
  });

  factory EvidenceItem.fromJson(Map<String, dynamic> json) {
    return EvidenceItem(
      id: json['id'] ?? '',
      titleAr: json['titleAr'] ?? '',
      titleEn: json['titleEn'] ?? '',
      contentAr: json['contentAr'] ?? '',
      contentEn: json['contentEn'] ?? '',
      source: json['source'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleAr': titleAr,
      'titleEn': titleEn,
      'contentAr': contentAr,
      'contentEn': contentEn,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class HadithItem {
  final String id;
  final String textAr;
  final String textEn;
  final String narrator;
  final String source;
  final DateTime createdAt;

  HadithItem({
    required this.id,
    required this.textAr,
    required this.textEn,
    required this.narrator,
    required this.source,
    required this.createdAt,
  });

  factory HadithItem.fromJson(Map<String, dynamic> json) {
    return HadithItem(
      id: json['id'] ?? '',
      textAr: json['textAr'] ?? '',
      textEn: json['textEn'] ?? '',
      narrator: json['narrator'] ?? '',
      source: json['source'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'textAr': textAr,
      'textEn': textEn,
      'narrator': narrator,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class MediaItem {
  final String id;
  final String type;
  final String title;
  final String url;
  final String? description;
  final DateTime createdAt;

  MediaItem({
    required this.id,
    required this.type,
    required this.title,
    required this.url,
    this.description,
    required this.createdAt,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      description: json['description'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'url': url,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class SoundItem {
  final String id;
  final String title;
  final String url;
  final Duration duration;
  final DateTime createdAt;

  SoundItem({
    required this.id,
    required this.title,
    required this.url,
    required this.duration,
    required this.createdAt,
  });

  factory SoundItem.fromJson(Map<String, dynamic> json) {
    return SoundItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      duration: Duration(seconds: json['duration'] ?? 0),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'duration': duration.inSeconds,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class PrayerFormulaSound {
  final String? id;
  final String language;
  final String title;
  final List<int>? soundBinary;
  final String? url;
  final bool isActive;
  final DateTime? createdAt;

  PrayerFormulaSound({
    this.id,
    required this.language,
    required this.title,
    this.soundBinary,
    this.url,
    this.isActive = true,
    this.createdAt,
  });

  factory PrayerFormulaSound.fromJson(Map<String, dynamic> json) {
    List<int>? soundBinary;

    String? id;
    if (json['id'] != null) {
      id = json['id'].toString().trim();
      if (id.isEmpty) id = null;
    }

    final language = json['language'] ?? '';
    final title = json['title'] ?? '';

    debugPrint('[SOUND_LOAD] ===== LOADING SOUND START =====');
    debugPrint('[SOUND_LOAD] ID: $id');
    debugPrint('[SOUND_LOAD] Title: $title');
    debugPrint('[SOUND_LOAD] Language: $language');

    if (json['sound_binary'] != null) {
      final soundData = json['sound_binary'];
      debugPrint(
        '[SOUND_LOAD] Sound binary found - Type: ${soundData.runtimeType}',
      );

      if (soundData is String) {
        if (soundData.isEmpty) {
          debugPrint('[SOUND_LOAD] ✗ WARNING: sound_binary is an empty string');
        } else {
          debugPrint(
            '[SOUND_LOAD] String length: ${soundData.length} characters',
          );

          try {
            if (soundData.startsWith('\\x')) {
              debugPrint('[SOUND_LOAD] Detected: PostgreSQL hex format (\\x)');
              soundBinary = _decodePostgresHex(soundData);
            } else {
              debugPrint('[SOUND_LOAD] Detected: Base64 format');
              // Robust Base64 decoding: ensure length is multiple of 4 by truncating
              String normalizedData = soundData.trim().replaceAll(
                RegExp(r'\s'),
                '',
              );
              if (normalizedData.length % 4 != 0) {
                normalizedData = normalizedData.substring(
                  0,
                  normalizedData.length - (normalizedData.length % 4),
                );
              }
              soundBinary = base64Decode(normalizedData);
            }

            debugPrint('[SOUND_LOAD] ✓ Decoded: ${soundBinary.length} bytes');

            if (soundBinary.isNotEmpty && soundBinary.length >= 4) {
              final header = soundBinary.sublist(0, 4);
              final headerHex = header
                  .map((b) => b.toRadixString(16).padLeft(2, '0'))
                  .join(' ');
              debugPrint(
                '[SOUND_LOAD] Audio header (first 4 bytes): $headerHex',
              );
            }
          } catch (e) {
            debugPrint('[SOUND_LOAD] ✗ ERROR decoding sound binary: $e');
            soundBinary = null;
          }
        }
      } else if (soundData is List) {
        try {
          soundBinary = List<int>.from(soundData);
          debugPrint(
            '[SOUND_LOAD] ✓ Converted list to binary: ${soundBinary.length} bytes',
          );
        } catch (e) {
          debugPrint('[SOUND_LOAD] ✗ ERROR converting list to binary: $e');
          soundBinary = null;
        }
      } else {
        debugPrint(
          '[SOUND_LOAD] ✗ Unknown sound_binary type: ${soundData.runtimeType}',
        );
      }
    } else {
      debugPrint('[SOUND_LOAD] ⚠ No sound_binary field in JSON');
    }

    debugPrint(
      '[SOUND_LOAD] Final result: soundBinary=${soundBinary?.length ?? 0} bytes',
    );
    debugPrint('[SOUND_LOAD] ===== LOADING SOUND END =====');

    bool isActive = true;
    if (json['is_active'] is bool) {
      isActive = json['is_active'] as bool;
    } else if (json['is_active'] is int) {
      isActive = (json['is_active'] as int) == 1;
    }

    return PrayerFormulaSound(
      id: id,
      language: language,
      title: title,
      soundBinary: soundBinary,
      url: json['url'],
      isActive: isActive,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  static List<int> _decodePostgresHex(String hexString) {
    var cleanHex = hexString.trim();

    if (cleanHex.startsWith('\\x')) {
      cleanHex = cleanHex.substring(2);
    }

    cleanHex = cleanHex.replaceAll(RegExp(r'\s'), '');

    if (cleanHex.isEmpty) {
      throw FormatException('Hex string is empty after removing prefix');
    }

    if (cleanHex.length % 2 != 0) {
      throw FormatException(
        'Invalid hex string length: ${cleanHex.length} (must be even)',
      );
    }

    final result = <int>[];
    try {
      for (int i = 0; i < cleanHex.length; i += 2) {
        final hex = cleanHex.substring(i, i + 2);
        final value = int.parse(hex, radix: 16);
        result.add(value);
      }
      debugPrint(
        '[HEX_DEBUG] ✓ Successfully decoded ${result.length} bytes from hex',
      );
      return result;
    } catch (e) {
      debugPrint('[HEX_DEBUG] ✗ Error during hex decode: $e');
      throw FormatException('Failed to decode hex string: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language': language,
      'title': title,
      if (soundBinary != null) 'sound_binary': base64Encode(soundBinary!),
      'url': url,
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  PrayerFormulaSound copyWith({
    String? id,
    String? language,
    String? title,
    List<int>? soundBinary,
    String? url,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return PrayerFormulaSound(
      id: id ?? this.id,
      language: language ?? this.language,
      title: title ?? this.title,
      soundBinary: soundBinary ?? this.soundBinary,
      url: url ?? this.url,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

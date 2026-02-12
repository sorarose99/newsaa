import 'package:flutter/material.dart';

class ReminderConfig {
  final String id;
  final String name;
  final bool enabled;
  final int intervalMinutes;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String? soundId;
  final String? soundTitle;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReminderConfig({
    required this.id,
    required this.name,
    required this.enabled,
    required this.intervalMinutes,
    this.startTime,
    this.endTime,
    this.soundId,
    this.soundTitle,
    required this.createdAt,
    required this.updatedAt,
  });

  ReminderConfig copyWith({
    String? id,
    String? name,
    bool? enabled,
    int? intervalMinutes,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? soundId,
    String? soundTitle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      soundId: soundId ?? this.soundId,
      soundTitle: soundTitle ?? this.soundTitle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'enabled': enabled,
      'intervalMinutes': intervalMinutes,
      'startTime': startTime != null ? _timeOfDayToString(startTime!) : null,
      'endTime': endTime != null ? _timeOfDayToString(endTime!) : null,
      'soundId': soundId,
      'soundTitle': soundTitle,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ReminderConfig.fromJson(Map<String, dynamic> json) {
    return ReminderConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      enabled: json['enabled'] as bool? ?? true,
      intervalMinutes: json['intervalMinutes'] as int,
      startTime: json['startTime'] != null
          ? _stringToTimeOfDay(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? _stringToTimeOfDay(json['endTime'] as String)
          : null,
      soundId: json['soundId'] as String?,
      soundTitle: json['soundTitle'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static String _timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static TimeOfDay _stringToTimeOfDay(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  bool isInTimeRange(DateTime now) {
    if (startTime == null || endTime == null) return true;

    final currentTime = TimeOfDay.fromDateTime(now);
    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;

    if (startMinutes <= endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }
}

extension TimeOfDayExtension on TimeOfDay {
  int toMinutes() => hour * 60 + minute;

  bool isBefore(TimeOfDay other) => toMinutes() < other.toMinutes();

  bool isAfter(TimeOfDay other) => toMinutes() > other.toMinutes();
}

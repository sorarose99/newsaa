class GroupModel {
  final String id;
  final String name;
  final String description;
  final int targetSalawat;
  final int currentSalawat;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isSoloChallenge;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.targetSalawat,
    required this.currentSalawat,
    required this.memberIds,
    required this.createdAt,
    required this.expiresAt,
    this.isSoloChallenge = true,
  });

  double get progress => currentSalawat / targetSalawat;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetSalawat': targetSalawat,
      'currentSalawat': currentSalawat,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isSoloChallenge': isSoloChallenge,
    };
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      targetSalawat: json['targetSalawat'],
      currentSalawat: json['currentSalawat'],
      memberIds: List<String>.from(json['memberIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      isSoloChallenge: json['isSoloChallenge'] ?? true,
    );
  }
}

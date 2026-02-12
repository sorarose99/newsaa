class BadgeTier {
  final String name;
  final String emoji;
  final int minCount;
  final int maxCount;

  BadgeTier({
    required this.name,
    required this.emoji,
    required this.minCount,
    required this.maxCount,
  });

  static final List<BadgeTier> tiers = [
    BadgeTier(
      name: 'بداية مباركة',
      emoji: '🌱',
      minCount: 0,
      maxCount: 100,
    ),
    BadgeTier(
      name: 'الذاكر للنبي',
      emoji: '🌟',
      minCount: 101,
      maxCount: 500,
    ),
    BadgeTier(
      name: 'المحب الصادق',
      emoji: '💫',
      minCount: 501,
      maxCount: 1000,
    ),
    BadgeTier(
      name: 'المجاهد في ذكر النبي',
      emoji: '🏅',
      minCount: 1001,
      maxCount: 5000,
    ),
    BadgeTier(
      name: 'تاج (للواعين)',
      emoji: '👑',
      minCount: 5001,
      maxCount: 10000,
    ),
    BadgeTier(
      name: 'صديق الرسول',
      emoji: '💎',
      minCount: 10001,
      maxCount: 30000,
    ),
    BadgeTier(
      name: 'السابقون بالخيرات',
      emoji: '🏆',
      minCount: 30001,
      maxCount: 50000,
    ),
    BadgeTier(
      name: 'الغائص في ذكر النبي',
      emoji: '🏅',
      minCount: 50001,
      maxCount: 100000,
    ),
    BadgeTier(
      name: 'الولي الصالح',
      emoji: '✨',
      minCount: 100001,
      maxCount: 200000,
    ),
    BadgeTier(
      name: 'هلال في سماء (المحب للنبي)',
      emoji: '🏅',
      minCount: 200001,
      maxCount: 500000,
    ),
    BadgeTier(
      name: 'العاشق للنبي',
      emoji: '🏅',
      minCount: 500001,
      maxCount: 750000,
    ),
    BadgeTier(
      name: 'الواصلون الى الرحمن',
      emoji: '🏅',
      minCount: 750001,
      maxCount: 1000000,
    ),
  ];

  static BadgeTier getTierForCount(int count) {
    for (final tier in tiers) {
      if (count >= tier.minCount && count <= tier.maxCount) {
        return tier;
      }
    }
    return tiers.last;
  }

  static int getProgressPercentage(int count) {
    final tier = getTierForCount(count);
    if (count < tier.minCount) return 0;
    final progress = count - tier.minCount;
    final total = tier.maxCount - tier.minCount;
    return ((progress / total) * 100).toInt();
  }
}

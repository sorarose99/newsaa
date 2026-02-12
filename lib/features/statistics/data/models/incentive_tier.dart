class IncentiveTier {
  final String name;
  final String emoji;
  final int minCount;
  final int maxCount;
  final String motivationalMessage;

  IncentiveTier({
    required this.name,
    required this.emoji,
    required this.minCount,
    required this.maxCount,
    required this.motivationalMessage,
  });

  static final List<IncentiveTier> tiers = [
    IncentiveTier(
      name: 'بداية مباركة',
      emoji: '🌱',
      minCount: 0,
      maxCount: 100,
      motivationalMessage: 'بداية مباركة يا مصلي على النبي، استمر في الذكر',
    ),
    IncentiveTier(
      name: 'الذاكر للنبي',
      emoji: '🌟',
      minCount: 101,
      maxCount: 500,
      motivationalMessage: 'الذاكر للنبي، بارك الله فيك واستمر في الذكر',
    ),
    IncentiveTier(
      name: 'المحب الصادق',
      emoji: '💫',
      minCount: 501,
      maxCount: 1000,
      motivationalMessage: 'المحب الصادق، استمر بارك الله فيك في حب النبي ﷺ',
    ),
    IncentiveTier(
      name: 'المجاهد في ذكر النبي',
      emoji: '🏅',
      minCount: 1001,
      maxCount: 5000,
      motivationalMessage:
          'المجاهد في ذكر النبي، بارك الله فيك لقد وصلت إلى 5000 صلاة',
    ),
    IncentiveTier(
      name: 'تاج (للواعين)',
      emoji: '👑',
      minCount: 5001,
      maxCount: 10000,
      motivationalMessage:
          'تاج (للواعين)، بارك الله فيك لقد وصلت إلى 10000 صلاة',
    ),
    IncentiveTier(
      name: 'صديق الرسول',
      emoji: '💎',
      minCount: 10001,
      maxCount: 30000,
      motivationalMessage: 'صديق الرسول، بارك الله فيك لقد وصلت إلى 30000 صلاة',
    ),
    IncentiveTier(
      name: 'السابقون بالخيرات',
      emoji: '🏆',
      minCount: 30001,
      maxCount: 50000,
      motivationalMessage:
          'السابقون بالخيرات، بارك الله فيك لقد وصلت إلى 50000 صلاة',
    ),
    IncentiveTier(
      name: 'الغائص في ذكر النبي',
      emoji: '🏅',
      minCount: 50001,
      maxCount: 100000,
      motivationalMessage:
          'الغائص في ذكر النبي، بارك الله فيك لقد وصلت إلى 100000 صلاة',
    ),
    IncentiveTier(
      name: 'الولي الصالح',
      emoji: '✨',
      minCount: 100001,
      maxCount: 200000,
      motivationalMessage:
          'الولي الصالح، بارك الله فيك لقد وصلت إلى 200000 صلاة',
    ),
    IncentiveTier(
      name: 'هلال في سماء (المحب للنبي)',
      emoji: '🏅',
      minCount: 200001,
      maxCount: 500000,
      motivationalMessage:
          'هلال في سماء (المحب للنبي)، بارك الله فيك لقد وصلت إلى 500000 صلاة',
    ),
    IncentiveTier(
      name: 'العاشق للنبي',
      emoji: '🏅',
      minCount: 500001,
      maxCount: 750000,
      motivationalMessage:
          'العاشق للنبي، بارك الله فيك لقد وصلت إلى 750000 صلاة',
    ),
    IncentiveTier(
      name: 'الواصلون الى الرحمن',
      emoji: '🏅',
      minCount: 750001,
      maxCount: 1000000,
      motivationalMessage:
          'الواصلون الى الرحمن، بارك الله فيك لقد وصلت إلى 1000000 صلاة',
    ),
  ];

  static IncentiveTier getTierForCount(int count) {
    for (final tier in tiers) {
      if (count >= tier.minCount && count <= tier.maxCount) {
        return tier;
      }
    }
    return tiers.last;
  }
}

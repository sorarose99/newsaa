import 'package:alslat_aalnabi/core/localization/app_localizations.dart';

class LocalizedTierData {
  final String name;
  final String emoji;
  final int minCount;
  final int maxCount;
  final String motivationalMessage;

  LocalizedTierData({
    required this.name,
    required this.emoji,
    required this.minCount,
    required this.maxCount,
    required this.motivationalMessage,
  });
}

class LocalizedTierModel {
  static List<LocalizedTierData> getTiers(AppLocalizations localizations) {
    return [
      LocalizedTierData(
        name: localizations.tier1_name,
        emoji: '🌱',
        minCount: 0,
        maxCount: 100,
        motivationalMessage: localizations.tier1_message,
      ),
      LocalizedTierData(
        name: localizations.tier2_name,
        emoji: '🌟',
        minCount: 101,
        maxCount: 500,
        motivationalMessage: localizations.tier2_message,
      ),
      LocalizedTierData(
        name: localizations.tier3_name,
        emoji: '💫',
        minCount: 501,
        maxCount: 1000,
        motivationalMessage: localizations.tier3_message,
      ),
      LocalizedTierData(
        name: localizations.tier4_name,
        emoji: '🏅',
        minCount: 1001,
        maxCount: 5000,
        motivationalMessage: localizations.tier4_message,
      ),
      LocalizedTierData(
        name: localizations.tier5_name,
        emoji: '👑',
        minCount: 5001,
        maxCount: 10000,
        motivationalMessage: localizations.tier5_message,
      ),
      LocalizedTierData(
        name: localizations.tier6_name,
        emoji: '💎',
        minCount: 10001,
        maxCount: 30000,
        motivationalMessage: localizations.tier6_message,
      ),
      LocalizedTierData(
        name: localizations.tier7_name,
        emoji: '🏆',
        minCount: 30001,
        maxCount: 50000,
        motivationalMessage: localizations.tier7_message,
      ),
      LocalizedTierData(
        name: localizations.tier8_name,
        emoji: '🏅',
        minCount: 50001,
        maxCount: 100000,
        motivationalMessage: localizations.tier8_message,
      ),
      LocalizedTierData(
        name: localizations.tier9_name,
        emoji: '✨',
        minCount: 100001,
        maxCount: 200000,
        motivationalMessage: localizations.tier9_message,
      ),
      LocalizedTierData(
        name: localizations.tier10_name,
        emoji: '🏅',
        minCount: 200001,
        maxCount: 500000,
        motivationalMessage: localizations.tier10_message,
      ),
      LocalizedTierData(
        name: localizations.tier11_name,
        emoji: '🏅',
        minCount: 500001,
        maxCount: 750000,
        motivationalMessage: localizations.tier11_message,
      ),
      LocalizedTierData(
        name: localizations.tier12_name,
        emoji: '🏅',
        minCount: 750001,
        maxCount: 1000000,
        motivationalMessage: localizations.tier12_message,
      ),
    ];
  }

  static LocalizedTierData getTierForCount(
    int count,
    AppLocalizations localizations,
  ) {
    final tiers = getTiers(localizations);
    for (final tier in tiers) {
      if (count >= tier.minCount && count <= tier.maxCount) {
        return tier;
      }
    }
    return tiers.last;
  }
}

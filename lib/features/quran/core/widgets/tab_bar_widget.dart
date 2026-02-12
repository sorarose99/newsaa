import 'package:flutter/material.dart';
import 'package:alslat_aalnabi/features/quran/core/utils/constants/extensions/bottom_sheet_extension.dart';
import 'package:alslat_aalnabi/features/quran/core/utils/constants/extensions/svg_extensions.dart';
import 'package:alslat_aalnabi/features/quran/core/utils/constants/svg_constants.dart';
import 'package:alslat_aalnabi/features/quran/core/widgets/settings_list.dart';

class TabBarWidget extends StatelessWidget {
  final bool isCenterChild;
  final Widget? centerChild;
  final bool? isQuranSetting;
  final bool isNotification;
  final void Function()? settingOnTap;
  final String? juzName;
  final String? surahName;

  const TabBarWidget({
    super.key,
    required this.isCenterChild,
    this.centerChild,
    this.isQuranSetting,
    required this.isNotification,
    this.settingOnTap,
    this.juzName,
    this.surahName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Transform.translate(
          offset: const Offset(0, -2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(flex: 3, child: SizedBox.shrink()),
              Expanded(
                flex: 4,
                child: isQuranSetting ?? false
                    ? GestureDetector(
                        onTap: () => customBottomSheet(
                          SettingsList(isQuranSetting: true),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const SizedBox().customSvgWithColor(
                              SvgPath.svgButtonCurve,
                              height: 35.0,
                              width: 35.0,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            Container(
                              padding: const EdgeInsets.all(3),
                              margin: const EdgeInsets.only(bottom: 3),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(4),
                                ),
                                border: Border.all(
                                  width: 1,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                              child: const SizedBox().customSvgWithCustomColor(
                                SvgPath.svgSliderIc,
                                height: 20,
                                width: 20,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const Expanded(flex: 3, child: SizedBox.shrink()),
            ],
          ),
        ),
        if (isCenterChild)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: centerChild!,
          ),
      ],
    );
  }
}

import 'package:alslat_aalnabi/features/quran/core/utils/constants/extensions/svg_extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import 'package:alslat_aalnabi/features/quran/presentation/controllers/theme_controller.dart';
import 'package:alslat_aalnabi/features/quran/presentation/screens/quran_page/quran.dart';
import 'package:alslat_aalnabi/features/quran/core/utils/constants/lists.dart';
import 'package:alslat_aalnabi/features/quran/core/utils/constants/shared_preferences_constants.dart';
import 'package:alslat_aalnabi/features/settings/presentation/widgets/settings_provider.dart';
import 'package:provider/provider.dart';

class ThemeChange extends StatelessWidget {
  const ThemeChange({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = ThemeController.instance;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'themeTitle'.tr,
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontFamily: 'kufi',
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Gap(4),
          Container(
            width: Get.width,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 1,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: List.generate(
                themeList.length,
                (index) => Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  padding: const EdgeInsets.all(4.0),
                  margin: const EdgeInsets.all(4.0),
                  child: Obx(
                    () => AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 300),
                      child: GestureDetector(
                        onTap: () {
                          final settingsProvider =
                              Provider.of<SettingsProvider>(
                                context,
                                listen: false,
                              );
                          settingsProvider.setQuranTheme(
                            (themeList[index]['name'] as AppTheme).name,
                          );
                          final newColor = themeCtrl
                              .currentThemeData
                              .colorScheme
                              .surfaceContainer
                              .value;
                          QuranController
                                  .instance
                                  .state
                                  .backgroundPickerColor
                                  .value =
                              newColor;
                          QuranController.instance.state.box.write(
                            BACKGROUND_PICKER_COLOR,
                            newColor,
                          );
                          Get.forceAppUpdate().then((_) {
                            Get.back();
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: Text(
                                  '${themeList[index]['title']}'.tr,
                                  style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontFamily: 'kufi',
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            const Gap(4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                customSvg(
                                  themeList[index]['svgUrl'],
                                  height: 75,
                                ),
                                const Gap(6),
                                Container(
                                  height: 20,
                                  width: 20,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(20.0),
                                    ),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      width: 2,
                                    ),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  child:
                                      themeList[index]['name'] ==
                                          themeCtrl.currentTheme
                                      ? const Icon(
                                          Icons.done,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

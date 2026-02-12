import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:alslat_aalnabi/features/quran/core/utils/constants/extensions/extensions.dart';
import 'package:alslat_aalnabi/features/quran/core/utils/constants/lists.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:alslat_aalnabi/features/quran/presentation/screens/quran_page/quran.dart';
import 'package:alslat_aalnabi/features/quran/core/utils/constants/shared_preferences_constants.dart';
import 'package:alslat_aalnabi/features/quran/core/widgets/theme_change.dart';

class MushafSettings extends StatelessWidget {
  MushafSettings({super.key});

  final quranCtrl = QuranController.instance;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'choiceBackgroundColor'.tr,
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 1,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Color(
                              quranCtrl.state.backgroundPickerColor.value,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await ColorPicker(
                            color: Color(
                              quranCtrl.state.backgroundPickerColor.value,
                            ),
                            onColorChanged: (Color color) {
                              quranCtrl.state.backgroundPickerColor.value =
                                  color.value;
                              quranCtrl.state.box.write(
                                BACKGROUND_PICKER_COLOR,
                                color.value,
                              );
                              quranCtrl.update();
                            },
                            width: 40,
                            height: 40,
                            borderRadius: 20,
                            spacing: 10,
                            runSpacing: 10,
                            wheelDiameter: 165,
                            enableOpacity: false,
                            showMaterialName: true,
                            showColorName: true,
                            showColorCode: true,
                            copyPasteBehavior:
                                const ColorPickerCopyPasteBehavior(
                                  longPressMenu: true,
                                ),
                            pickerTypeLabels: <ColorPickerType, String>{
                              ColorPickerType.primary: 'primary'.tr,
                              ColorPickerType.accent: 'accent'.tr,
                            },
                          ).showPickerDialog(
                            context,
                            constraints: const BoxConstraints(
                              minHeight: 460,
                              minWidth: 300,
                              maxWidth: 320,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'choose'.tr == 'choose' ? 'اختر' : 'choose'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'kufi',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                          0xFFF5ECDA,
                          0xFFDED4C0,
                          0xFFE7D9BC,
                          0xFFF1E5C9,
                          0xFFFFF7E6,
                          0xFFFAF7F3,
                          0xFFE8E0D1,
                          0xFFD7CBB3,
                        ].map((colorValue) {
                          return GestureDetector(
                            onTap: () {
                              quranCtrl.state.backgroundPickerColor.value =
                                  colorValue;
                              quranCtrl.state.box.write(
                                BACKGROUND_PICKER_COLOR,
                                colorValue,
                              );
                              quranCtrl.update();
                            },
                            child: Obx(
                              () => Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Color(colorValue),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        quranCtrl
                                                .state
                                                .backgroundPickerColor
                                                .value ==
                                            colorValue
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.withAlpha(100),
                                    width:
                                        quranCtrl
                                                .state
                                                .backgroundPickerColor
                                                .value ==
                                            colorValue
                                        ? 2
                                        : 1,
                                  ),
                                ),
                                child:
                                    quranCtrl
                                            .state
                                            .backgroundPickerColor
                                            .value ==
                                        colorValue
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.black,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
            const Gap(16),
            const ThemeChange(),
            const Gap(16),
            Text(
              'choseQuran'.tr,
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
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 1,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: Column(
                children: [
                  const Gap(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      mushafSettingsList.length,
                      (index) => Obx(() {
                        return AnimatedOpacity(
                          opacity: 1,
                          duration: const Duration(milliseconds: 300),
                          child: GestureDetector(
                            onTap: () => quranCtrl.switchMode(index),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(4.0),
                                    ),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      width: 1,
                                    ),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  child: Image.asset(
                                    mushafSettingsList[index]['imageUrl'],
                                    width: 50,
                                  ),
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
                                  child: quranCtrl.state.isPages.value == index
                                      ? const Icon(
                                          Icons.done,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const Gap(8),
                  context.hDivider(width: MediaQuery.sizeOf(context).width),
                  const Gap(8),
                  Column(
                    children: List.generate(
                      2,
                      (index) => Obx(
                        () => GestureDetector(
                          onTap: () {
                            quranCtrl.state.isBold.value = index.isEven
                                ? true
                                : false;
                            GetStorage().write(
                              IS_BOLD,
                              quranCtrl.state.isBold.value,
                            );
                            quranCtrl.update(['clearSelection']);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                child:
                                    quranCtrl.state.isBold.value == index.isEven
                                    ? const Icon(
                                        Icons.done,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const Gap(6),
                              Text(
                                'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَيُّ ٱلۡقَيُّومُ',
                                style: TextStyle(
                                  fontFamily: 'uthmanic2',
                                  fontSize: 18,
                                  height: 1.9,
                                  fontWeight: index.isEven
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.inversePrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

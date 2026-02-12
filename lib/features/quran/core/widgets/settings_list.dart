import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import 'package:alslat_aalnabi/features/quran/core/utils/constants/extensions/extensions.dart';
import 'package:alslat_aalnabi/features/quran/core/widgets/select_screen_build.dart';
import 'package:alslat_aalnabi/features/quran/presentation/controllers/theme_controller.dart';
import 'package:alslat_aalnabi/features/quran/core/widgets/mushaf_settings.dart';
import 'package:alslat_aalnabi/features/quran/presentation/controllers/general/general_controller.dart';
import 'package:alslat_aalnabi/features/quran/presentation/screens/quran_page/quran.dart';

class SettingsList extends StatelessWidget {
  final bool? isQuranSetting;
  SettingsList({Key? key, this.isQuranSetting}) : super(key: key);
  final generalCtrl = GeneralController.instance;
  final quranCtrl = QuranController.instance;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return GetBuilder<ThemeController>(
      builder: (_) {
        return Container(
          height: size.height * .9,
          width: size.width,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(
                () => generalCtrl.state.showSelectScreenPage.value
                    ? const SelectScreenBuild(
                        isButtonBack: true,
                        isButton: false,
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                context.customClose(),
                                const Gap(8),
                                context.vDivider(height: 20),
                                const Gap(8),
                                Text(
                                  'setting'.tr,
                                  style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontFamily: 'kufi',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(8),
                          Flexible(
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                const Gap(32),
                                MushafSettings(),
                                const Gap(16),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

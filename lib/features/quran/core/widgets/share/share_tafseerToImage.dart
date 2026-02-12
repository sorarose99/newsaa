import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:quran_library/quran.dart';
import 'package:screenshot/screenshot.dart';

import 'package:alslat_aalnabi/features/quran/core/utils/constants/extensions/alignment_rotated_extension.dart';
import 'package:alslat_aalnabi/features/quran/core/utils/constants/extensions/svg_extensions.dart';
import 'package:alslat_aalnabi/features/quran/presentation/screens/quran_page/quran.dart';
import 'package:alslat_aalnabi/features/quran/core/utils/constants/extensions/extensions.dart';

class TafseerImageCreator extends StatelessWidget {
  final int verseNumber;
  final int verseUQNumber;
  final int surahNumber;
  final String verseText;

  final tafseerToImage = ShareController.instance;
  final quranCtrl = QuranController.instance;

  TafseerImageCreator({
    super.key,
    required this.verseNumber,
    required this.verseUQNumber,
    required this.surahNumber,
    required this.verseText,
  });

  // إرجاع نص الترجمة بأمان وفقًا للرقم العالمي للآية
  String _safeTranslationText(int verseUQNumber) {
    final list = QuranLibrary().translationList;
    final idx = verseUQNumber - 1;
    if (idx < 0 || idx >= list.length) return '';
    return list[idx].text;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Screenshot(
          controller: tafseerToImage.tafseerScreenController,
          child: buildVerseImageWidget(
            context: context,
            verseNumber: verseNumber,
            verseUQNumber: verseUQNumber,
            surahNumber: surahNumber,
            verseText: verseText,
          ),
        ),
      ],
    );
  }

  Widget buildVerseImageWidget({
    required BuildContext context,
    required int verseNumber,
    required int verseUQNumber,
    required int surahNumber,
    required String verseText,
  }) {
    return GetBuilder<TranslateController>(
      builder: (translateController) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            width: 960.0,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              children: [
                const Gap(8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/svg/splash_icon_w.svg',
                              height: 40,
                            ),
                            context.vDivider(),
                            const Text(
                              'القـرآن الكريــــم\nمكتبة الحكمة',
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'kufi',
                                color: Color(0xffffffff),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: context.hDivider(
                          width: MediaQuery.sizeOf(context).width,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    color: Color(0xffffffff),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const Gap(6),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            customSvg(quranCtrl.surahBannerPath),
                            surahNameWidget(
                              height: 25,
                              '$surahNumber',
                              Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                        const Gap(16),
                        SizedBox(
                          width: 928.0,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Text(
                                  '﴿ $verseText ${tafseerToImage.arabicNumber.convert(verseNumber)} ﴾',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'uthmanic2',
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.inversePrimary,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                              const Gap(16),
                              Align(
                                alignment: alignmentLayoutWPassLang(
                                  '${tafseerToImage.currentTranslate.value}',
                                  Alignment.centerRight,
                                  Alignment.centerLeft,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inverseSurface
                                        .withValues(alpha: .3),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  child: Obx(
                                    () => Text(
                                      tafseerToImage.currentTranslate.value,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'kufi',
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.inversePrimary,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                ),
                              ),
                              const Gap(8),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: .15),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                child: Obx(
                                  () => Text.rich(
                                    TextSpan(
                                      text: _safeTranslationText(verseUQNumber),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: 'naskh',
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.inversePrimary,
                                      ),
                                    ),
                                    textAlign: TextAlign.justify,
                                    textDirection: alignmentLayoutWPassLang(
                                      tafseerToImage.currentTranslate.value,
                                      TextDirection.rtl,
                                      TextDirection.ltr,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

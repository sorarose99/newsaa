part of '../../quran.dart';

class TranslateBuild extends StatelessWidget {
  final List<AyahModel> ayahs;
  final int ayahIndex;
  final int pageIndex;

  TranslateBuild({
    super.key,
    required this.ayahs,
    required this.ayahIndex,
    required this.pageIndex,
  });

  final transCtrl = TranslateController.instance;

  @override
  Widget build(BuildContext context) {
    transCtrl.expandedMap[ayahs[ayahIndex].ayahUQNumber - 1] =
        transCtrl.expandedMap[ayahs[ayahIndex].ayahUQNumber - 1] ?? false;
    // QuranController.instance.updateTafsir(pageIndex + 1);
    // QuranLibrary().initializeDatabase();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: GetBuilder<TranslateController>(
              id: 'tafsirs_menu_list',
              builder: (tafsirCtrl) {
                return QuranLibrary().changeTafsirPopupMenu(
                  TafsirStyle(
                    backgroundColor: Get.theme.colorScheme.primary,
                    textColor: QuranController.instance.adaptiveTextColor,
                    backgroundTitleColor: Get.theme.colorScheme.surface
                        .withValues(alpha: .5),
                    fontSizeWidget: fontSizeDropDownWidget(),
                    fontSize:
                        sl<GeneralController>().state.fontSizeArabic.value,
                    currentTafsirColor: Get.theme.colorScheme.surface,
                    selectedTafsirBorderColor: Get.theme.colorScheme.surface,
                    selectedTafsirColor: Get.theme.colorScheme.surface,
                    unSelectedTafsirColor: QuranController
                        .instance
                        .adaptiveTextColor
                        .withValues(alpha: .8),
                    selectedTafsirTextColor: Get.theme.colorScheme.surface,
                    unSelectedTafsirTextColor: QuranController
                        .instance
                        .adaptiveTextColor
                        .withValues(alpha: .8),
                    unSelectedTafsirBorderColor: Colors.transparent,
                    dividerColor: Get.theme.colorScheme.surface.withValues(
                      alpha: .5,
                    ),
                    textTitleColor: context.theme.colorScheme.surface,
                    horizontalMargin: 16.0,
                    tafsirBackgroundColor:
                        Get.theme.colorScheme.primaryContainer,
                    tafsirNameWidget: customSvgWithCustomColor(
                      SvgPath.svgTafseerWhite,
                      color: Get.theme.canvasColor,
                      height: 25,
                    ),
                    footnotesName: 'footnotes'.tr,
                    tafsirName: 'tafseer'.tr,
                    translateName: 'translation'.tr,
                  ),
                  isDark: Theme.of(context).brightness == Brightness.dark,
                );
              },
            ),
          ),
          const Gap(10),
          GetBuilder<TranslateController>(
            id: 'tafsirs_menu_list',
            builder: (tafsirCtrl) {
              return QuranLibrary().isTafsir
                  ? Directionality(
                      textDirection: alignmentLayoutWPassLang(
                        QuranLibrary()
                            .tafsirAndTraslationsCollection[QuranLibrary()
                                        .selectedTafsirIndex >=
                                    QuranLibrary()
                                        .tafsirAndTraslationsCollection
                                        .length
                                ? 0
                                : QuranLibrary().selectedTafsirIndex]
                            .bookName,
                        TextDirection.rtl,
                        TextDirection.ltr,
                      ),
                      child: ReadMoreLess(
                        text: transCtrl
                            .getAyahTranslation(ayahs[ayahIndex].ayahUQNumber)
                            .tafsirText
                            .buildTextSpans(),
                        textStyle: TextStyle(
                          fontSize:
                              (sl<GeneralController>()
                                  .state
                                  .fontSizeArabic
                                  .value -
                              3),
                          fontFamily:
                              sl<SettingsController>().languageFont.value,
                          color: QuranController.instance.adaptiveTextColor,
                          overflow: TextOverflow.fade,
                        ),
                        textAlign: alignmentLayoutWPassLang(
                          QuranLibrary()
                              .tafsirAndTraslationsCollection[QuranLibrary()
                                          .selectedTafsirIndex >=
                                      QuranLibrary()
                                          .tafsirAndTraslationsCollection
                                          .length
                                  ? 0
                                  : QuranLibrary().selectedTafsirIndex]
                              .bookName,
                          TextAlign.right,
                          TextAlign.left,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        maxLines: 1,
                        collapsedHeight: 18,
                        readMoreText: 'readMore'.tr,
                        readLessText: 'readLess'.tr,
                        buttonTextStyle: TextStyle(
                          fontSize: 12,
                          fontFamily: 'kufi',
                          color: QuranController.instance.adaptiveTextColor,
                        ),
                        iconColor: QuranController.instance.adaptiveTextColor,
                      ),
                    )
                  : Directionality(
                      textDirection: alignmentLayoutWPassLang(
                        QuranLibrary()
                            .tafsirAndTraslationsCollection[QuranLibrary()
                                        .selectedTafsirIndex >=
                                    QuranLibrary()
                                        .tafsirAndTraslationsCollection
                                        .length
                                ? 0
                                : QuranLibrary().selectedTafsirIndex]
                            .bookName,
                        TextDirection.rtl,
                        TextDirection.ltr,
                      ),
                      child: ReadMoreLess(
                        text: _buildTranslationSpans(),
                        textStyle: TextStyle(
                          fontSize:
                              (sl<GeneralController>()
                                  .state
                                  .fontSizeArabic
                                  .value -
                              3),
                          fontFamily:
                              sl<SettingsController>().languageFont.value,
                          color: QuranController.instance.adaptiveTextColor,
                          overflow: TextOverflow.fade,
                        ),
                        textAlign: alignmentLayoutWPassLang(
                          QuranLibrary()
                              .tafsirAndTraslationsCollection[QuranLibrary()
                                          .selectedTafsirIndex >=
                                      QuranLibrary()
                                          .tafsirAndTraslationsCollection
                                          .length
                                  ? 0
                                  : QuranLibrary().selectedTafsirIndex]
                              .bookName,
                          TextAlign.right,
                          TextAlign.left,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        maxLines: 1,
                        collapsedHeight: 18,
                        readMoreText: 'readMore'.tr,
                        readLessText: 'readLess'.tr,
                        buttonTextStyle: TextStyle(
                          fontSize: 12,
                          fontFamily: 'kufi',
                          color: QuranController.instance.adaptiveTextColor,
                        ),
                        iconColor: QuranController.instance.adaptiveTextColor,
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }

  // بناء spans للترجمة مع الحواشي
  List<TextSpan> _buildTranslationSpans() {
    // السماح بالآية ذات الفهرس 0، ونتأكد من وجود بيانات ترجمة
    if (QuranLibrary().translationList.isEmpty || ayahIndex < 0) {
      return [const TextSpan(text: '')];
    }

    // استخدام دالة helper من TranslateController للحصول على الترجمة
    final translation = TranslateController.instance.getTranslationForAyahModel(
      ayahs[ayahIndex],
      ayahs[ayahIndex].ayahUQNumber,
    );

    if (translation == null || translation.cleanText.isEmpty) {
      return [
        TextSpan(
          text: '\n\nتفسير هذه الآية في الأيات السابقة',
          style: QuranLibrary().cairoStyle.copyWith(
            fontSize: (sl<GeneralController>().state.fontSizeArabic.value - 3),
            color: QuranController.instance.adaptiveTextColor,
          ),
        ),
      ];
    }
    final spans = <TextSpan>[
      // النص الأساسي بدون HTML tags
      TextSpan(children: translation.cleanText.customTextSpans()),
    ];

    // إضافة الحواشي إذا وجدت
    final footnotes = translation.orderedFootnotesWithNumbers;
    if (footnotes.isNotEmpty) {
      spans.add(const TextSpan(text: '\n\n'));
      // فاصل نصي بدل WidgetSpan لضمان توافق النوع
      spans.add(
        TextSpan(
          text: '————————————',
          style: TextStyle(
            color: QuranController.instance.adaptiveTextColor.withValues(
              alpha: .7,
            ),
          ),
        ),
      );
      spans.add(const TextSpan(text: '\n'));

      for (final footnoteEntry in footnotes) {
        final number = footnoteEntry.key;
        final footnoteData = footnoteEntry.value;

        spans.add(
          TextSpan(
            children: [
              TextSpan(
                text: '($number) ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize:
                      (sl<GeneralController>().state.fontSizeArabic.value - 5),
                  color: QuranController.instance.adaptiveTextColor.withValues(
                    alpha: .7,
                  ),
                ),
              ),
              TextSpan(
                text: '${footnoteData.value}\n\n',
                style: TextStyle(
                  fontSize:
                      (sl<GeneralController>().state.fontSizeArabic.value - 5),
                  color: QuranController.instance.adaptiveTextColor.withValues(
                    alpha: .7,
                  ),
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      }
    }

    return spans;
  }
}

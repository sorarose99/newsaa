part of '../../quran.dart';

class AyahsBuild extends StatelessWidget {
  final int pageIndex;
  AyahsBuild({super.key, required this.pageIndex});

  final quranCtrl = QuranController.instance;
  final transCtrl = TranslateController.instance;

  @override
  Widget build(BuildContext context) {
    TranslateController.instance.loadTranslateValue();
    return Column(
      children: [
        PageHeader(pageIndex: pageIndex),
        ...QuranLibrary.quranCtrl
            .getCurrentPageAyahsSeparatedForBasmalah(pageIndex)
            .asMap()
            .entries
            .map((entry) {
              return _fontsAyahsBuild(
                context,
                pageIndex,
                entry.key,
                entry.value,
              );
            }),
      ],
    );
  }

  Widget _fontsAyahsBuild(
    BuildContext context,
    int pageIndex,
    int i,
    List<AyahModel> ayahs,
  ) {
    return Column(
      children: [
        surahAyahBannerFirstPlace(pageIndex, i),
        Obx(() {
          return Column(
            children: List.generate(ayahs.length, (ayahIndex) {
              quranCtrl.state.isSelected = quranCtrl.state.selectedAyahIndexes
                  .contains(ayahs[ayahIndex].ayahUQNumber);
              return MeasureSizeWidget(
                onChange: (size) {
                  quranCtrl.state.ayahsWidgetHeight.value = size.height;
                  // print("Item $ayahIndex size: ${size.height}");
                },
                child: Container(
                  key: ValueKey(i),
                  child: GestureDetector(
                    onLongPress: () => quranCtrl.toggleAyahSelection(
                      ayahs[ayahIndex].ayahUQNumber,
                    ),
                    child: Column(
                      children: [
                        Gap(16.h),
                        AyahsMenu(
                          surahNum: QuranLibrary()
                              .getCurrentSurahDataByAyahUniqueNumber(
                                ayahUniqueNumber: ayahs[ayahIndex].ayahUQNumber,
                              )
                              .surahNumber,
                          ayahNum: ayahs[ayahIndex].ayahNumber,
                          ayahText: ayahs[ayahIndex].text,
                          pageIndex: pageIndex,
                          ayahTextNormal: ayahs[ayahIndex].text,
                          ayahUQNum: ayahs[ayahIndex].ayahUQNumber,
                          surahName: quranCtrl.state.surahs
                              .firstWhere(
                                (s) => s.ayahs.contains(ayahs[ayahIndex]),
                              )
                              .arabicName,
                          isSelected: quranCtrl.state.isSelected,
                          index: ayahIndex,
                        ),
                        Gap(16.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Obx(
                            () => RichText(
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'uthmanic2',
                                  fontSize:
                                      (sl<GeneralController>()
                                              .state
                                              .fontSizeArabic
                                              .value)
                                          .sp,
                                  height: 1.5,
                                  color: quranCtrl.adaptiveTextColor,
                                ),
                                children: [
                                  ayahIndex == 0
                                      ? span(
                                          isFirstAyah: true,
                                          text:
                                              "${ayahs[ayahIndex].text[0].replaceAll('\n', '')}${ayahs[ayahIndex].text.substring(1).replaceAll('\n', '')}",
                                          fontFamily: 'uthmanic2',
                                          pageIndex: pageIndex,
                                          isSelected:
                                              quranCtrl.state.isSelected,
                                          letterSpacing: 0.0,
                                          fontSize:
                                              (sl<GeneralController>()
                                                      .state
                                                      .fontSizeArabic
                                                      .value)
                                                  .sp,
                                          surahNum: quranCtrl
                                              .getSurahDataByAyahUQ(
                                                ayahs[ayahIndex].ayahUQNumber,
                                              )
                                              .surahNumber,
                                          ayahNum:
                                              ayahs[ayahIndex].ayahUQNumber,
                                        )
                                      : span(
                                          isFirstAyah: false,
                                          text: ayahs[ayahIndex].text
                                              .replaceAll('\n', ''),
                                          fontFamily: 'uthmanic2',
                                          pageIndex: pageIndex,
                                          isSelected:
                                              quranCtrl.state.isSelected,
                                          letterSpacing: 0.0,
                                          fontSize:
                                              (sl<GeneralController>()
                                                      .state
                                                      .fontSizeArabic
                                                      .value)
                                                  .sp,
                                          surahNum: quranCtrl
                                              .getSurahDataByAyahUQ(
                                                ayahs[ayahIndex].ayahUQNumber,
                                              )
                                              .surahNumber,
                                          ayahNum:
                                              ayahs[ayahIndex].ayahUQNumber,
                                        ),
                                  TextSpan(
                                    text:
                                        ' ${ayahs[ayahIndex].ayahNumber.toString().convertEnglishNumbersToArabic(ayahs[ayahIndex].ayahNumber.toString())}',
                                    style: TextStyle(
                                      fontFamily: 'uthmanic2',
                                      fontSize:
                                          (sl<GeneralController>()
                                                      .state
                                                      .fontSizeArabic
                                                      .value +
                                                  3)
                                              .sp,
                                      height: 1.5,
                                      color: quranCtrl.adaptiveTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Gap(16.h),
                        TranslateBuild(
                          ayahs: ayahs,
                          ayahIndex: ayahIndex,
                          pageIndex: pageIndex,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }),
        Gap(32.h),
        Align(
          alignment: pageIndex.isEven
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            height: 35.h,
            width: 120.w,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/svg/surah_name/00${QuranLibrary().getCurrentSurahDataByPageNumber(pageNumber: pageIndex + 1).surahNumber}.svg',
                height: 25.h,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primaryContainer,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

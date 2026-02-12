part of '../../quran.dart';

class TextBuild extends StatelessWidget {
  final int pageIndex;

  TextBuild({super.key, required this.pageIndex});

  final audioCtrl = AudioController.instance;
  final quranCtrlGlobal = QuranController.instance;
  final bookmarkCtrl = BookmarksController.instance;
  final themeCtrl = ThemeController.instance;
  final generalCtrl = GeneralController.instance;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuranController>(
      id: 'clearSelection',
      builder: (controller) => Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final deviceRatio = constraints.maxWidth / constraints.maxHeight;
              const virtualWidth = 500.0;
              final dynamicHeight = virtualWidth / deviceRatio;

              final pageAyahs = quranCtrlGlobal.getPageAyahsByIndex(pageIndex);
              final surahCount = pageAyahs
                  .map((a) => a.surahNumber)
                  .toSet()
                  .length;

              // 4. granular Conditional "No-Scroll" Height
              // 1 or 2 surahs fit perfectly with +175.
              // 3 or more surahs (like page 604) need +550 to avoid any overflow.
              final finalVirtualHeight = (surahCount > 2)
                  ? dynamicHeight + 550.0
                  : dynamicHeight + 340.0;

              return Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      size: Size(virtualWidth, finalVirtualHeight),
                      textScaler: TextScaler.noScaling,
                      padding: EdgeInsets.zero,
                    ),
                    child: SizedBox(
                      width: virtualWidth,
                      height: finalVirtualHeight,
                      child: Builder(
                        builder: (innerContext) => QuranLibraryScreen(
                          parentContext: innerContext,
                          isDark:
                              Theme.of(context).brightness == Brightness.dark,
                          isFontsLocal: true,
                          withPageView: false,
                          useDefaultAppBar: false,
                          isShowAudioSlider: false,
                          pageIndex: pageIndex,
                          appLanguageCode: Get.locale!.languageCode,
                          bookmarkList:
                              BookmarksController.instance.bookmarkTextList,
                          fontsName: 'page${pageIndex + 1}',
                          backgroundColor: quranCtrlGlobal.backgroundColor,
                          textColor: quranCtrlGlobal.adaptiveTextColor,
                          ayahSelectedBackgroundColor: Get.theme.highlightColor,
                          bookmarksColor: Get.theme.colorScheme.inverseSurface
                              .withValues(alpha: .4),
                          ayahBookmarked: BookmarksController.instance
                              .hasBookmark2(pageIndex),
                          ayahIconColor: Get.theme.colorScheme.inverseSurface,
                          topBottomQuranStyle: TopBottomQuranStyle.defaults(
                            isDark:
                                Theme.of(context).brightness == Brightness.dark,
                            context: context,
                          ).copyWith(juzName: 'juz'.tr, sajdaName: 'sajda'.tr),
                          basmalaStyle: BasmalaStyle(
                            basmalaColor: quranCtrlGlobal.adaptiveTextColor
                                .withValues(alpha: .8),
                            basmalaFontSize: 20.0,
                            verticalPadding: 0.0,
                          ),
                          surahInfoStyle: SurahInfoStyle(
                            ayahCount: 'aya_count'.tr,
                            backgroundColor:
                                Get.theme.colorScheme.primaryContainer,
                            closeIconColor:
                                Get.theme.colorScheme.inversePrimary,
                            firstTabText: 'surahNames'.tr,
                            secondTabText: 'aboutSurah'.tr,
                            indicatorColor: Get.theme.colorScheme.surface,
                            primaryColor: Get.theme.colorScheme.surface
                                .withValues(alpha: .2),
                            surahNameColor: Get.theme.colorScheme.primary,
                            surahNumberColor: Get.theme.hintColor,
                            textColor: quranCtrlGlobal.adaptiveTextColor,
                            titleColor: Get.theme.hintColor,
                          ),
                          onPagePress: () => audioCtrl.clearSelection(),
                          onAyahLongPress: (details, ayah) {
                            final surah = QuranLibrary()
                                .getCurrentSurahDataByAyah(ayah: ayah);
                            context.showAyahMenu(
                              surahNum: surah.surahNumber,
                              ayahNum: ayah.ayahNumber,
                              ayahText: ayah.text,
                              pageIndex: pageIndex,
                              ayahTextNormal: ayah.ayaTextEmlaey,
                              ayahUQNum: ayah.ayahUQNumber,
                              surahName: surah.arabicName,
                              details: details,
                            );
                            controller.toggleAyahSelection(ayah.ayahUQNumber);
                          },
                          tafsirStyle:
                              TafsirStyle.defaults(
                                isDark:
                                    Theme.of(context).brightness ==
                                    Brightness.dark,
                                context: context,
                              ).copyWith(
                                backgroundColor: Get.theme.colorScheme.primary,
                                textColor: quranCtrlGlobal.adaptiveTextColor,
                                backgroundTitleColor: Get
                                    .theme
                                    .colorScheme
                                    .surface
                                    .withValues(alpha: .5),
                                fontSizeWidget: fontSizeDropDownWidget(),
                                fontSize:
                                    generalCtrl.state.fontSizeArabic.value,
                                currentTafsirColor:
                                    Get.theme.colorScheme.surface,
                                selectedTafsirBorderColor:
                                    Get.theme.colorScheme.surface,
                                selectedTafsirColor:
                                    Get.theme.colorScheme.surface,
                                unSelectedTafsirColor: Get.theme.canvasColor
                                    .withValues(alpha: .8),
                                selectedTafsirTextColor:
                                    Get.theme.colorScheme.surface,
                                unSelectedTafsirTextColor: Get.theme.canvasColor
                                    .withValues(alpha: .8),
                                unSelectedTafsirBorderColor: Colors.transparent,
                                dividerColor: Get.theme.colorScheme.surface
                                    .withValues(alpha: .5),
                                textTitleColor: context.theme.canvasColor,
                                horizontalMargin: 0.0,
                                tafsirBackgroundColor:
                                    Get.theme.colorScheme.primaryContainer,
                                tafsirNameWidget: customSvgWithCustomColor(
                                  SvgPath.svgTafseerWhite,
                                  color: Get.theme.canvasColor,
                                  height: 20.0,
                                ),
                                footnotesName: 'footnotes'.tr,
                                tafsirName: 'tafseer'.tr,
                                translateName: 'translation'.tr,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            left: pageIndex.isEven ? null : 0,
            right: pageIndex.isEven ? 0 : null,
            child: GestureDetector(
              onTap: () => bookmarkCtrl.addPageBookmarkOnTap(pageIndex),
              child: _BookmarkIcon(
                height: context.customOrientation(30.0, 40.0),
                pageNum: pageIndex + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookmarkIcon extends StatelessWidget {
  final int? pageNum;

  final double? height;

  const _BookmarkIcon({this.pageNum, this.height});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuranController>(
      id: 'pageBookmarked',

      builder: (controller) {
        return Semantics(
          button: true,

          enabled: true,

          label: 'Add Bookmark',

          child: customSvg(
            BookmarksController.instance
                    .hasPageBookmark(
                      pageNum ?? controller.state.currentPageNumber.value,
                    )
                    .value
                ? SvgPath.svgBookmarked
                : Get.context!.bookmarkPageIconPath(),

            height: height,
          ),
        );
      },
    );
  }
}

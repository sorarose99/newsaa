part of '../../../quran.dart';

extension QuranGetters on QuranController {
  /// -------- [Getter] ----------
  ThemeController get themeCtrl => ThemeController.instance;

  List<List<AyahModel>> getCurrentPageAyahsSeparatedForBasmalah(
    int pageIndex,
  ) => QuranLibrary.quranCtrl.state.pages[pageIndex.clamp(0, 603)]
      .splitBetween((f, s) => f.ayahNumber > s.ayahNumber)
      .toList();

  List<AyahModel> getPageAyahsByIndex(int pageIndex) =>
      state.pages.isEmpty || QuranLibrary.quranCtrl.state.pages.isEmpty
      ? []
      : QuranLibrary.quranCtrl.state.pages[pageIndex.clamp(0, 603)];

  /// will return the surah number of the first ayahs..
  /// even if the page contains another surah..
  /// if you wanna get the last's ayah's surah information
  /// you can use [ayahs.last].
  int getSurahNumberFromPage(int pageNumber) =>
      QuranLibrary.quranCtrl.state.surahs
          .firstWhereOrNull(
            (s) =>
                s.ayahs.firstWhereOrNull(
                  (a) => a.page == pageNumber.clamp(1, 604),
                ) !=
                null,
          )
          ?.surahNumber ??
      1;

  SurahModel getCurrentSurahByPage(int pageNumber) {
    if (state.pages.isEmpty ||
        state.surahs.isEmpty ||
        QuranLibrary.quranCtrl.state.pages.isEmpty) {
      return SurahModel(
        surahNumber: 1,
        arabicName: '',
        englishName: '',
        ayahs: [],
        isDownloadedFonts: false,
      );
    }
    return QuranLibrary().getCurrentSurahDataByPageNumber(
      pageNumber: pageNumber.clamp(1, 604),
    );
  }

  SurahModel getSurahDataByAyah(AyahModel ayah) =>
      QuranLibrary().getCurrentSurahDataByAyah(ayah: ayah);

  SurahModel getSurahDataByAyahUQ(int ayah) => QuranLibrary()
      .getCurrentSurahDataByAyahUniqueNumber(ayahUniqueNumber: ayah);

  AyahModel getJuzByPage(int page) {
    if (state.pages.isEmpty ||
        state.allAyahs.isEmpty ||
        QuranLibrary.quranCtrl.state.pages.isEmpty) {
      return AyahModel(
        ayahNumber: 1,
        ayahUQNumber: 1,
        text: '',
        ayaTextEmlaey: '',
        juz: 1,
        page: 1,
        surahNumber: 1,
        hizb: 1,
        isDownloadedFonts: false,
      );
    }
    return QuranLibrary().getJuzByPageNumber(pageNumber: page.clamp(1, 604));
  }

  List<AyahModel> get currentPageAyahs =>
      state.pages[(state.currentPageNumber.value - 1).clamp(0, 603)];

  RxBool getCurrentJuzNumber(int juzNum) =>
      getJuzByPage(state.currentPageNumber.value).juz - 1 == juzNum
      ? true.obs
      : false.obs;

  PageController get pageController {
    return state.quranPageController = PageController(
      viewportFraction:
          (Responsive.isDesktop(Get.context!) && Get.context!.isLandscape)
          ? 1 / 2
          : 1,
      initialPage: (state.box.read(MSTART_PAGE) ?? 1) - 1,
      keepPage: true,
    );
  }

  ScrollController get surahController {
    final suraNumber =
        getCurrentSurahByPage(state.currentPageNumber.value).surahNumber - 1;
    if (state.surahController == null) {
      state.surahController = ScrollController(
        initialScrollOffset: state.surahItemHeight * suraNumber,
      );
    }
    return state.surahController!;
  }

  ScrollController get juzController {
    if (state.juzListController == null) {
      state.juzListController = ScrollController(
        initialScrollOffset:
            state.surahItemHeight *
            getJuzByPage(state.currentPageNumber.value).juz,
      );
    }
    return state.juzListController!;
  }

  Color get backgroundColor {
    // 1. Check for Dark Mode (System or App-specific)
    if (themeCtrl.isDarkMode ||
        (Get.context != null &&
            Theme.of(Get.context!).brightness == Brightness.dark)) {
      return const Color(0xff121212); // Standard Dark Background
    }

    // 2. Check for Custom Picker Color
    final pickerColor = state.backgroundPickerColor.value;
    if (pickerColor != 0 && pickerColor != 0x00000000) {
      return Color(pickerColor);
    }

    // 3. Default Light Background
    return const Color(0xfffaf7f3);
  }

  Color get adaptiveTextColor {
    // First priority: Check Quran-specific theme controller
    if (themeCtrl.isDarkMode) {
      return Colors.white; // Always white text in dark theme
    }

    // Second priority: Check Flutter theme brightness for main app dark mode
    if (Get.context != null) {
      final isDarkTheme = Theme.of(Get.context!).brightness == Brightness.dark;
      if (isDarkTheme) {
        return Colors.white; // Always white text in dark theme
      }
    }

    // For light themes, check custom background color
    final bgColor = backgroundColor;

    // For the default light beige background, explicitly use black text
    if (bgColor == const Color(0xfffaf7f3)) {
      return Colors.black;
    }

    // For dark backgrounds (common dark theme colors), explicitly use white text
    if (bgColor == const Color(0xff121212) || // Dark theme background
        bgColor == const Color(0xff1E1E1E) || // Dark surface
        bgColor == const Color(0xff000000)) {
      // Pure black
      return Colors.white;
    }

    // Calculate the luminance of the background color
    // Luminance ranges from 0.0 (black) to 1.0 (white)
    final luminance = bgColor.computeLuminance();

    // If background is dark (luminance < 0.5), use white text
    // If background is light (luminance >= 0.5), use black text
    if (luminance < 0.5) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  Color get adaptiveTextColor80 => adaptiveTextColor.withValues(alpha: 0.8);

  String get surahBannerPath {
    if (themeCtrl.isBlueMode) {
      return SvgPath.svgSurahBanner1;
    } else if (themeCtrl.isBrownMode) {
      return SvgPath.svgSurahBanner2;
    } else if (themeCtrl.isOldMode) {
      return SvgPath.svgSurahBanner4;
    } else if (themeCtrl.isGreenMode) {
      return SvgPath.svgSurahBanner3;
    } else {
      return SvgPath.svgSurahBanner3;
    }
  }

  String get surahBannerAyahPath {
    if (themeCtrl.isBlueMode) {
      return SvgPath.svgSurahBannerAyah1;
    } else if (themeCtrl.isBrownMode) {
      return SvgPath.svgSurahBannerAyah2;
    } else {
      return SvgPath.svgSurahBannerAyah1;
    }
  }
}

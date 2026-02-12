part of '../../quran.dart';

TextSpan span({
  required String text,
  required String fontFamily,
  required int pageIndex,
  required bool isSelected,
  double? fontSize,
  required int surahNum,
  required int ayahNum,
  LongPressStartDetailsFunction? onLongPressStart,
  required bool isFirstAyah,
  double? letterSpacing,
}) {
  if (text.isNotEmpty) {
    final String partOne = text.length < 3 ? text[0] : text[0] + text[1];
    final String? partTwo = text.length > 2
        ? text.substring(2, text.length - 1)
        : null;
    final String initialPart = text.substring(0, text.length - 1);
    final String lastCharacter = text.substring(text.length - 1);
    TextSpan? first;
    TextSpan? second;
    if (isFirstAyah) {
      first = TextSpan(
        text: partOne,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          height: 2,
          letterSpacing:
              letterSpacing ??
              (QuranLibrary().currentFontsSelected == 0 ? 0 : 10),
          color: quranCtrl.adaptiveTextColor,
          backgroundColor: quranCtrl.state.isPages.value == 0
              ? Colors.transparent
              : sl<BookmarksController>().hasBookmark(surahNum, ayahNum).value
              ? Get.theme.colorScheme.inverseSurface.withValues(alpha: .4)
              : isSelected
              ? Get.theme.highlightColor
              : Colors.transparent,
        ),
        recognizer: LongPressGestureRecognizer(
          duration: const Duration(milliseconds: 500),
        )..onLongPressStart = onLongPressStart,
      );
      second = TextSpan(
        text: partTwo,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          height: 2,
          letterSpacing:
              letterSpacing ??
              (QuranLibrary().currentFontsSelected == 0 ? 0 : 5),
          color: quranCtrl.adaptiveTextColor,
          backgroundColor: quranCtrl.state.isPages.value == 0
              ? Colors.transparent
              : sl<BookmarksController>().hasBookmark(surahNum, ayahNum).value
              ? Get.theme.colorScheme.inverseSurface.withValues(alpha: .4)
              : isSelected
              ? Get.theme.highlightColor
              : Colors.transparent,
        ),
        recognizer: LongPressGestureRecognizer(
          duration: const Duration(milliseconds: 500),
        )..onLongPressStart = onLongPressStart,
      );
    }

    final TextSpan initialTextSpan = TextSpan(
      text: initialPart,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        height: 2,
        letterSpacing:
            letterSpacing ?? (QuranLibrary().currentFontsSelected == 0 ? 0 : 5),
        color: quranCtrl.adaptiveTextColor,
        backgroundColor: quranCtrl.state.isPages.value == 0
            ? Colors.transparent
            : sl<BookmarksController>().hasBookmark(surahNum, ayahNum).value
            ? Get.theme.colorScheme.inverseSurface.withValues(alpha: .4)
            : isSelected
            ? Get.theme.highlightColor
            : Colors.transparent,
      ),
      recognizer: LongPressGestureRecognizer(
        duration: const Duration(milliseconds: 500),
      )..onLongPressStart = onLongPressStart,
    );

    var lastCharacterSpan =
        sl<BookmarksController>().hasBookmark(surahNum, ayahNum).value
        ? WidgetSpan(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: quranCtrl.state.isPages.value == 0 ? 6 : 30.0,
              ),
              child: SvgPicture.asset(
                SvgPath.svgAyahBookmarked,
                height: quranCtrl.state.isPages.value == 0 ? 25 : 100,
                colorFilter: ColorFilter.mode(
                  Get.theme.colorScheme.surface,
                  BlendMode.srcIn,
                ),
              ),
            ),
          )
        : TextSpan(
            text: lastCharacter,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: fontSize,
              height: 2,
              letterSpacing:
                  letterSpacing ??
                  (QuranLibrary().currentFontsSelected == 0 ? 0 : 5),
              color: quranCtrl.adaptiveTextColor,
              backgroundColor: quranCtrl.state.isPages.value == 0
                  ? Colors.transparent
                  : sl<BookmarksController>()
                        .hasBookmark(surahNum, ayahNum)
                        .value
                  ? Get.theme.colorScheme.inverseSurface.withValues(alpha: .4)
                  : isSelected
                  ? Get.theme.highlightColor
                  : Colors.transparent,
            ),
            recognizer: LongPressGestureRecognizer(
              duration: const Duration(milliseconds: 500),
            )..onLongPressStart = onLongPressStart,
          );

    return TextSpan(
      children: isFirstAyah
          ? [first!, second!, lastCharacterSpan]
          : [initialTextSpan, lastCharacterSpan],
      recognizer: LongPressGestureRecognizer(
        duration: const Duration(milliseconds: 500),
      )..onLongPressStart = onLongPressStart,
    );
  } else {
    return const TextSpan(text: '');
  }
}

typedef LongPressStartDetailsFunction = void Function(LongPressStartDetails)?;

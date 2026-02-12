part of '../../quran.dart';

class PageHeader extends StatelessWidget {
  final int pageIndex;
  final double? headerHeight;
  const PageHeader({super.key, required this.pageIndex, this.headerHeight});

  @override
  Widget build(BuildContext context) {
    final quranCtrl = QuranController.instance;
    final juz = quranCtrl.getJuzByPage(pageIndex + 1).juz;
    final surahNum = quranCtrl.getSurahNumberFromPage(pageIndex + 1);
    final surahNumString = surahNum.toString().padLeft(3, '0');

    final effectiveHeight = headerHeight ?? 50.h;
    final scaleFactor = (effectiveHeight / 50.h).clamp(0.8, 1.5);

    return Container(
      width: double.infinity,
      height: effectiveHeight,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: .5),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center Icon
          SvgPicture.asset(
            SvgPath
                .svgSoraNum, // Using a decorative icon like the frame for numbers
            height: 20.h,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),

          // Content
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Juz Name
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Decorative side bar akin to image if possible, or just text for now
                  Text(
                    '${'juz'.tr}: ${juz.toString().convertNumbers()}',
                    style: TextStyle(
                      fontSize: 30.h,
                      fontFamily: 'uthmanic2',
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Right: Surah Name SVG
              SvgPicture.asset(
                'assets/svg/surah_name/$surahNumString.svg',
                height: 30.h,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

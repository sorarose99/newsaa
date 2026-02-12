part of '../quran.dart';

class QuranSurahList extends StatelessWidget {
  QuranSurahList({super.key});
  final quranCtrl = QuranController.instance;

  @override
  Widget build(BuildContext context) {
    return CupertinoScrollbar(
      controller: quranCtrl.surahController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Match mushaf page proportional spacing
          double horizontalPadding = constraints.maxWidth * 0.115;
          double verticalPadding = constraints.maxHeight * 0.045;

          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ).add(const EdgeInsets.all(4.0)),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: quranCtrl.state.surahs.length,
              controller: quranCtrl.surahController,
              itemBuilder: (_, index) {
                final surah = quranCtrl.state.surahs[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        '${'juz'.tr} ${surah.ayahs.first.juz.toString()}',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontFamily: "kufi",
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 2,
                        ),
                      ),
                    ),
                    // Added spacing between Juz and Surah
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () => quranCtrl.changeSurahListOnTap(
                            surah.ayahs.first.page,
                          ),
                          child: GetBuilder<QuranController>(
                            builder: (quranCtrl) {
                              return Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: (index % 2 == 0
                                      ? Theme.of(context).colorScheme.primary
                                            .withValues(alpha: .15)
                                      : Colors.transparent),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  border: Border.all(
                                    width: 2,
                                    color:
                                        quranCtrl
                                                    .state
                                                    .lastReadSurahNumber
                                                    .value -
                                                1 ==
                                            index
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SizedBox(
                                                height: 40,
                                                width: 40,
                                                child: RepaintBoundary(
                                                  child: SvgPicture.asset(
                                                    SvgPath.svgSoraNum,
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                          Theme.of(
                                                            context,
                                                          ).colorScheme.surface,
                                                          BlendMode.srcIn,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10.0,
                                                      ),
                                                  child: Transform.translate(
                                                    offset: const Offset(0, 1),
                                                    child: Text(
                                                      '${surah.surahNumber}'
                                                          .convertNumbers(),
                                                      style: TextStyle(
                                                        color: Theme.of(
                                                          context,
                                                        ).hintColor,
                                                        fontFamily: "kufi",
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        height: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 8,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            RepaintBoundary(
                                              child: SvgPicture.asset(
                                                'assets/svg/surah_name/00${index + 1}.svg',
                                                colorFilter: ColorFilter.mode(
                                                  Theme.of(context).hintColor,
                                                  BlendMode.srcIn,
                                                ),
                                                width: 90,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8.0,
                                              ),
                                              child: Text(
                                                surah.englishName,
                                                style: TextStyle(
                                                  fontFamily: "naskh",
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.surface,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              context.vDivider(height: 30.0),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'aya_count'.tr,
                                                    style: TextStyle(
                                                      fontFamily: "naskh",
                                                      fontSize: 13,
                                                      color: Get
                                                          .theme
                                                          .colorScheme
                                                          .surface,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${surah.ayahs.last.ayahNumber}'
                                                        .convertNumbers(),
                                                    style: TextStyle(
                                                      fontFamily: "kufi",
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Get.theme.hintColor
                                                          .withValues(
                                                            alpha: .7,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        context.hDivider(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: .2),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

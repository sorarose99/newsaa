part of '../quran.dart';

class QuranPages extends StatelessWidget {
  QuranPages({Key? key}) : super(key: key);
  final audioCtrl = AudioController.instance;
  final quranCtrl = QuranController.instance;
  final bookmarkCtrl = BookmarksController.instance;

  @override
  Widget build(BuildContext context) {
    NotificationManager().updateBookProgress(
      'quran'.tr,
      'notifyQuranBody'.trParams({
        'currentPageNumber': '${quranCtrl.state.currentPageNumber.value}',
      }),
      quranCtrl.state.currentPageNumber.value,
    );
    return GestureDetector(
      onTap: () => audioCtrl.clearSelection(),
      child: Stack(
        children: [
          Container(
            child: Focus(
              focusNode: quranCtrl.state.quranPageRLFocusNode,
              onKeyEvent: (node, event) =>
                  quranCtrl.controlRLByKeyboard(node, event),
              child: PageView.builder(
                controller: quranCtrl.pageController,
                itemCount: 604,
                padEnds: false,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                onPageChanged: quranCtrl.pageChanged,
                itemBuilder: (_, index) {
                  // sl<TranslateDataController>().fetchTranslate();
                  return !quranCtrl.state.isPageMode.value
                      ? _regularModeWidget(context, index)
                      : _pageModeWidget(context, index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageModeWidget(BuildContext context, int pageIndex) {
    return Stack(
      children: [
        Center(
          child: pageIndex.isEven
              ? RightPage(
                  child: Focus(
                    focusNode: quranCtrl.state.quranPageUDFocusNode,
                    onKeyEvent: (node, event) =>
                        quranCtrl.controlUDByKeyboard(node, event),
                    child: TextBuild(pageIndex: pageIndex),
                  ),
                )
              : LeftPage(
                  child: Focus(
                    focusNode: quranCtrl.state.quranPageUDFocusNode,
                    onKeyEvent: (node, event) =>
                        quranCtrl.controlUDByKeyboard(node, event),
                    child: TextBuild(pageIndex: pageIndex),
                  ),
                ),
        ),
        if (quranCtrl.getCurrentSurahByPage(pageIndex).startPage ==
            pageIndex + 1)
          Positioned(
            top: 4.h,
            left: 4.w,
            right: 4.w,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                color: quranCtrl.backgroundColor,
                child: const SizedBox().surahAyahBannerWidget(
                  quranCtrl.getCurrentSurahByPage(pageIndex).surahNumber,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _regularModeWidget(BuildContext context, int pageIndex) {
    return Container(
      color: quranCtrl.backgroundColor,
      child: AyahsBuild(pageIndex: pageIndex),
    );
  }
}

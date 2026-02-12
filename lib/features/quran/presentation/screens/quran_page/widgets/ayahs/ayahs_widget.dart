part of '../../quran.dart';

class AyahsWidget extends StatelessWidget {
  AyahsWidget({super.key});

  final quranCtrl = QuranController.instance;
  final audioCtrl = AudioController.instance;
  final generalCtrl = GeneralController.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: quranCtrl.backgroundColor,
      child: Column(
        children: [
          Flexible(
            child: GestureDetector(
              onTap: () => audioCtrl.clearSelection(),
              child: QuranLibrary.quranCtrl.state.pages.isEmpty
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : FutureBuilder<void>(
                      future: Future.delayed(Duration.zero),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return ScrollablePositionedList.builder(
                            initialScrollIndex: math.max(
                              0,
                              quranCtrl.state.currentPageNumber.value - 1,
                            ),
                            itemScrollController:
                                quranCtrl.state.itemScrollController,
                            itemPositionsListener:
                                quranCtrl.state.itemPositionsListener,
                            scrollOffsetController:
                                quranCtrl.state.scrollOffsetController,
                            itemCount: quranCtrl.state.pages.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, pageIndex) {
                              // ملاحظة: استدعاء جلب الترجمة داخل itemBuilder مكلف.
                              // يفضل تحريكه إلى نقطة تحميل مناسبة لاحقًا.
                              QuranLibrary().fetchTranslation();
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  border: Border.all(
                                    width: 1,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withValues(alpha: .2),
                                  ),
                                ),
                                child: AyahsBuild(pageIndex: pageIndex),
                              );
                            },
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

part of '../quran.dart';

class SurahJuzList extends StatelessWidget {
  SurahJuzList({super.key});

  final controller = ScrollController();
  final generalCtrl = GeneralController.instance;
  final quranCtrl = QuranController.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Column(
        children: [
          TabBarWidget(
            isCenterChild: true,
            isQuranSetting: true,
            isNotification: false,
            juzName:
                '${'juz'.tr}: ${quranCtrl.getJuzByPage(quranCtrl.state.currentPageNumber.value).juz.toString().convertNumbers()}',
            surahName: quranCtrl
                .getCurrentSurahByPage(quranCtrl.state.currentPageNumber.value)
                      .arabicName,
            centerChild: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: OpenContainerWrapper(
                transitionType:
                    QuranSearchController.instance.state.transitionType,
                closedBuilder: (BuildContext _, VoidCallback openContainer) {
                  return SearchBarWidget(openContainer: openContainer);
                },
              ),
            ),
          ),
          const Gap(16),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    height: 40,
                    padding: const EdgeInsets.all(4.0),
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: TabBar(
                      unselectedLabelColor: Colors.white.withValues(alpha: .7),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Theme.of(context).colorScheme.primary,
                      labelStyle: const TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      indicator: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      tabs: [
                        Tab(text: 'quran_sorah'.tr),
                        Tab(text: 'allJuz'.tr),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: <Widget>[QuranSurahList(), QuranJuz()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

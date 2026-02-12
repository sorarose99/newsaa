part of '../quran.dart';

class QuranHome extends StatelessWidget {
  QuranHome({Key? key}) : super(key: key);

  final audioCtrl = AudioController.instance;
  final generalCtrl = GeneralController.instance;
  final bookmarkCtrl = BookmarksController.instance;
  final quranCtrl = QuranController.instance;

  // bool hasUnopenedNotifications() {
  //   return sl<NotificationsController>()
  //       .sentNotifications
  //       .any((notification) => !notification['opened']);
  // }

  @override
  Widget build(BuildContext context) {
    GlobalKeyManager().resetDrawerKey();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (didPop) {
          return;
        }
        audioCtrl.state.audioPlayer.stop();
        audioCtrl.state.isPlay.value = false;
        quranCtrl.state.selectedAyahIndexes.clear();
        Get.back();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: quranCtrl.backgroundColor,
        body: SafeArea(
          child: SliderDrawer(
            key: GlobalKeyManager().drawerKey,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            slideDirection: alignmentLayout(
              SlideDirection.rightToLeft,
              SlideDirection.leftToRight,
            ),
            sliderOpenSize: 300.0,
            isDraggable: true,
            appBar: const SizedBox.shrink(),
            slider: SurahJuzList(),
            child: Container(
              decoration: BoxDecoration(color: quranCtrl.backgroundColor),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Center(child: ScreenSwitch()),
                  ),
                  Obx(
                    () => Align(
                      alignment: Alignment.topCenter,
                      child: TabBarWidget(
                        isCenterChild: generalCtrl.state.isShowControl.value,
                        isQuranSetting: true,
                        isNotification: false,
                        juzName: quranCtrl.state.pages.isEmpty
                            ? ''
                            : '${'juz'.tr}: ${quranCtrl.getJuzByPage(quranCtrl.state.currentPageNumber.value).juz.toString().convertNumbers()}',
                        surahName: quranCtrl.state.pages.isEmpty
                            ? ''
                            : quranCtrl
                                  .getCurrentSurahByPage(
                                    quranCtrl.state.currentPageNumber.value,
                                  )
                                  .arabicName,
                        centerChild: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: OpenContainerWrapper(
                            transitionType: QuranSearchController
                                .instance
                                .state
                                .transitionType,
                            closedBuilder:
                                (BuildContext _, VoidCallback openContainer) {
                                  return SearchBarWidget(
                                    openContainer: openContainer,
                                  );
                                },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () =>
                        audioCtrl.state.isStartPlaying.value ||
                            generalCtrl.state.isShowControl.value
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: AudioWidget(),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Obx(
                    () => generalCtrl.state.isShowControl.value
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: NavBarWidget(),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

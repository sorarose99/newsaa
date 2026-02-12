part of '../../../quran.dart';

// AudioState state = AudioState();
final generalCtrl = GeneralController.instance;
final quranCtrl = QuranController.instance;

extension AudioGetters on AudioController {
  /// -------- [Getters] ----------

  MediaItem get mediaItemForCurrentAyah => MediaItem(
    id: '${state.currentAyahUQInPage.value}',
    title:
        '${quranCtrl.getPageAyahsByIndex((quranCtrl.state.currentPageNumber.value - 1).clamp(0, 603)).firstWhereOrNull((a) => a.ayahUQNumber == state.currentAyahUQInPage.value)?.text ?? ''}',
    artist: '${ayahReaderInfo[state.readerIndex.value]['name']}'.tr,
    artUri: state.cachedArtUri,
  );

  List<MediaItem> get mediaItemsForCurrentSurah {
    final ayahsOfCrntSurah =
        quranCtrl.state.surahs[(currentSurahNumInPage - 1).clamp(0, 113)].ayahs;
    return List.generate(
      ayahsOfCrntSurah.length,
      (i) => MediaItem(
        id: '${ayahsOfCrntSurah[i].ayahUQNumber}',
        title: '${ayahsOfCrntSurah[i].text}',
        artist: '${ayahReaderInfo[state.readerIndex.value]['name']}'.tr,
        artUri: state.cachedArtUri,
      ),
    );
  }

  int get currentAyahInPage => state.selectedAyahNum.value == 1
      ? (quranCtrl.state.allAyahs
                    .firstWhereOrNull(
                      (ayah) =>
                          ayah.page == quranCtrl.state.currentPageNumber.value,
                    )
                    ?.ayahNumber ??
                1) -
            1
      : state.selectedAyahNum.value;

  int get currentSurahNumInPage =>
      (state.currentSurahNumInPage.value == 1
              ? quranCtrl.getSurahNumberFromPage(
                  quranCtrl.state.currentPageNumber.value,
                )
              : state.currentSurahNumInPage.value)
          .clamp(1, 114);

  Stream<PositionData> get positionDataStream =>
      R.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        state.audioPlayer.positionStream,
        state.audioPlayer.bufferedPositionStream,
        state.audioPlayer.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  bool get isLastAyahInPage =>
      quranCtrl
          .getPageAyahsByIndex(quranCtrl.state.currentPageNumber.value - 1)
          .last
          .ayahUQNumber ==
      state.currentAyahUQInPage.value;

  bool get isFirstAyahInPage =>
      quranCtrl
          .getPageAyahsByIndex(quranCtrl.state.currentPageNumber.value - 1)
          .first
          .ayahUQNumber ==
      state.currentAyahUQInPage.value;

  bool get isLastAyahInSurah =>
      quranCtrl
          .getCurrentSurahByPage(quranCtrl.state.currentPageNumber.value)
          .ayahs
          .last
          .ayahUQNumber ==
      state.currentAyahUQInPage.value;

  bool get isFirstAyahInSurah =>
      quranCtrl
          .getCurrentSurahByPage(quranCtrl.state.currentPageNumber.value)
          .ayahs
          .first
          .ayahUQNumber ==
      state.currentAyahUQInPage.value;

  bool get isLastAyahInSurahButNotInPage =>
      isLastAyahInSurah && !isLastAyahInPage;

  bool get isLastAyahInSurahAndPage => isLastAyahInSurah && isLastAyahInPage;

  bool get isLastAyahInPageButNotInSurah =>
      isLastAyahInPage && !isLastAyahInSurah;

  bool get isFirstAyahInPageButNotInSurah =>
      isFirstAyahInPage && !isFirstAyahInSurah;

  String get reader => state.readerValue!;

  String get currentAyahFileName {
    if (ayahReaderInfo[state.readerIndex.value]['url'] ==
        ApiConstants.ayahs1stSource) {
      return '$reader/${state.currentAyahUQInPage.value}.mp3';
    } else {
      final surahNum = quranCtrl
          .getSurahDataByAyah(
            quranCtrl.state.allAyahs[(state.currentAyahUQInPage.value - 1)
                .clamp(0, 6235)],
          )
          .surahNumber
          .toString()
          .padLeft(3, '0');
      final currentAyahNumber = quranCtrl
          .state
          .allAyahs[(state.currentAyahUQInPage.value - 1).clamp(0, 6235)]
          .ayahNumber
          .toString()
          .padLeft(3, '0');
      return '$reader/$surahNum$currentAyahNumber.mp3';
    }
  }

  List<int> get selectedSurahAyahsUniqueNumbers => quranCtrl
      .state
      .surahs[currentSurahNumInPage - 1]
      .ayahs
      .map((ayah) => ayah.ayahUQNumber)
      .toList();

  List<String> get selectedSurahAyahsFileNames {
    final selectedSurah =
        quranCtrl.state.surahs[(currentSurahNumInPage - 1).clamp(0, 113)];
    log(
      'selectedSurah: ${selectedSurah.arabicName}',
      name: 'AudioController_selectedSurahAyahsFileNames',
    );
    return List.generate(
      selectedSurah.ayahs.length,
      (i) =>
          ayahReaderInfo[state.readerIndex.value]['url'] ==
              ApiConstants.ayahs1stSource
          ? '$reader/${selectedSurah.ayahs[i].ayahUQNumber}.mp3'
          : '$reader/${selectedSurah.surahNumber.toString().padLeft(3, "0")}${selectedSurah.ayahs[i].ayahNumber.toString().padLeft(3, "0")}.mp3',
    );
  }

  // +1
  List<String> get selectedSurahAyahsUrls {
    return List.generate(
      selectedSurahAyahsFileNames.length,
      (i) => '$ayahDownloadSource${selectedSurahAyahsFileNames[i]}',
    );
  }

  String get ayahDownloadSource {
    final index = state.readerIndex.value;
    if (index < 0 || index >= ayahReaderInfo.length) {
      return ApiConstants.ayahs1stSource;
    }
    return ayahReaderInfo[index]['url'] == ApiConstants.ayahs1stSource
        ? ApiConstants.ayahs1stSource
        : ApiConstants.ayahs2ndSource;
  }

  String get currentAyahUrl => '$ayahDownloadSource$currentAyahFileName';

  void get pausePlayer async {
    state.isPlay.value = false;
    await state.audioPlayer.pause();
  }
}

part of '../../quran.dart';

class AudioController extends GetxController with WidgetsBindingObserver {
  static AudioController get instance =>
      GetInstance().putOrFind(() => AudioController());

  AudioState state = AudioState();
  bool _isPlayingFile = false;

  final generalCtrl = GeneralController.instance;
  final quranCtrl = QuranController.instance;

  @override
  void onInit() async {
    state.isPlay.value = false;
    state.sliderValue = 0;
    try {
      loadQuranReader();
      if (!kIsWeb) {
        await Future.wait([
          GeneralController.instance.getCachedArtUri().then(
            (v) => state.cachedArtUri = v,
          ),
          getApplicationDocumentsDirectory().then((v) => state.dir = v),
        ]);
      } else {
        state.dir = Directory('');
        state.cachedArtUri = Uri.parse(
          StringConstants.appsIcon1024.isEmpty
              ? 'about:blank'
              : StringConstants.appsIcon1024,
        );
      }
      ConnectivityService.instance.init();
      _initPlayerListeners();
    } catch (e) {
      log(
        'Error during AudioController initialization: $e',
        name: 'AudioController',
      );
    } finally {
      if (!state.initCompleter.isCompleted) {
        state.initCompleter.complete();
      }
    }
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  void _initPlayerListeners() {
    state.playerIndexSubscription?.cancel();
    state.playerIndexSubscription = state.audioPlayer.currentIndexStream.listen(
      (index) async {
        if (index != null &&
            index != 0 &&
            index != state.selectedAyahNum.value) {
          log('state.currentAyahUQInPage.value: ${state.currentAyahUQInPage}');
          state.selectedAyahNum.value = index;
          state.currentAyahUQInPage.value =
              selectedSurahAyahsUniqueNumbers[state.selectedAyahNum.value];
          QuranLibrary.quranCtrl.clearSelection();
          QuranLibrary.quranCtrl.toggleAyahSelection(
            state.currentAyahUQInPage.value,
          );
        }
      },
    );

    state.playerPositionSubscription?.cancel();
    state.playerPositionSubscription = state.audioPlayer.positionStream.listen((
      position,
    ) async {
      final duration = state.audioPlayer.duration;
      final currentIndex = state.audioPlayer.currentIndex;

      if (duration != null && position.inMilliseconds > 0) {
        final remainingTime = duration.inMilliseconds - position.inMilliseconds;

        if (remainingTime <= 200 && remainingTime > 0) {
          if ((isLastAyahInPageButNotInSurah || isLastAyahInSurahAndPage) &&
              !state.playSingleAyahOnly &&
              currentIndex != null) {
            await Future.delayed(Duration(milliseconds: remainingTime + 50));
            await moveToNextPage(withScroll: true);
          }
        }
      }
    });

    // Sync isPlay with actual player state
    state.audioPlayer.playingStream.listen((playing) {
      state.isPlay.value = playing;
    });
  }

  @override
  void onClose() {
    state.audioPlayer.pause();
    state.audioPlayer.dispose();
    state.playerIndexSubscription?.cancel();
    state.playerPositionSubscription?.cancel();
    ConnectivityService.instance.onClose();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// -------- [DownloadsMethods] ----------

  Future<String> _downloadFileIfNotExist(
    String url,
    String fileName, {
    bool showSnakbars = true,
    bool setDownloadingStatus = true,
  }) async {
    if (kIsWeb) return '';
    await state
        .initCompleter
        .future; // Wait for initialization if not already done

    String path = join(state.dir.path, fileName);
    var file = File(path);
    bool exists = await file.exists();

    if (!exists) {
      if (setDownloadingStatus && state.downloading.isFalse) {
        state.downloading.value = true;
        state.onDownloading.value = true;
      }

      if (!kIsWeb) {
        try {
          await Directory(dirname(path)).create(recursive: true);
        } catch (e) {
          print('Error creating directory: $e');
        }
      }

      if (showSnakbars && !state.snackBarShownForBatch) {
        if (ConnectivityService.instance.noConnection.value) {
          Get.context!.showCustomErrorSnackBar('noInternet'.tr);
        } else if (ConnectivityService.instance.connectionStatus.contains(
          ConnectivityResult.mobile,
        )) {
          state.snackBarShownForBatch = true; // Set the flag to true
          Get.context!.customMobileNoteSnackBar('mobileDataAyat'.tr);
        }
      }

      // Proceed with the download
      if (!ConnectivityService.instance.connectionStatus.contains(
        ConnectivityResult.none,
      )) {
        try {
          await _downloadFile(path, url, fileName);
        } catch (e) {
          log('Error downloading file: $e');
        }
      }
    }

    if (setDownloadingStatus && state.downloading.isTrue) {
      state.downloading.value = false;
      state.onDownloading.value = false;
    }

    update(['audio_seekBar_id']);
    return path;
  }

  Future<bool> _downloadFile(String path, String url, String fileName) async {
    Dio dio = Dio();
    if (kIsWeb) return true;
    try {
      await Directory(dirname(path)).create(recursive: true);
      state.progressString.value = 'Indeterminate';
      state.progress.value = 0;
      var incrementalProgress = 0.0;
      const incrementalStep = 0.1;

      await dio.download(
        url,
        path,
        onReceiveProgress: (rec, total) {
          if (total <= 0) {
            // Update the progress value incrementally
            incrementalProgress += incrementalStep;
            if (incrementalProgress >= 1) {
              incrementalProgress = 0; // Reset if it reaches 1
            }
          } else {
            // Handle determinate progress as before
            double progressValue = (rec / total).toDouble().clamp(0.0, 1.0);
            state.progress.value = progressValue;
            update(['audio_seekBar_id']);
            // log('ayah downloading progress: $progressValue');
          }
        },
      );
      return true;
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        print('Download canceled');
      } else {
        print('Download error for $fileName: $e');
      }
      return false;
    } finally {
      state.progressString.value = 'Completed';
    }
  }

  void _startBackgroundDownload(
    List<String> urls,
    List<String> fileNames,
    String surahKey,
    String surahName,
  ) async {
    state.snackBarShownForBatch = false;
    state.downloading.value = true;
    state.onDownloading.value = true;

    try {
      for (int i = 0; i < fileNames.length; i++) {
        bool success =
            await _downloadFileIfNotExist(
              urls[i],
              fileNames[i],
              setDownloadingStatus: false,
            ) !=
            '';

        if (success) {
          state.tmpDownloadedAyahsCount.value++;
        }
      }
      state.box.write(surahKey, true);
      log('Background download for surah $surahName completed.');
    } catch (e) {
      log('Error in background download: $e', name: 'AudioController');
    } finally {
      state.downloading.value = false;
      state.onDownloading.value = false;
    }
  }

  void cancelDownload() {
    state.cancelToken.cancel('Request cancelled');
  }

  /// -------- [PlayingMethods] ----------

  Future<void> moveToNextPage({bool withScroll = true}) async {
    if (withScroll) {
      await quranCtrl.state.quranPageController.animateToPage(
        (quranCtrl.state.currentPageNumber.value).clamp(0, 603),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      log(
        'Going To Next Page at: ${quranCtrl.state.currentPageNumber.value + 1} ',
      );
    }
  }

  void moveToPreviousPage({bool withScroll = true}) {
    if (withScroll) {
      quranCtrl.state.quranPageController.animateToPage(
        (quranCtrl.state.currentPageNumber.value - 2).clamp(0, 603),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> playFile() async {
    if (_isPlayingFile) return;
    _isPlayingFile = true;
    try {
      await state.initCompleter.future; // Wait for initialization
      state.tmpDownloadedAyahsCount = 0.obs;
      final selectedSurah =
          quranCtrl.state.surahs[(currentSurahNumInPage - 1).clamp(0, 113)];
      final ayahsFilesNames = selectedSurahAyahsFileNames;
      final ayahsUrls = selectedSurahAyahsUrls;
      final surahKey =
          'surah_${selectedSurah.surahNumber}ـ${state.readerIndex.value}';

      bool isSurahDownloaded = state.box.read(surahKey) ?? false;

      // We no longer wait for the entire surah to download
      if (state.playSingleAyahOnly) {
        final path = await _downloadFileIfNotExist(
          currentAyahUrl,
          currentAyahFileName,
        );
        state.downloading.value = false;
        state.onDownloading.value = false;

        await state.audioPlayer.setAudioSource(
          kIsWeb
              ? AudioSource.uri(
                  Uri.parse(currentAyahUrl),
                  tag: mediaItemForCurrentAyah,
                )
              : AudioSource.file(path, tag: mediaItemForCurrentAyah),
        );
      } else {
        if (!isSurahDownloaded) {
          _startBackgroundDownload(
            ayahsUrls,
            ayahsFilesNames,
            surahKey,
            selectedSurah.arabicName,
          );
        }

        final List<AudioSource> audioSources = [];
        for (int i = 0; i < ayahsFilesNames.length; i++) {
          final fileName = ayahsFilesNames[i];
          final url = ayahsUrls[i];
          final path = join(state.dir.path, fileName);
          final file = File(path);

          if (!kIsWeb && await file.exists()) {
            audioSources.add(
              AudioSource.file(path, tag: mediaItemsForCurrentSurah[i]),
            );
          } else {
            audioSources.add(
              AudioSource.uri(
                Uri.parse(url),
                tag: mediaItemsForCurrentSurah[i],
              ),
            );
          }
        }

        await state.audioPlayer.setAudioSource(
          ConcatenatingAudioSource(children: audioSources),
          initialIndex: state.isDirectPlaying.value
              ? currentAyahInPage
              : state.selectedAyahNum.value,
        );
      }

      state.isPlay.value = true;
      await state.audioPlayer.play();

      log(
        '${'-' * 30} player started successfully ${'-' * 30}',
        name: 'AudioController',
      );
    } catch (e) {
      state.isPlay.value = false;
      state.audioPlayer.stop();
      log('Error in playFile: $e', name: 'AudioController');
    } finally {
      _isPlayingFile = false;
    }
  }

  Future<void> playAyah() async {
    if (quranCtrl.state.isPages.value == 0) {
      state.currentAyahUQInPage.value = state.currentAyahUQInPage.value == 1
          ? quranCtrl.state.allAyahs
                .firstWhere(
                  (ayah) =>
                      ayah.page ==
                      quranCtrl
                              .state
                              .itemPositionsListener
                              .itemPositions
                              .value
                              .last
                              .index +
                          1,
                )
                .ayahUQNumber
          : state.currentAyahUQInPage.value;
    } else {
      state.currentAyahUQInPage.value = state.currentAyahUQInPage.value == 1
          ? quranCtrl.state.allAyahs
                .firstWhere(
                  (ayah) =>
                      ayah.page == quranCtrl.state.currentPageNumber.value,
                )
                .ayahUQNumber
          : state.currentAyahUQInPage.value;
    }
    // quranCtrl.clearAndAddSelection(state.currentAyahUQInPage.value);

    // quranCtrl.clearAndAddSelection(state.currentAyahUQInPage.value);
    if (state.audioPlayer.playing || state.isPlay.value) {
      state.isPlay.value = false;
      await state.audioPlayer.pause();
      print('state.audioPlayer: pause');
    } else {
      if (_isPlayingFile) return;
      await playFile();
    }
  }

  Future<void> skipNextAyah() async {
    if (state.currentAyahUQInPage.value == 6236) {
      pausePlayer;
    } else if (isLastAyahInPageButNotInSurah || isLastAyahInSurahAndPage) {
      await moveToNextPage(withScroll: true);
      await state.audioPlayer.seekToNext();
      quranCtrl.clearAndAddSelection(state.currentAyahUQInPage.value += 1);
    } else {
      await state.audioPlayer.seekToNext();
      quranCtrl.clearAndAddSelection(state.currentAyahUQInPage.value += 1);
    }
  }

  Future<void> skipPreviousAyah() async {
    if (state.currentAyahUQInPage.value == 1) {
      pausePlayer;
    } else if (isFirstAyahInPageButNotInSurah) {
      moveToPreviousPage();
      await state.audioPlayer.seekToPrevious();
      quranCtrl.clearAndAddSelection(state.currentAyahUQInPage.value -= 1);
    } else {
      await state.audioPlayer.seekToPrevious();
      quranCtrl.clearAndAddSelection(state.currentAyahUQInPage.value -= 1);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState states) {
    if (states == AppLifecycleState.paused ||
        states == AppLifecycleState.detached ||
        states == AppLifecycleState.inactive) {
      if (state.audioPlayer.playing || state.isPlay.value) {
        state.audioPlayer.stop();
        state.isPlay.value = false;
      }
    }
  }
}

part of '../quran.dart';

class TranslateController extends GetxController {
  static TranslateController get instance =>
      GetInstance().putOrFind(() => TranslateController());

  RxDouble get fontSizeArabic => sl<GeneralController>().state.fontSizeArabic;

  dynamic getTranslationForAyahModel(dynamic ayah, int ayahUQNumber) {
    // This is a shim for the missing method. In a real scenario, this would
    // fetch the translation from the database or local storage.
    // Returning a dummy object that mirrors the expected interface.
    return null; // translate_build.dart handles null by returning a default message
  }

  // var data = [].obs;
  // var isLoading = false.obs;
  var trans = 'en'.obs;
  // RxInt transValue = 0.obs;
  RxInt shareTransValue = 0.obs;
  var expandedMap = <int, bool>{}.obs;
  RxList<TafsirTableData> tafsirList = QuranLibrary().tafsirList.obs;
  // RxBool isTafsir = QuranLibrary().isTafsir.obs;
  RxInt tafsirRadioValue = QuranLibrary().selectedTafsirIndex.obs;
  final box = GetStorage();

  TafsirTableData getAyahTranslation(int ayahUQNumber) {
    final tafsir = QuranLibrary().tafsirList.firstWhere(
      (element) => element.id == ayahUQNumber,
      orElse: () => const TafsirTableData(
        id: 0,
        tafsirText: '',
        ayahNum: 0,
        pageNum: 0,
        surahNum: 0,
      ),
    );
    return tafsir;
  }

  shareTranslateHandleRadioValue(int translateVal) async {
    shareTransValue.value = translateVal;
    switch (shareTransValue.value) {
      case 0:
        sl<ShareController>().isTafseer.value = false;
        trans.value = 'en';
        box.write(TRANS, 'en');
      case 1:
        sl<ShareController>().isTafseer.value = false;
        trans.value = 'es';
        box.write(TRANS, 'es');
      case 2:
        sl<ShareController>().isTafseer.value = false;
        trans.value = 'be';
        box.write(TRANS, 'be');
      case 3:
        sl<ShareController>().isTafseer.value = false;
        trans.value = 'urdu';
        box.write(TRANS, 'urdu');
      case 4:
        sl<ShareController>().isTafseer.value = false;
        trans.value = 'so';
        box.write(TRANS, 'so');
      case 5:
        sl<ShareController>().isTafseer.value = false;
        trans.value = 'in';
        box.write(TRANS, 'in');
      case 6:
        sl<ShareController>().isTafseer.value = false;
        trans.value = 'ku';
        box.write(TRANS, 'ku');
      case 7:
        sl<ShareController>().isTafseer.value = false;
        trans.value = 'tr';
        box.write(TRANS, 'tr');
      // case 8:
      //   sl<ShareController>().isTafseer.value = true;
      //   sl<AyatController>().dBName =
      //       sl<AyatController>().saadiClient?.database;
      //   sl<AyatController>().selectedDBName = MufaserName.saadi.name;
      //   box.write(IS_TAFSEER, true);
      default:
        trans.value = 'en';
    }
  }

  void loadTranslateValue() {
    // transValue.value = box.read(TRANSLATE_VALUE) ?? 0;
    shareTransValue.value = box.read(SHARE_TRANSLATE_VALUE) ?? 0;
    trans.value = box.read(TRANS) ?? 'en';
    ShareController.instance.currentTranslate.value =
        box.read(CURRENT_TRANSLATE) ?? 'English';
    sl<ShareController>().isTafseer.value = (box.read(IS_TAFSEER)) ?? false;
    print('trans.value ${trans.value}');
    // print('translateـvalue $transValue');
    ShareController.instance.update(['currentTranslate']);
  }

  @override
  void onInit() {
    // fetchTranslate();
    super.onInit();
  }
}

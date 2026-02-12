import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:alslat_aalnabi/features/quran/presentation/screens/quran_page/quran.dart';
import 'package:alslat_aalnabi/features/quran/presentation/controllers/general/general_state.dart';

class GeneralController extends GetxController {
  static GeneralController get instance =>
      GetInstance().putOrFind(() => GeneralController());

  GeneralState state = GeneralState();

  @override
  void onInit() async {
    Future.delayed(const Duration(seconds: 1)).then((_) async {
      try {
        await WakelockPlus.enable();
      } catch (e) {
        print('Failed to enable wakelock: $e');
      }
    });

    super.onInit();
  }

  /// -------- [Methods] ----------

  /// Greeting
  updateGreeting() {
    final now = DateTime.now();
    final isMorning = now.hour < 12;
    state.greeting.value = isMorning
        ? 'صبحكم الله بالخير'
        : 'مساكم الله بالخير';
  }

  scrollToAyah(int ayahNumber) {
    if (state.ayahListController.hasClients) {
      double position = (ayahNumber - 1) * state.ayahItemWidth;
      state.ayahListController.jumpTo(position);
    } else {
      print("Controller not attached to any scroll views.");
    }
  }

  Widget screenSelect() {
    return QuranHome();
  }
}

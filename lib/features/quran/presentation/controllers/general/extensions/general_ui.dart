import 'package:get/get.dart';

import 'package:alslat_aalnabi/features/quran/core/utils/helpers/responsive.dart';
import 'package:alslat_aalnabi/features/quran/presentation/controllers/general/general_controller.dart';

extension GeneralUi on GeneralController {
  /// -------- [GeneralUi] ----------

  void selectScreenToggleView() {
    state.showSelectScreenPage.value = !state.showSelectScreenPage.value;
  }

  double screenWidth(double smallWidth, double largeWidth) {
    final size = Get.width;
    if (size <= 600) {
      return smallWidth;
    }
    return largeWidth;
  }

  double customSize(
      double mobile, double largeMobile, double tablet, double desktop) {
    if (Responsive.isMobile(Get.context!)) {
      return mobile;
    } else if (Responsive.isMobileLarge(Get.context!)) {
      return largeMobile;
    } else if (Responsive.isTablet(Get.context!)) {
      return tablet;
    } else {
      return desktop;
    }
  }

  double ifBigScreenSize(double s, double l) {
    return Get.width >= 1025.0 ? s : l;
  }
}

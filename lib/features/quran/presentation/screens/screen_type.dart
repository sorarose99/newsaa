import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'package:alslat_aalnabi/features/quran/presentation/controllers/general/general_controller.dart';

class ScreenTypeL extends StatelessWidget {
  ScreenTypeL({super.key});
  final generalCtrl = GeneralController.instance;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb &&
        (Platform.isIOS || Platform.isAndroid || Platform.isFuchsia)) {
      // UiHelper.showRateDialog(context);
    }
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) {
        return generalCtrl.screenSelect();
      },
      desktop: (BuildContext context) {
        return generalCtrl.screenSelect();
      },
      breakpoints: const ScreenBreakpoints(
        desktop: 650,
        tablet: 450,
        watch: 300,
      ),
    );
  }
}

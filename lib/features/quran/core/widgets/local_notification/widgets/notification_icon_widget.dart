import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:alslat_aalnabi/features/quran/core/utils/constants/extensions/convert_number_extension.dart';
import 'package:alslat_aalnabi/features/quran/core/utils/constants/extensions/svg_extensions.dart';
import 'package:alslat_aalnabi/features/quran/core/utils/constants/svg_constants.dart';
import 'package:alslat_aalnabi/features/quran/core/widgets/local_notification/controller/local_notifications_controller.dart';

class NotificationIconWidget extends StatelessWidget {
  final bool isCurve;
  final double iconHeight;
  final double padding;
  const NotificationIconWidget({
    super.key,
    required this.isCurve,
    required this.iconHeight,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        isCurve
            ? customSvgWithColor(
                SvgPath.svgButtonCurve,
                height: 45.0,
                width: 45.0,
                color: Get.theme.colorScheme.primary,
              )
            : const SizedBox.shrink(),
        Container(
          padding: EdgeInsets.all(padding),
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          child: GetX<LocalNotificationsController>(
            builder: (notiCtrl) {
              return badges.Badge(
                showBadge: notiCtrl.unreadCount > 0,
                position: badges.BadgePosition.bottomEnd(bottom: -22, end: -20),
                badgeStyle: badges.BadgeStyle(
                  shape: badges.BadgeShape.square,
                  badgeColor: Theme.of(context).colorScheme.primaryContainer,
                  borderSide: BorderSide(
                    width: 1,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  borderRadius: BorderRadius.circular(4),
                  elevation: 0,
                ),
                badgeContent: Text(
                  notiCtrl.unreadCount.toString().convertNumbers(),
                  style: TextStyle(
                    fontFamily: 'naskh',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: customSvgWithCustomColor(
                  SvgPath.svgNotifications,
                  height: iconHeight,
                  color: Theme.of(context).colorScheme.surface,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

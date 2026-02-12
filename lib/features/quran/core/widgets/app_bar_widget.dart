import 'package:alslat_aalnabi/features/quran/core/utils/constants/extensions/alignment_rotated_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:alslat_aalnabi/features/quran/core/utils/constants/extensions/font_size_extension.dart';
import 'package:alslat_aalnabi/features/quran/core/utils/constants/extensions/extensions.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final bool isTitled;
  final bool isFontSize;
  final Widget searchButton;
  final String title;
  final Color? color;
  final bool isNotifi;
  final bool isBooks;
  final PreferredSizeWidget? bottom;

  const AppBarWidget({
    super.key,
    required this.isTitled,
    required this.title,
    required this.isFontSize,
    required this.searchButton,
    this.color,
    required this.isNotifi,
    required this.isBooks,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: color ?? Theme.of(context).colorScheme.primaryContainer,
      elevation: 0,
      title: isTitled
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 1,
                ),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Theme.of(context).hintColor,
                  fontSize: context.customOrientation(12.0, 16.0),
                  fontFamily: 'kufi',
                ),
              ),
            )
          : const SizedBox.shrink(),
      centerTitle: true,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Transform.flip(
            flipX: alignmentLayout(false, true),
            child: Image.asset(
              'assets/icons/arrow_back.png',
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
      ),
      actions: [
        isFontSize ? fontSizeDropDownWidget() : const SizedBox.shrink(),
        searchButton,
      ],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SurahHeaderBanner extends StatelessWidget {
  final String surahNumber;
  final double? width;
  final double? height;

  const SurahHeaderBanner({
    super.key,
    required this.surahNumber,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/svg/surah_header.svg',
      width: width ?? Get.width * .45,
      height: height ?? Get.height * .3,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(
        Theme.of(context).colorScheme.primary,
        BlendMode.srcIn,
      ),
    );
  }
}

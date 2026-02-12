import 'package:flutter/material.dart';

class MushafPageBorder extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const MushafPageBorder({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(4.0),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // The decorative border
        Image.asset('assets/svg/mushaf_border.png', fit: BoxFit.fill),
        // The content with padding to ensure it fits inside the border
        // The border visual thickness is roughly 13% of the width/height.
        // We use a LayoutBuilder to apply relative padding if needed,
        // or just a fixed padding if the aspect ratio is predictable.
        // For now, we'll try a safe padding + 12% relative padding.
        LayoutBuilder(
          builder: (context, constraints) {
            double horizontalPadding = constraints.maxWidth * 0.115;
            double verticalPadding = constraints.maxHeight * 0.045;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ).add(padding),
              child: child,
            );
          },
        ),
      ],
    );
  }
}

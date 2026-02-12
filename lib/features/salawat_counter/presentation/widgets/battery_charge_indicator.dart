import 'package:flutter/material.dart';

class BatteryChargeIndicator extends StatelessWidget {
  final int currentCount;
  final int lastAchievedGoal;
  final int nextGoal;
  final double width;
  final double height;
  final bool horizontal;

  const BatteryChargeIndicator({
    super.key,
    required this.currentCount,
    required this.lastAchievedGoal,
    required this.nextGoal,
    this.width = 120,
    this.height = 120,
    this.horizontal = false,
  });

  Color _getLevelColor(int levelIndex, bool isGoalReached) {
    if (isGoalReached) {
      return const Color(0xFF4CAF50);
    }

    if (levelIndex < 2) {
      return const Color(0xFFFFC107);
    } else if (levelIndex < 4) {
      return const Color(0xFFFF9800);
    } else {
      return const Color(0xFFFF9800);
    }
  }

  bool _isBatteryLevelFilled(int levelIndex) {
    if (currentCount == lastAchievedGoal && lastAchievedGoal > 0) {
      return true;
    }

    final rangeDifference = nextGoal - lastAchievedGoal;
    final levelValue =
        lastAchievedGoal + ((levelIndex + 1) * rangeDifference) ~/ 5;
    return currentCount >= levelValue;
  }

  @override
  Widget build(BuildContext context) {
    final isGoalReached =
        currentCount == lastAchievedGoal && lastAchievedGoal > 0;

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: BatteryPainter(
          levels: List.generate(5, (index) {
            return BatteryLevel(
              isFilled: _isBatteryLevelFilled(index),
              color: _getLevelColor(index, isGoalReached),
            );
          }),
          isGoalReached: isGoalReached,
          horizontal: horizontal,
        ),
      ),
    );
  }
}

class BatteryLevel {
  final bool isFilled;
  final Color color;

  BatteryLevel({required this.isFilled, required this.color});
}

class BatteryPainter extends CustomPainter {
  final List<BatteryLevel> levels;
  final bool isGoalReached;
  final bool horizontal;

  BatteryPainter({
    required this.levels,
    required this.isGoalReached,
    this.horizontal = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (horizontal) {
      _paintHorizontal(canvas, size);
    } else {
      _paintVertical(canvas, size);
    }
  }

  void _paintVertical(Canvas canvas, Size size) {
    const borderRadius = 4.0;
    const spacing = 3.0;
    const containerPadding = 8.0;
    const topCapHeight = 8.0;

    final containerWidth = size.width - (2 * containerPadding);
    final containerHeight = size.height - (2 * containerPadding) - topCapHeight;

    final containerRect = Rect.fromLTWH(
      containerPadding,
      containerPadding + topCapHeight,
      containerWidth,
      containerHeight,
    );

    final containerPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;

    final containerBorderPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        containerRect,
        const Radius.circular(borderRadius),
      ),
      containerPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        containerRect,
        const Radius.circular(borderRadius),
      ),
      containerBorderPaint,
    );

    final topCapRect = Rect.fromLTWH(
      size.width / 2 - 8,
      containerPadding,
      16,
      topCapHeight,
    );

    final topCapPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(topCapRect, const Radius.circular(2)),
      topCapPaint,
    );

    final levelHeight = (containerHeight - (spacing * 4)) / 5;
    final levelWidth = containerWidth - (2 * 2);

    for (int i = 0; i < levels.length; i++) {
      final level = levels[i];
      final reversedIndex = levels.length - 1 - i;
      final levelTop =
          containerRect.top + (reversedIndex * (levelHeight + spacing));

      final levelRect = Rect.fromLTWH(
        containerRect.left + 2,
        levelTop,
        levelWidth,
        levelHeight,
      );

      if (isGoalReached) {
        final achievedPaint = Paint()
          ..color = const Color(0xFF4CAF50)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(levelRect, const Radius.circular(2)),
          achievedPaint,
        );
      } else if (level.isFilled) {
        final levelPaint = Paint()
          ..color = level.color
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(levelRect, const Radius.circular(2)),
          levelPaint,
        );
      } else {
        final emptyPaint = Paint()
          ..color = Colors.grey[200]!
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(levelRect, const Radius.circular(2)),
          emptyPaint,
        );
      }
    }
  }

  void _paintHorizontal(Canvas canvas, Size size) {
    const borderRadius = 4.0;
    const spacing = 2.0;
    const containerPadding = 6.0;
    const rightCapWidth = 6.0;

    final containerHeight = size.height - (2 * containerPadding);
    final containerWidth = size.width - (2 * containerPadding) - rightCapWidth;

    final containerRect = Rect.fromLTWH(
      containerPadding,
      containerPadding,
      containerWidth,
      containerHeight,
    );

    final containerPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;

    final containerBorderPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        containerRect,
        const Radius.circular(borderRadius),
      ),
      containerPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        containerRect,
        const Radius.circular(borderRadius),
      ),
      containerBorderPaint,
    );

    final rightCapRect = Rect.fromLTWH(
      size.width - containerPadding - rightCapWidth,
      containerPadding + (containerHeight / 2) - 4,
      rightCapWidth,
      8,
    );

    final rightCapPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rightCapRect, const Radius.circular(1.5)),
      rightCapPaint,
    );

    final levelWidth = (containerWidth - (spacing * 4)) / 5;
    final levelHeight = containerHeight - (2 * 2);

    for (int i = 0; i < levels.length; i++) {
      final level = levels[i];
      final levelLeft = containerRect.left + (i * (levelWidth + spacing));

      final levelRect = Rect.fromLTWH(
        levelLeft,
        containerRect.top + 2,
        levelWidth,
        levelHeight,
      );

      if (isGoalReached) {
        final achievedPaint = Paint()
          ..color = const Color(0xFF4CAF50)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(levelRect, const Radius.circular(1.5)),
          achievedPaint,
        );
      } else if (level.isFilled) {
        final levelPaint = Paint()
          ..color = level.color
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(levelRect, const Radius.circular(1.5)),
          levelPaint,
        );
      } else {
        final emptyPaint = Paint()
          ..color = Colors.grey[200]!
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(levelRect, const Radius.circular(1.5)),
          emptyPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(BatteryPainter oldDelegate) {
    return oldDelegate.levels != levels ||
        oldDelegate.isGoalReached != isGoalReached ||
        oldDelegate.horizontal != horizontal;
  }
}

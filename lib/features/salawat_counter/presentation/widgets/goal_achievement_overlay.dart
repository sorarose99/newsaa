import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alslat_aalnabi/core/localization/app_localizations.dart';

class GoalAchievementOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const GoalAchievementOverlay({super.key, required this.onDismiss});

  @override
  State<GoalAchievementOverlay> createState() => _GoalAchievementOverlayState();
}

class _GoalAchievementOverlayState extends State<GoalAchievementOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeController);
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _fadeController.reverse().then((_) {
          if (mounted) {
            widget.onDismiss();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 36.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 40.r,
                  spreadRadius: 15.r,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStarAnimation(),
                SizedBox(height: 24.h),
                Text(
                  localizations.goalAchievementTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.r,
                        color: Colors.black26,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  localizations.goalAchievementSubtitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    shadows: [
                      Shadow(
                        blurRadius: 10.r,
                        color: Colors.black26,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 2 * 3.14159),
      duration: const Duration(milliseconds: 2000),
      builder: (context, angle, child) {
        return Transform.rotate(angle: angle, child: child);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140.w,
            height: 140.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.6),
                  blurRadius: 40.r,
                  spreadRadius: 15.r,
                ),
              ],
            ),
          ),
          Icon(
            Icons.star,
            size: 120.sp,
            color: const Color(0xFFFFD700),
            shadows: [
              Shadow(
                blurRadius: 20.r,
                color: const Color(0xFFFFD700),
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

part of '../../quran.dart';

class RightPage extends StatelessWidget {
  final Widget child;

  RightPage({super.key, required this.child});

  final quranCtrl = QuranController.instance;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Quran Page',
      child: Container(
        margin: context.customOrientation(
          const EdgeInsets.only(right: 2.0),
          const EdgeInsets.only(right: 2.0),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.transparent
              : Theme.of(context).dividerColor.withValues(alpha: .5),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(right: 1.0),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.transparent
                : Theme.of(context).dividerColor.withValues(alpha: .7),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: GetX<QuranController>(
            builder: (quranCtrl) => Container(
              margin: const EdgeInsets.only(right: 1.0),
              decoration: BoxDecoration(
                color: quranCtrl.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

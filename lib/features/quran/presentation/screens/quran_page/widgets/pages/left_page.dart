part of '../../quran.dart';

class LeftPage extends StatelessWidget {
  final Widget child;

  LeftPage({super.key, required this.child});

  final quranCtrl = QuranController.instance;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Quran Page',
      child: Container(
        margin: const EdgeInsets.only(left: 2.0),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.transparent
              : Theme.of(context).dividerColor.withValues(alpha: .5),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(left: 1.0),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.transparent
                : Theme.of(context).dividerColor.withValues(alpha: .7),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
          ),
          child: GetX<QuranController>(
            builder: (quranCtrl) => Container(
              margin: const EdgeInsets.only(left: 1.0),
              decoration: BoxDecoration(
                color: quranCtrl.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
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

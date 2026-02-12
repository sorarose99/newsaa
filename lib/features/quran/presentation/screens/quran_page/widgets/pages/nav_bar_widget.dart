part of '../../quran.dart';

class NavBarWidget extends StatelessWidget {
  NavBarWidget({super.key});
  final generalCtrl = GeneralController.instance;
  final quranCtrl = QuranController.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavIcon(
            context,
            iconPath: SvgPath.svgListIcon,
            onTap: () {
              if (GlobalKeyManager().drawerKey.currentState != null) {
                GlobalKeyManager().drawerKey.currentState!.toggle();
              }
            },
          ),
          _buildNavIcon(
            context,
            iconPath: SvgPath.svgBookmarkList,
            onTap: () {
              customBottomSheet(const KhatmahBookmarksScreen());
              generalCtrl.state.showSelectScreenPage.value = false;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(
    BuildContext context, {
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 1,
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
          ),
        ),
        child: customSvgWithCustomColor(
          iconPath,
          height: 24,
          width: 24,
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}

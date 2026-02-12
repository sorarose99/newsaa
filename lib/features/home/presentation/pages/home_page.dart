import 'package:alslat_aalnabi/features/virtues/presentation/pages/virtues_page.dart';
import 'package:alslat_aalnabi/features/quran/presentation/screens/quran_page/quran.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alslat_aalnabi/core/localization/app_localizations.dart';
import 'package:alslat_aalnabi/features/salawat_counter/presentation/pages/counter_page.dart';
import 'package:alslat_aalnabi/features/settings/presentation/pages/settings_page.dart';
import 'package:alslat_aalnabi/features/settings/presentation/widgets/settings_provider.dart';
import 'package:alslat_aalnabi/features/statistics/presentation/pages/statistics_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const CounterPage(),
    const StatisticsPage(),
    const VirtuesPage(),
    QuranHome(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localizations = AppLocalizations.of(context)!;
      final settingsProvider = Provider.of<SettingsProvider>(
        context,
        listen: false,
      );
      settingsProvider.setNotificationTitle(localizations.notificationTitle);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: localizations.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: localizations.plan,
          ),
          NavigationDestination(
            icon: const Icon(Icons.book_outlined),
            selectedIcon: const Icon(Icons.book),
            label: localizations.virtues,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: localizations.quran,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: localizations.settings,
          ),
        ],
      ),
    );
  }
}

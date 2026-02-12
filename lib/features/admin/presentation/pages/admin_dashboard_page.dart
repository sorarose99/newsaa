import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alslat_aalnabi/core/widgets/sync_status_widget.dart';
import 'package:alslat_aalnabi/features/admin/presentation/providers/admin_provider.dart';
import 'package:alslat_aalnabi/features/admin/presentation/pages/virtues_management_page.dart';
import 'package:alslat_aalnabi/features/admin/presentation/pages/prayer_formula_sounds_management_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        if (!adminProvider.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/admin-login');
          });
          return const Scaffold(body: SizedBox.shrink());
        }
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home', (route) => false);
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('لوحة التحكم الاستراتيجية'),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: SyncStatusWidget(
                      showDetails: false,
                      showButton: false,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: 'تسجيل الخروج',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('تأكيد تسجيل الخروج'),
                        content: const Text(
                          'هل أنت متأكد من رغبتك في تسجيل الخروج من لوحة التحكم؟',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('إلغاء'),
                          ),
                          FilledButton.tonal(
                            onPressed: () async {
                              final navigator = Navigator.of(context);
                              await context.read<AdminProvider>().logout();
                              if (mounted) {
                                navigator.pushReplacementNamed('/home');
                              }
                            },
                            child: const Text('تسجيل الخروج'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            body: adminProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colorScheme.surface,
                          colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.3,
                          ),
                        ],
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.admin_panel_settings,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'نظرة عامة على الإدارة',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const SyncStatusWidget(
                            showDetails: true,
                            showButton: true,
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'الأدوات المتاحة',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _buildMenuButton(
                            context,
                            title: 'إدارة الفضائل',
                            subtitle:
                                'تعديل النصوص والوسائط المتعددة (صور/فيديو)',
                            icon: Icons.auto_awesome_mosaic_rounded,
                            color: Colors.teal,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const VirtuesManagementPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildMenuButton(
                            context,
                            title: 'إدارة الصيغ الصوتية',
                            subtitle: 'تحديث الملفات الصوتية لصيغ الصلاة',
                            icon: Icons.record_voice_over_rounded,
                            color: Colors.blueGrey,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PrayerFormulaSoundsManagementPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

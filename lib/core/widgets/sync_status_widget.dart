import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alslat_aalnabi/core/providers/sync_provider.dart';

class SyncStatusWidget extends StatelessWidget {
  final bool showDetails;
  final bool showButton;

  const SyncStatusWidget({
    super.key,
    this.showDetails = true,
    this.showButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, _) {
        Color statusColor;
        IconData statusIcon;
        String statusLabel;

        switch (syncProvider.syncStatus) {
          case 'online':
            statusColor = Colors.green;
            statusIcon = Icons.cloud_done;
            statusLabel = 'متصل';
            break;
          case 'offline':
            statusColor = Colors.orange;
            statusIcon = Icons.cloud_off;
            statusLabel = 'غير متصل';
            break;
          case 'syncing':
            statusColor = Colors.blue;
            statusIcon = Icons.cloud_upload;
            statusLabel = 'جاري المزامنة';
            break;
          case 'synced':
            statusColor = Colors.green;
            statusIcon = Icons.check_circle;
            statusLabel = 'تم المزامنة';
            break;
          case 'error':
            statusColor = Colors.red;
            statusIcon = Icons.error;
            statusLabel = 'خطأ';
            break;
          default:
            statusColor = Colors.grey;
            statusIcon = Icons.help;
            statusLabel = 'غير معروف';
        }

        if (!showDetails) {
          return Tooltip(
            message: syncProvider.syncMessage,
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 20,
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            border: Border.all(color: statusColor, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          syncProvider.syncMessage,
                          style: TextStyle(
                            color: statusColor.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (showButton && syncProvider.isOnline && !syncProvider.isSyncing)
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.refresh, size: 16),
                        onPressed: () {
                          syncProvider.manualSync();
                        },
                      ),
                    ),
                  if (syncProvider.isSyncing)
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                ],
              ),
              if (syncProvider.lastSyncTime != null && showDetails)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'آخر مزامنة: ${syncProvider.getFormattedLastSyncTime()}',
                    style: TextStyle(
                      color: statusColor.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class SyncStatusSnackBar {
  static void showOnline(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.cloud_done, color: Colors.white),
            SizedBox(width: 8),
            Text('متصل بالإنترنت'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showOffline(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.cloud_off, color: Colors.white),
            SizedBox(width: 8),
            Text('غير متصل بالإنترنت'),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showSyncError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:alslat_aalnabi/core/services/sync_manager_service.dart';

class SyncProvider extends ChangeNotifier {
  final SyncManagerService _syncManager = SyncManagerService();

  bool _isOnline = false;
  bool _isSyncing = false;
  String _syncStatus = 'offline';
  DateTime? _lastSyncTime;
  String _syncMessage = '';

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  String get syncStatus => _syncStatus;
  DateTime? get lastSyncTime => _lastSyncTime;
  String get syncMessage => _syncMessage;

  SyncProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _syncManager.syncStatusStream.listen((status) {
      _isSyncing = status == SyncStatus.syncing;
      
      switch (status) {
        case SyncStatus.syncing:
          _syncStatus = 'syncing';
          _syncMessage = 'جاري مزامنة البيانات...';
          break;
        case SyncStatus.synced:
          _syncStatus = 'synced';
          _syncMessage = 'تمت المزامنة بنجاح';
          _lastSyncTime = DateTime.now();
          break;
        case SyncStatus.error:
          _syncStatus = 'error';
          _syncMessage = 'حدث خطأ أثناء المزامنة';
          break;
      }
      
      notifyListeners();
    });

    _isOnline = _syncManager.isOnline;
    if (_isOnline) {
      _syncStatus = 'online';
      _syncMessage = 'متصل بالإنترنت';
    } else {
      _syncStatus = 'offline';
      _syncMessage = 'العمل بدون إنترنت';
    }
    notifyListeners();
  }

  Future<void> manualSync() async {
    if (!_isOnline) {
      _syncMessage = 'لا توجد اتصالة إنترنت. سيتم المزامنة عند توفر الاتصال.';
      notifyListeners();
      return;
    }

    if (_isSyncing) {
      _syncMessage = 'جاري المزامنة بالفعل...';
      notifyListeners();
      return;
    }

    await _syncManager.syncAllData();
  }

  Future<bool> checkConnectivity() async {
    _isOnline = await _syncManager.checkConnectivity();
    
    if (_isOnline) {
      _syncStatus = 'online';
      _syncMessage = 'متصل بالإنترنت';
      await _syncManager.syncAllData();
    } else {
      _syncStatus = 'offline';
      _syncMessage = 'العمل بدون إنترنت';
    }
    
    notifyListeners();
    return _isOnline;
  }

  String getFormattedLastSyncTime() {
    if (_lastSyncTime == null) {
      return 'لم تتم مزامنة بعد';
    }

    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime!);

    if (difference.inMinutes < 1) {
      return 'للتو';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }

  @override
  void dispose() {
    _syncManager.dispose();
    super.dispose();
  }
}

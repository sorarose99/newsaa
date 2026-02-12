import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:alslat_aalnabi/core/services/sync_manager_service.dart';
import 'package:alslat_aalnabi/features/virtues/data/models/virtue_model.dart';
import 'package:alslat_aalnabi/features/virtues/data/services/virtues_service.dart';

class VirtuesProvider extends ChangeNotifier {
  final VirtuesService _virtuesService = VirtuesService();
  final SyncManagerService _syncManager = SyncManagerService();

  List<Virtue> _virtues = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Virtue> get virtues => _virtues;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  VirtuesProvider() {
    loadVirtues();
  }

  Future<void> loadVirtues({bool forceSync = false}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _virtues = await _syncManager.getVirtues(forceOnline: forceSync);
    } catch (e) {
      _errorMessage = 'خطأ في تحميل الفضائل: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addVirtue(Virtue virtue, {Uint8List? fileBytes}) async {
    developer.log(
      'addVirtue called: title=${virtue.title}, type=${virtue.type}, url=${virtue.url}, hasBytes=${fileBytes != null}',
    );
    _isLoading = true;
    notifyListeners();
    try {
      Virtue virtueToAdd = virtue;

      if (virtue.type == VirtueType.image &&
          ((virtue.filePath != null && virtue.filePath!.isNotEmpty) ||
              fileBytes != null)) {
        developer.log('Uploading image file to Supabase...');
        String imageUrl;
        if (fileBytes != null) {
          imageUrl = await _virtuesService.uploadFileBytes(
            fileBytes,
            'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
            'images',
          );
        } else {
          imageUrl = await _virtuesService.uploadFile(
            virtue.filePath!,
            'images',
          );
        }

        virtueToAdd = virtue.copyWith(url: imageUrl);
        developer.log('Image uploaded successfully: $imageUrl');
      } else if (virtue.type == VirtueType.video) {
        developer.log(
          'Video virtue detected: url=${virtue.url}, filePath=${virtue.filePath}, hasBytes=${fileBytes != null}',
        );
        if (((virtue.filePath != null && virtue.filePath!.isNotEmpty) ||
                fileBytes != null) &&
            (virtue.url == null || virtue.url!.isEmpty)) {
          // Upload local file to Supabase if no URL is provided
          developer.log('Uploading video file to Supabase...');
          String uploadedUrl;
          if (fileBytes != null) {
            uploadedUrl = await _virtuesService.uploadFileBytes(
              fileBytes,
              'video_${DateTime.now().millisecondsSinceEpoch}.mp4',
              'videos',
            );
          } else {
            uploadedUrl = await _virtuesService.uploadFile(
              virtue.filePath!,
              'videos',
            );
          }

          virtueToAdd = virtue.copyWith(url: uploadedUrl);
          developer.log('Video uploaded successfully: $uploadedUrl');
        } else {
          virtueToAdd = virtue;
        }
      }

      developer.log(
        'Saving virtue to service: title=${virtueToAdd.title}, type=${virtueToAdd.type}, url=${virtueToAdd.url}',
      );
      try {
        await _virtuesService.addVirtue(virtueToAdd);
        _errorMessage = '';
        developer.log('Virtue saved successfully to Supabase');
      } catch (e) {
        _errorMessage = 'خطأ في حفظ الفيديو على الخادم: $e';
        developer.log('Error saving virtue: $e');
        rethrow;
      }
      await loadVirtues(forceSync: true);
    } catch (e) {
      _errorMessage = 'خطأ في إضافة الفضيلة: $e';
      developer.log('Error in addVirtue: $e');
      rethrow;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateVirtue(Virtue virtue, {Uint8List? fileBytes}) async {
    _isLoading = true;
    notifyListeners();
    try {
      Virtue virtueToUpdate = virtue;

      if (virtue.type == VirtueType.image &&
          ((virtue.filePath != null && virtue.filePath!.isNotEmpty) ||
              fileBytes != null)) {
        developer.log('Updating image file in Supabase...');
        String imageUrl;
        if (fileBytes != null) {
          imageUrl = await _virtuesService.uploadFileBytes(
            fileBytes,
            'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
            'images',
          );
        } else {
          imageUrl = await _virtuesService.uploadFile(
            virtue.filePath!,
            'images',
          );
        }
        virtueToUpdate = virtue.copyWith(url: imageUrl);
        developer.log('Image updated and uploaded successfully: $imageUrl');
      } else if (virtue.type == VirtueType.video) {
        if (((virtue.filePath != null && virtue.filePath!.isNotEmpty) ||
                fileBytes != null) &&
            (virtue.url == null || virtue.url!.isEmpty)) {
          // Upload local file to Supabase if no URL is provided
          developer.log('Updating video file in Supabase...');
          String uploadedUrl;
          if (fileBytes != null) {
            uploadedUrl = await _virtuesService.uploadFileBytes(
              fileBytes,
              'video_${DateTime.now().millisecondsSinceEpoch}.mp4',
              'videos',
            );
          } else {
            uploadedUrl = await _virtuesService.uploadFile(
              virtue.filePath!,
              'videos',
            );
          }
          virtueToUpdate = virtue.copyWith(url: uploadedUrl);
          developer.log(
            'Video updated and uploaded successfully: $uploadedUrl',
          );
        }
      }

      try {
        await _virtuesService.updateVirtue(virtueToUpdate);
        _errorMessage = '';
      } catch (e) {
        _errorMessage = 'خطأ في تحديث الفيديو على الخادم: $e';
      }

      final index = _virtues.indexWhere((v) => v.id == virtueToUpdate.id);
      if (index != -1) {
        _virtues[index] = virtueToUpdate;
      }
    } catch (e) {
      _errorMessage = 'خطأ في تحديث الفضيلة: $e';
      rethrow;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteVirtue(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _virtuesService.deleteVirtue(id);
      await loadVirtues(forceSync: true);
    } catch (e) {
      _errorMessage = 'خطأ في حذف الفضيلة: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateVirtueFilePath(String virtueId, String filePath) async {
    try {
      final index = _virtues.indexWhere((v) => v.id == virtueId);
      if (index != -1) {
        final virtue = _virtues[index];
        final updatedVirtue = Virtue(
          id: virtue.id,
          type: virtue.type,
          category: virtue.category,
          text: virtue.text,
          title: virtue.title,
          description: virtue.description,
          url: virtue.url,
          filePath: filePath,
          imageBinary: virtue.imageBinary,
        );

        await _virtuesService.updateVirtue(updatedVirtue);
        _virtues[index] = updatedVirtue;
        notifyListeners();

        developer.log(
          'Virtue file path updated: id=$virtueId, filePath=$filePath',
        );
      }
    } catch (e) {
      developer.log('Error updating virtue file path: $e', error: e);
      _errorMessage = 'خطأ في حفظ مسار الفيديو: $e';
    }
  }

  Future<void> deleteVirtueFilePath(String virtueId) async {
    try {
      final index = _virtues.indexWhere((v) => v.id == virtueId);
      if (index != -1) {
        final virtue = _virtues[index];
        final updatedVirtue = Virtue(
          id: virtue.id,
          type: virtue.type,
          category: virtue.category,
          text: virtue.text,
          title: virtue.title,
          description: virtue.description,
          url: virtue.url,
          filePath: null,
          imageBinary: virtue.imageBinary,
        );

        await _virtuesService.updateVirtue(updatedVirtue);
        _virtues[index] = updatedVirtue;
        notifyListeners();

        developer.log('Virtue file path deleted: id=$virtueId');
      }
    } catch (e) {
      developer.log('Error deleting virtue file path: $e', error: e);
      _errorMessage = 'خطأ في حذف مسار الفيديو: $e';
    }
  }
}

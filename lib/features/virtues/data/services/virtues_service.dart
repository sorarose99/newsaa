import 'dart:io';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_util;
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:alslat_aalnabi/core/services/offline_database_service.dart';
import 'package:alslat_aalnabi/features/virtues/data/models/virtue_model.dart';

class VirtuesService {
  final _supabase = Supabase.instance.client;
  final _offlineDb = OfflineDatabaseService();

  Future<String> uploadFile(String filePath, String destination) async {
    try {
      final file = File(filePath);
      final fileName = filePath.split('/').last;

      final mimeType = _getMimeType(fileName);
      String bucketName = 'files';
      String storagePath = '$destination/$fileName';

      // Always use 'videos' bucket for video uploads or if destination explicitly requests it
      if (destination == 'videos' || mimeType.startsWith('video/')) {
        bucketName = 'videos';
        // If the destination explicitly matches the bucket name,
        // we store at the root of the bucket for cleaner organization
        if (destination == 'videos') {
          storagePath = fileName;
        }
      }

      // On mobile/desktop, use .upload(path, File) which is more memory efficient
      await _supabase.storage
          .from(bucketName)
          .upload(
            storagePath,
            file,
            fileOptions: FileOptions(contentType: mimeType, upsert: true),
          );

      final url = _supabase.storage.from(bucketName).getPublicUrl(storagePath);
      return url;
    } catch (e) {
      throw Exception('Error uploading file to "$destination": $e');
    }
  }

  Future<String> uploadFileBytes(
    List<int> bytes,
    String fileName,
    String destination,
  ) async {
    try {
      final mimeType = _getMimeType(fileName);
      developer.log('Uploading file: $fileName with MIME type: $mimeType');

      String bucketName = 'files';
      String storagePath = '$destination/$fileName';

      // Always use 'videos' bucket for video uploads or if destination explicitly requests it
      if (destination == 'videos' || mimeType.startsWith('video/')) {
        bucketName = 'videos';
        // If the destination explicitly matches the bucket name,
        // we store at the root of the bucket for cleaner organization
        if (destination == 'videos') {
          storagePath = fileName;
        }
      }

      await _supabase.storage
          .from(bucketName)
          .uploadBinary(
            storagePath,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(contentType: mimeType, upsert: true),
          );

      final url = _supabase.storage.from(bucketName).getPublicUrl(storagePath);
      return url;
    } catch (e) {
      developer.log('Error uploading file bytes: $e', error: e);
      throw Exception('Error uploading file bytes to "$destination": $e');
    }
  }

  /// Detects MIME type from file extension
  String _getMimeType(String fileName) {
    // Try to get extension
    final parts = fileName.split('.');
    final extension = parts.length > 1 ? parts.last.toLowerCase() : '';

    // If no extension, try to infer from filename pattern
    if (extension.isEmpty || extension == fileName.toLowerCase()) {
      developer.log(
        'No file extension found in: $fileName, attempting to infer type',
      );

      // Check if filename suggests it's an image
      if (fileName.toLowerCase().contains('image')) {
        developer.log('Filename contains "image", defaulting to image/jpeg');
        return 'image/jpeg';
      }

      // Check if filename suggests it's a video
      if (fileName.toLowerCase().contains('video')) {
        developer.log('Filename contains "video", defaulting to video/mp4');
        return 'video/mp4';
      }

      developer.log(
        'Could not infer type from filename: $fileName, using application/octet-stream',
      );
      return 'application/octet-stream';
    }

    switch (extension) {
      // Images
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';

      // Videos
      case 'mp4':
        return 'video/mp4';
      case 'webm':
        return 'video/webm';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';

      // Audio
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'm4a':
        return 'audio/mp4';
      case 'ogg':
        return 'audio/ogg';

      // Documents
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';

      // Default
      default:
        developer.log(
          'Unknown file extension: $extension, using application/octet-stream',
        );
        return 'application/octet-stream';
    }
  }

  Future<String> uploadImageBinary(String filePath) async {
    try {
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();

      developer.log('Image upload - File size: ${fileBytes.length} bytes');

      final base64String = Virtue.encodeImageToBase64(fileBytes);

      developer.log(
        'Image upload - Base64 encoded, length: ${base64String.length}',
      );

      return base64String;
    } catch (e) {
      developer.log('Error encoding image to Base64: $e', error: e);
      throw Exception('Error uploading image binary: $e');
    }
  }

  Future<String> copyVideoToPermanentLocation(String tempFilePath) async {
    try {
      developer.log(
        'copyVideoToPermanentLocation: Starting with path: $tempFilePath',
      );

      final appDocDir = await getApplicationDocumentsDirectory();
      final videosDir = Directory('${appDocDir.path}/videos');

      if (tempFilePath.startsWith(videosDir.path)) {
        developer.log('Video already in permanent location: $tempFilePath');
        final permanentFile = File(tempFilePath);
        if (await permanentFile.exists()) {
          return tempFilePath;
        }
        throw Exception(
          'الملف الدائم موجود في قاعدة البيانات لكنه غير موجود على القرص: $tempFilePath',
        );
      }

      final sourceFile = File(tempFilePath);

      if (!await sourceFile.exists()) {
        throw Exception('الملف المصدر غير موجود: $tempFilePath');
      }

      developer.log(
        'Source file exists, size: ${await sourceFile.length()} bytes',
      );

      if (!await videosDir.exists()) {
        await videosDir.create(recursive: true);
        developer.log('Created videos directory: ${videosDir.path}');
      }

      final fileName = path_util.basename(tempFilePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';
      final newFilePath = '${videosDir.path}/$uniqueFileName';

      developer.log('Copying video from: $tempFilePath to: $newFilePath');

      await sourceFile.copy(newFilePath);

      final copiedFile = File(newFilePath);
      if (!await copiedFile.exists()) {
        throw Exception('فشل التحقق من نسخ الملف: الملف غير موجود بعد النسخ');
      }

      developer.log(
        'Video copied successfully. New file size: ${await copiedFile.length()} bytes',
      );

      return newFilePath;
    } catch (e) {
      developer.log('Error copying video file: $e', error: e);
      throw Exception('خطأ في نسخ ملف الفيديو: $e');
    }
  }

  Future<List<Virtue>> getVirtues() async {
    try {
      final response = await _supabase.from('virtues').select();

      return (response as List)
          .map(
            (doc) =>
                Virtue.fromFirestore(doc as Map<String, dynamic>, doc['id']),
          )
          .toList();
    } catch (e) {
      throw Exception('Error fetching virtues: $e');
    }
  }

  Future<void> addVirtue(Virtue virtue) async {
    try {
      final id = virtue.id ?? _generateId();
      final virtueWithId = Virtue(
        id: id,
        type: virtue.type,
        category: virtue.category,
        text: virtue.text,
        title: virtue.title,
        description: virtue.description,
        url: virtue.url,
        filePath: virtue.filePath,
        imageBinary: virtue.imageBinary,
      );

      developer.log(
        'Adding virtue with id=$id, title=${virtue.title}, type=${virtue.type}',
      );

      await _supabase.from('virtues').insert(virtueWithId.toFirestore());
      developer.log('Inserted into Supabase');

      await _offlineDb.insertVirtue(virtueWithId.toJson());
      developer.log('Inserted into local database');

      developer.log('Virtue added successfully: id=$id, title=${virtue.title}');
    } catch (e) {
      developer.log('Error adding virtue: $e', error: e);
      throw Exception('Error adding virtue: $e');
    }
  }

  String _generateId() {
    return const Uuid().v4();
  }

  Future<void> updateVirtue(Virtue virtue) async {
    try {
      if (virtue.id == null) {
        throw Exception('Virtue ID cannot be null when updating.');
      }
      await _supabase
          .from('virtues')
          .update(virtue.toFirestore())
          .eq('id', virtue.id!);

      await _offlineDb.updateVirtue(virtue.id!, virtue.toJson());

      developer.log('Virtue updated successfully: id=${virtue.id}');
    } catch (e) {
      developer.log('Error updating virtue: $e', error: e);
      throw Exception('Error updating virtue: $e');
    }
  }

  Future<void> deleteVirtue(String id) async {
    try {
      await _supabase.from('virtues').delete().eq('id', id);
      await _offlineDb.deleteVirtue(id);

      developer.log('Virtue deleted successfully: id=$id');
    } catch (e) {
      developer.log('Error deleting virtue: $e', error: e);
      throw Exception('Error deleting virtue: $e');
    }
  }

  Future<String> downloadVideo(
    String url,
    String videoId, {
    required void Function(double) onProgress,
  }) async {
    try {
      developer.log('Starting video download: url=$url, videoId=$videoId');

      final appDocDir = await getApplicationDocumentsDirectory();
      final videosDir = Directory('${appDocDir.path}/videos');

      if (!await videosDir.exists()) {
        await videosDir.create(recursive: true);
        developer.log('Created videos directory: ${videosDir.path}');
      }

      final fileName =
          'video_${videoId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final filePath = '${videosDir.path}/$fileName';

      final dio = Dio();

      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total) * 100;
            developer.log('Download progress: $progress%');
            onProgress(progress / 100);
          }
        },
      );

      developer.log('Video downloaded successfully to: $filePath');
      return filePath;
    } catch (e) {
      developer.log('Error downloading video: $e', error: e);
      throw Exception('فشل تحميل الفيديو: $e');
    }
  }

  Future<bool> checkVideoExists(String? filePath) async {
    if (filePath == null || filePath.isEmpty) {
      return false;
    }
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      developer.log('Error checking if video exists: $e');
      return false;
    }
  }

  Future<void> deleteDownloadedVideo(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        developer.log('Downloaded video deleted: $filePath');
      }
    } catch (e) {
      developer.log('Error deleting downloaded video: $e', error: e);
    }
  }

  Future<String> downloadYouTubeVideo(
    String youtubeUrl,
    String videoId, {
    required void Function(double) onProgress,
  }) async {
    try {
      developer.log(
        'Starting YouTube video download: url=$youtubeUrl, videoId=$videoId',
      );

      final appDocDir = await getApplicationDocumentsDirectory();
      final videosDir = Directory('${appDocDir.path}/videos');

      if (!await videosDir.exists()) {
        await videosDir.create(recursive: true);
        developer.log('Created videos directory: ${videosDir.path}');
      }

      final yt = YoutubeExplode();
      try {
        final video = await yt.videos.get(youtubeUrl);
        developer.log('YouTube video info: ${video.title}');

        final streamManifest = await yt.videos.streamsClient.getManifest(
          youtubeUrl,
        );

        final muxedStreams = streamManifest.muxed;
        if (muxedStreams.isEmpty) {
          throw Exception('لا توجد تدفقات فيديو متاحة');
        }

        final muxedStream = muxedStreams.withHighestBitrate();

        final fileName =
            'yt_${videoId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
        final filePath = '${videosDir.path}/$fileName';
        final file = File(filePath);

        final httpClient = HttpClient();
        final request = await httpClient.getUrl(
          Uri.parse(muxedStream.url.toString()),
        );
        final response = await request.close();

        developer.log('YouTube stream size: ${response.contentLength} bytes');

        int receivedBytes = 0;
        final sink = file.openWrite();

        await response.forEach((List<int> chunk) {
          receivedBytes += chunk.length;
          final progress = receivedBytes / response.contentLength;
          developer.log(
            'YouTube download progress: ${(progress * 100).toStringAsFixed(1)}%',
          );
          onProgress(progress);
          sink.add(chunk);
        });

        await sink.flush();
        await sink.close();
        httpClient.close();

        developer.log('YouTube video downloaded successfully to: $filePath');
        return filePath;
      } finally {
        yt.close();
      }
    } catch (e) {
      developer.log('Error downloading YouTube video: $e', error: e);
      throw Exception('فشل تحميل فيديو YouTube: $e');
    }
  }
}

import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  double _volume = 0.5;
  File? _currentTempFile;

  Function()? _onPlaybackComplete;

  Future<void> initialize() async {
    await _audioPlayer.setVolume(_volume);
    _setupAudioPlayerListeners();
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      developer.log('Audio player state: $state');
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      developer.log('Audio playback completed');
      _onPlaybackComplete?.call();
      _scheduleCleanup();
    });
  }

  void setOnPlaybackComplete(Function() callback) {
    _onPlaybackComplete = callback;
  }

  String _detectAudioFormat(List<int> soundBinary) {
    developer.log('[AUDIO_FORMAT] ===== AUDIO FORMAT DETECTION START =====');
    developer.log(
      '[AUDIO_FORMAT] Total binary size: ${soundBinary.length} bytes',
    );

    if (soundBinary.length < 4) {
      developer.log(
        '[AUDIO_FORMAT] Binary too small (${soundBinary.length} bytes), defaulting to mp3',
      );
      developer.log(
        '[AUDIO_FORMAT] ===== AUDIO FORMAT DETECTION END (SMALL) =====',
      );
      return 'mp3';
    }

    final header = soundBinary.sublist(0, 4);
    final headerHex = header
        .map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}')
        .join(' ');
    final headerDecimal = header.map((b) => b).toList();
    developer.log('[AUDIO_FORMAT] Header bytes (HEX): $headerHex');
    developer.log('[AUDIO_FORMAT] Header bytes (DEC): $headerDecimal');

    // First 16 bytes for analysis
    if (soundBinary.length >= 16) {
      final first16 = soundBinary.sublist(0, 16);
      final first16Hex = first16
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(' ');
      developer.log('[AUDIO_FORMAT] First 16 bytes: $first16Hex');
    }

    // MP3 MPEG frame sync (0xFF followed by sync bits)
    if (header[0] == 0xFF && (header[1] & 0xE0) == 0xE0) {
      developer.log('[AUDIO_FORMAT] ✓ MATCH: MP3 (MPEG frame sync)');
      developer.log(
        '[AUDIO_FORMAT] ===== AUDIO FORMAT DETECTION END (MP3-MPEG) =====',
      );
      return 'mp3';
    }

    // MP3 ID3 tag
    if (header[0] == 0x49 && header[1] == 0x44 && header[2] == 0x33) {
      developer.log('[AUDIO_FORMAT] ✓ MATCH: MP3 (ID3 tag)');
      developer.log(
        '[AUDIO_FORMAT] ===== AUDIO FORMAT DETECTION END (MP3-ID3) =====',
      );
      return 'mp3';
    }

    // M4A/AAC (ftyp)
    if (header[0] == 0x66 &&
        header[1] == 0x74 &&
        header[2] == 0x79 &&
        header[3] == 0x70) {
      developer.log('[AUDIO_FORMAT] ✓ MATCH: M4A/AAC (ftyp signature)');
      developer.log(
        '[AUDIO_FORMAT] ===== AUDIO FORMAT DETECTION END (M4A) =====',
      );
      return 'm4a';
    }

    // WAV (RIFF)
    if (header[0] == 0x52 &&
        header[1] == 0x49 &&
        header[2] == 0x46 &&
        header[3] == 0x46) {
      developer.log('[AUDIO_FORMAT] ✓ MATCH: WAV (RIFF signature)');
      developer.log(
        '[AUDIO_FORMAT] ===== AUDIO FORMAT DETECTION END (WAV) =====',
      );
      return 'wav';
    }

    // Alternative MP3 sync
    if (header[0] == 0xFF && header[1] == 0xFB) {
      developer.log('[AUDIO_FORMAT] ✓ MATCH: MP3 (Alternative MPEG sync)');
      developer.log(
        '[AUDIO_FORMAT] ===== AUDIO FORMAT DETECTION END (MP3-ALT) =====',
      );
      return 'mp3';
    }

    developer.log(
      '[AUDIO_FORMAT] ✗ NO MATCH: Unknown format, defaulting to mp3',
    );
    developer.log(
      '[AUDIO_FORMAT] ===== AUDIO FORMAT DETECTION END (DEFAULT) =====',
    );
    return 'mp3';
  }

  Future<void> playNotificationSound(String soundPath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setVolume(_volume);
      developer.log('Playing notification sound from: $soundPath');
      await _audioPlayer.play(DeviceFileSource(soundPath));
    } catch (e) {
      developer.log('Error playing notification sound: $e', error: e);
    }
  }

  Future<void> playAssetSound(String assetPath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setVolume(_volume);
      developer.log('Playing asset sound: $assetPath');
      // audioplayers 6.x uses AssetSource for assets, relative to 'assets/'
      await _audioPlayer.play(
        AssetSource(assetPath.replaceFirst('assets/', '')),
      );
    } catch (e) {
      developer.log('Error playing asset sound: $e', error: e);
    }
  }

  Future<void> playFromUrl(String soundUrl) async {
    try {
      if (soundUrl.isEmpty) {
        developer.log('Error: Sound URL is empty');
        return;
      }

      developer.log('Starting playFromUrl with: $soundUrl');
      await _audioPlayer.stop();
      await _audioPlayer.setVolume(_volume);

      developer.log('Playing audio from URL: $soundUrl');
      await _audioPlayer.play(UrlSource(soundUrl));
      developer.log('Audio playback initiated successfully from URL');
    } catch (e) {
      developer.log(
        'Error playing from URL: $e',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  Future<void> playBinarySound(List<int> soundBinary) async {
    try {
      developer.log('[AUDIO_PLAY] ===== PLAYBACK START =====');

      if (soundBinary.isEmpty) {
        developer.log('[AUDIO_PLAY] ✗ ERROR: Sound binary is empty');
        developer.log('[AUDIO_PLAY] ===== PLAYBACK END (EMPTY) =====');
        throw Exception('Sound binary is empty');
      }

      developer.log(
        '[AUDIO_PLAY] ✓ Received sound: ${soundBinary.length} bytes',
      );

      if (soundBinary.length < 100) {
        developer.log(
          '[AUDIO_PLAY] ⚠ WARNING: Audio data very small (${soundBinary.length} bytes) - may be corrupted',
        );
      }

      developer.log('[AUDIO_PLAY] Stopping any current playback...');
      await _audioPlayer.stop();

      developer.log('[AUDIO_PLAY] Setting volume to: $_volume');
      await _audioPlayer.setVolume(_volume);
      developer.log('[AUDIO_PLAY] ✓ Volume set');

      developer.log('[AUDIO_PLAY] Detecting audio format...');
      final audioFormat = _detectAudioFormat(soundBinary);
      developer.log('[AUDIO_PLAY] ✓ Format detected: $audioFormat');

      // Web platform: use BytesSource directly
      if (kIsWeb) {
        developer.log('[AUDIO_PLAY] Running on Web, using BytesSource...');
        final bytes = Uint8List.fromList(soundBinary);
        final source = BytesSource(bytes);
        developer.log(
          '[AUDIO_PLAY] ✓ BytesSource created with ${bytes.length} bytes',
        );

        developer.log('[AUDIO_PLAY] Initiating playback on web...');
        await _audioPlayer.play(source);
        developer.log(
          '[AUDIO_PLAY] ✓✓✓ WEB PLAYBACK INITIATED SUCCESSFULLY ✓✓✓',
        );
        developer.log('[AUDIO_PLAY] ===== PLAYBACK END (WEB SUCCESS) =====');
        return;
      }

      // Non-web platforms: use file system
      developer.log('[AUDIO_PLAY] Getting temporary directory...');
      final tempDir = await getTemporaryDirectory();
      developer.log('[AUDIO_PLAY] Temp directory: ${tempDir.path}');

      final fileName =
          'prayer_formula_${DateTime.now().millisecondsSinceEpoch}.$audioFormat';
      final tempFile = File('${tempDir.path}/$fileName');
      developer.log('[AUDIO_PLAY] Target file: ${tempFile.path}');

      developer.log(
        '[AUDIO_PLAY] Writing ${soundBinary.length} bytes to file...',
      );
      await tempFile.writeAsBytes(soundBinary);
      developer.log('[AUDIO_PLAY] ✓ File written to disk');

      if (!tempFile.existsSync()) {
        final errorMsg =
            'Failed to create temporary audio file at: ${tempFile.path}';
        developer.log('[AUDIO_PLAY] ✗ $errorMsg');
        throw Exception(errorMsg);
      }
      developer.log('[AUDIO_PLAY] ✓ File exists verified');

      _currentTempFile = tempFile;
      final fileSize = tempFile.lengthSync();
      developer.log('[AUDIO_PLAY] ✓ Temp file size: $fileSize bytes');

      if (fileSize != soundBinary.length) {
        developer.log(
          '[AUDIO_PLAY] ⚠ WARNING: Size mismatch! Expected: ${soundBinary.length}, Got: $fileSize',
        );
      }

      developer.log('[AUDIO_PLAY] Waiting 100ms for file stability...');
      await Future.delayed(const Duration(milliseconds: 100));

      developer.log('[AUDIO_PLAY] Creating DeviceFileSource...');
      final source = DeviceFileSource(tempFile.path);
      developer.log('[AUDIO_PLAY] ✓ Source created: $source');

      developer.log('[AUDIO_PLAY] Initiating playback...');
      try {
        await _audioPlayer.play(source);
        developer.log('[AUDIO_PLAY] ✓✓✓ PLAYBACK INITIATED SUCCESSFULLY ✓✓✓');
        developer.log('[AUDIO_PLAY] ===== PLAYBACK END (SUCCESS) =====');
      } catch (playError) {
        developer.log(
          '[AUDIO_PLAY] ✗ First playback attempt failed: $playError',
          error: playError,
        );

        developer.log('[AUDIO_PLAY] Waiting 300ms and retrying...');
        await Future.delayed(const Duration(milliseconds: 300));
        try {
          developer.log('[AUDIO_PLAY] Retry attempt: calling play again...');
          await _audioPlayer.play(source);
          developer.log('[AUDIO_PLAY] ✓ Playback succeeded on retry');
          developer.log(
            '[AUDIO_PLAY] ===== PLAYBACK END (RETRY SUCCESS) =====',
          );
        } catch (retryError) {
          developer.log(
            '[AUDIO_PLAY] ✗✗✗ RETRY FAILED: $retryError',
            error: retryError,
            stackTrace: StackTrace.current,
          );
          developer.log('[AUDIO_PLAY] ===== PLAYBACK END (RETRY FAILED) =====');
          rethrow;
        }
      }
    } catch (e) {
      developer.log(
        '[AUDIO_PLAY] ✗✗✗ FATAL ERROR: $e',
        error: e,
        stackTrace: StackTrace.current,
      );
      developer.log('[AUDIO_PLAY] ===== PLAYBACK END (FATAL ERROR) =====');
      _cleanupTempFile();
      rethrow;
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _cleanupTempFile();
    _onPlaybackComplete?.call();
    developer.log('Audio playback stopped and cleaned up.');
  }

  void _scheduleCleanup() {
    Future.delayed(const Duration(seconds: 5), () {
      _cleanupTempFile();
    });
  }

  void _cleanupTempFile() {
    try {
      if (_currentTempFile != null && _currentTempFile!.existsSync()) {
        _currentTempFile!.deleteSync();
        developer.log('Cleaned up temporary file: ${_currentTempFile!.path}');
      }
    } catch (e) {
      developer.log('Error deleting temp file: $e');
    }
    _currentTempFile = null;
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _audioPlayer.setVolume(volume);
  }

  double get volume => _volume;

  Future<Duration?> getDuration() async {
    try {
      return await _audioPlayer.getDuration();
    } catch (e) {
      developer.log('Error getting audio duration: $e', error: e);
      return null;
    }
  }

  Future<void> dispose() async {
    _cleanupTempFile();
    await _audioPlayer.dispose();
  }
}

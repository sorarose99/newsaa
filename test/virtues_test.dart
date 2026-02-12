import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VirtuesPage', () {
    test('_extractYouTubeVideoId extracts video ID from valid YouTube URLs',
        () {
      // Test with a standard YouTube URL
      const standardUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      const videoId = 'dQw4w9WgXcQ';
      final extractedId1 = _extractYouTubeVideoId(standardUrl);
      expect(extractedId1, videoId);

      // Test with a shortened YouTube URL
      const shortenedUrl = 'https://youtu.be/dQw4w9WgXcQ';
      final extractedId2 = _extractYouTubeVideoId(shortenedUrl);
      expect(extractedId2, videoId);

      // Test with a URL that has additional query parameters
      const urlWithParams =
          'https://www.youtube.com/watch?v=dQw4w9WgXcQ&feature=share';
      final extractedId3 = _extractYouTubeVideoId(urlWithParams);
      expect(extractedId3, videoId);
    });

    test('_extractYouTubeVideoId returns null for invalid YouTube URLs', () {
      // Test with a non-YouTube URL
      const nonYouTubeUrl = 'https://www.google.com';
      final extractedId1 = _extractYouTubeVideoId(nonYouTubeUrl);
      expect(extractedId1, isNull);

      // Test with a malformed YouTube URL
      const malformedUrl = 'https://www.youtube.com/watch?v=';
      final extractedId2 = _extractYouTubeVideoId(malformedUrl);
      expect(extractedId2, isNull);

      // Test with a URL that has no video ID
      const noVideoIdUrl = 'https://www.youtube.com/';
      final extractedId3 = _extractYouTubeVideoId(noVideoIdUrl);
      expect(extractedId3, isNull);
    });
  });
}

String? _extractYouTubeVideoId(String url) {
  try {
    final uri = Uri.parse(url);

    if (uri.host.contains('youtube.com')) {
      final videoId = uri.queryParameters['v'];
      if (videoId != null && videoId.isNotEmpty) {
        return videoId;
      }
    } else if (uri.host.contains('youtu.be')) {
      final path = uri.path.replaceFirst('/', '');
      if (path.isNotEmpty) {
        return path;
      }
    }
  } catch (e) {
    // Error parsing URL, return null
  }
  return null;
}

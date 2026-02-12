import 'package:drift/drift.dart' as drift;

import 'package:alslat_aalnabi/features/quran/database/bookmark_db/bookmark_database.dart';

class DbBookmarkHelper {
  /// -------[BookmarkPage]--------
  static Future<int?> addBookmark(BookmarksCompanion bookmark) async {
    print('Save Text Bookmarks');
    final db = BookmarkDatabase(); // قم بتهيئة قاعدة البيانات
    try {
      return await db.into(db.bookmarks).insert(bookmark);
    } catch (e) {
      print('Error adding bookmark: $e');
      return 90000;
    }
  }

  /// -------[BookmarkAyah]--------

  static Future<int?> addBookmarkText(
    BookmarksAyahsCompanion bookmarkText,
  ) async {
    print('Save Text Bookmarks');
    final db = BookmarkDatabase(); // قم بتهيئة قاعدة البيانات
    try {
      return await db.into(db.bookmarksAyahs).insert(bookmarkText);
    } catch (e) {
      print('Error adding bookmark: $e');
      return 90000;
    }
  }

  static Future<int> deleteBookmark(Bookmark bookmark) async {
    print('Delete Text Bookmarks');
    final db = BookmarkDatabase();

    try {
      return await (db.delete(
        db.bookmarks,
      )..where((t) => t.id.equals(bookmark.id))).go();
    } catch (e) {
      print('Error deleting bookmark: $e');
      return 0;
    }
  }

  static Future<int> deleteBookmarkText(BookmarksAyah bookmarkText) async {
    print('Delete Text Bookmarks');
    final db = BookmarkDatabase();

    try {
      return await (db.delete(
        db.bookmarksAyahs,
      )..where((t) => t.id.equals(bookmarkText.id))).go();
    } catch (e) {
      print('Error deleting bookmark: $e');
      return 0;
    }
  }

  static Future<List<Bookmark>> queryB() async {
    final db = BookmarkDatabase();

    // استرجاع العلامات المرجعية من قاعدة البيانات
    return await db.getBookmarks();
  }

  static Future<List<BookmarksAyah>> queryT() async {
    print('Get Text Bookmarks');
    final db = BookmarkDatabase();
    return await db.getAllBookmarkAyahs();
  }

  static Future<int> updateBookmarks(Bookmark bookmark) async {
    final db = BookmarkDatabase();

    // استخدام BookmarksCompanion للتحديث
    return await db.updateBookmark(
      BookmarksCompanion(
        sorahName: drift.Value(bookmark.sorahName), // تمرير القيم الصحيحة
        pageNum: drift.Value(bookmark.pageNum), // تمرير القيم الصحيحة
        lastRead: drift.Value(bookmark.lastRead), // تمرير القيم الصحيحة
      ),
      bookmark.id, // تمرير معرف العلامة المرجعية (ID)
    );
  }

  static Future<int> updateBookmarksText(BookmarksAyah bookmarkText) async {
    print('Update Text Bookmarks');
    final db = BookmarkDatabase();
    return await db.updateBookmarkAyah(
      BookmarksAyahsCompanion(
        surahName: drift.Value(bookmarkText.surahName),
        surahNumber: drift.Value(bookmarkText.surahNumber),
        pageNumber: drift.Value(bookmarkText.pageNumber),
        ayahNumber: drift.Value(bookmarkText.ayahNumber),
        ayahUQNumber: drift.Value(bookmarkText.ayahUQNumber),
        lastRead: drift.Value(bookmarkText.lastRead),
      ),
      bookmarkText.id,
    );
  }
}

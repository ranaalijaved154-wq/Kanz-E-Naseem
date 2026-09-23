import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz_e_naseem/constants/app_constants.dart';
import 'package:kanz_e_naseem/services/content_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Kanz-e-Naseem Assets Verification Tests', () {
    test('Verify all 5 books exist in assets/books/ and are non-empty', () {
      final expectedBooks = [
        'assets/books/adab_e_suhbat_e_shaikh.pdf',
        'assets/books/sarmast_e_soot_e_sarmadi.pdf',
        'assets/books/lamaat_e_noor_ul_qudas.pdf',
        'assets/books/man_keh_faqiram_ya_ali.pdf',
        'assets/books/naqsh_e_sabr.pdf',
      ];

      for (final bookPath in expectedBooks) {
        final file = File(bookPath);
        expect(file.existsSync(), isTrue, reason: 'Missing book: $bookPath');
        expect(file.lengthSync(), greaterThan(10000), reason: 'Book file too small: $bookPath');
      }
    });

    test('Verify all 5 book covers exist in assets/book_covers/ and are non-empty', () {
      final expectedCovers = [
        'assets/book_covers/adab_e_suhbat_e_shaikh.png',
        'assets/book_covers/soot_e_sarmadi.png',
        'assets/book_covers/lamaat_e_noor_ul_qudas.png',
        'assets/book_covers/man_keh_faqiram_ya_ali.png',
        'assets/book_covers/naqsh_e_sabr.png',
      ];

      for (final coverPath in expectedCovers) {
        final file = File(coverPath);
        expect(file.existsSync(), isTrue, reason: 'Missing cover: $coverPath');
        expect(file.lengthSync(), greaterThan(5000), reason: 'Cover file too small: $coverPath');
      }
    });

    test('Verify all 9 Sarkar G gallery photos exist in assets/gallery/', () {
      for (int i = 1; i <= 9; i++) {
        final path = 'assets/gallery/sarkar_g_${i.toString().padLeft(2, '0')}.jpg';
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'Missing gallery image: $path');
        expect(file.lengthSync(), greaterThan(10000), reason: 'Gallery image too small: $path');
      }
    });

    test('ContentService preloads match actual assets', () {
      final service = ContentService();
      final books = service.localBooks;

      expect(books.length, equals(5));
      for (final b in books) {
        expect(File(b.coverUrl).existsSync(), isTrue, reason: 'Cover missing for ${b.title}');
        expect(File(b.fileUrl).existsSync(), isTrue, reason: 'PDF missing for ${b.title}');
      }

      final memories = service.localMemories;
      expect(memories.length, equals(9));
      for (final m in memories) {
        expect(File(m.imageUrl).existsSync(), isTrue, reason: 'Photo missing for ${m.title}');
      }
    });
  });

  group('Security & Admin Restriction Tests', () {
    test('Only master admin email is recognized as master admin', () {
      expect(AppConstants.isMasterAdmin('ranaalijaved154@gmail.com'), isTrue);
      expect(AppConstants.isMasterAdmin('RANAALIJAVED154@GMAIL.COM'), isTrue);
      expect(AppConstants.isMasterAdmin('ranaalijaved154@gmail.com '), isTrue);
      expect(AppConstants.isMasterAdmin('user@example.com'), isFalse);
      expect(AppConstants.isMasterAdmin('admin@kanzenaseem.com'), isFalse);
      expect(AppConstants.isMasterAdmin(null), isFalse);
    });
  });
}

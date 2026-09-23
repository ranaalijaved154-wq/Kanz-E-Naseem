import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../constants/app_constants.dart';
import '../models/audio_model.dart';
import '../models/book_model.dart';
import '../models/memory_model.dart';

class ContentService {
  static final ContentService _instance = ContentService._internal();
  factory ContentService({FirebaseFirestore? firestore}) => _instance;

  ContentService._internal() {
    _initStreams();
  }

  bool get isFirebaseAvailable => Firebase.apps.isNotEmpty;
  FirebaseFirestore? get _firestore =>
      isFirebaseAvailable ? FirebaseFirestore.instance : null;

  // Initial Content Preloads (From Sarkar G Books Collection)
  final List<BookModel> _localBooks = [
    BookModel(
      id: 'book_01',
      title: 'آدابِ صحبتِ شیخ',
      description: 'شیخِ طریقت کے آداب و فیوضات پر مشتمل نادر و نایاب تصنیفِ مبارک',
      coverUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=600&q=80',
      fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      totalPages: 112,
      createdAt: DateTime(2026, 1, 1),
    ),
    BookModel(
      id: 'book_02',
      title: 'سرمستِ صوتِ سرمدی',
      description: 'عشق و معرفتِ الٰہیہ اور احوالِ باطنیہ کا بے مثال شاہکار',
      coverUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=600&q=80',
      fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      totalPages: 248,
      createdAt: DateTime(2026, 1, 2),
    ),
    BookModel(
      id: 'book_03',
      title: 'لماتِ نور القدس',
      description: 'اسرار و رموزِ طریقت اور انوارِ قدسیہ کے فیضان کا تذکرہ',
      coverUrl: 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?auto=format&fit=crop&w=600&q=80',
      fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      totalPages: 160,
      createdAt: DateTime(2026, 1, 3),
    ),
    BookModel(
      id: 'book_04',
      title: 'مَن کہ فقیرم یا علیؑ',
      description: 'بارگاہِ ولایت میں عاجزانہ نذرانہ اور مدحتِ مولا علیؑ',
      coverUrl: 'https://images.unsplash.com/photo-1532012164546-f432f2e3777a?auto=format&fit=crop&w=600&q=80',
      fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      totalPages: 48,
      createdAt: DateTime(2026, 1, 4),
    ),
    BookModel(
      id: 'book_05',
      title: 'نقشِ صابرؒ',
      description: 'سوانح و تعلیماتِ حضرت مخدوم علی احمد صابر کلیریؒ',
      coverUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&w=600&q=80',
      fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      totalPages: 180,
      createdAt: DateTime(2026, 1, 5),
    ),
  ];

  final List<AudioModel> _localAudios = [
    AudioModel(
      id: 'audio_01',
      title: 'بیانِ مبارک: عظمتِ شیخ و معرفتِ باطن',
      topic: 'ملفوظات شریف',
      duration: '38:15',
      fileUrl: 'https://actions.google.com/sounds/v1/ambiences/outdoor_evening.ogg',
      createdAt: DateTime(2026, 1, 1),
    ),
    AudioModel(
      id: 'audio_02',
      title: 'کلامِ پاک و نعتِ رسولِ مقبول ﷺ',
      topic: 'نعت و منقبت',
      duration: '12:40',
      fileUrl: 'https://actions.google.com/sounds/v1/ambiences/water_lapping.ogg',
      createdAt: DateTime(2026, 1, 2),
    ),
    AudioModel(
      id: 'audio_03',
      title: 'ذکرِ الٰہی و مراقبہ باطنیہ',
      topic: 'ذکر و تسبیحات',
      duration: '25:30',
      fileUrl: 'https://actions.google.com/sounds/v1/ambiences/rain_heavy.ogg',
      createdAt: DateTime(2026, 1, 3),
    ),
  ];

  final List<MemoryModel> _localMemories = [
    MemoryModel(
      id: 'mem_01',
      title: 'مبارک زیارت و محفلِ سماع',
      description: 'حضور قبلہ سرکار جیؒ کی زیارتِ با برکت اور روحانی مجالس کی یادگار تصاویر',
      imageUrl: 'https://images.unsplash.com/photo-1564769625905-50e93615e769?auto=format&fit=crop&w=800&q=80',
      date: '1998',
      createdAt: DateTime(2026, 1, 1),
    ),
    MemoryModel(
      id: 'mem_02',
      title: 'مجلسِ ذکر و فیضِ صحبت',
      description: 'مبارک لمحات اور دربارِ عالیہ کے روح پرور مناظر',
      imageUrl: 'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?auto=format&fit=crop&w=800&q=80',
      date: '2004',
      createdAt: DateTime(2026, 1, 2),
    ),
    MemoryModel(
      id: 'mem_03',
      title: 'قدیم قلمی نوادرات و تبرکات',
      description: 'مبارک قلمی تحریرات اور دربارِ اقدس کے تبرکات',
      imageUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?auto=format&fit=crop&w=800&q=80',
      date: '1985',
      createdAt: DateTime(2026, 1, 3),
    ),
  ];

  final StreamController<List<BookModel>> _booksController =
      StreamController<List<BookModel>>.broadcast();
  final StreamController<List<AudioModel>> _audiosController =
      StreamController<List<AudioModel>>.broadcast();
  final StreamController<List<MemoryModel>> _memoriesController =
      StreamController<List<MemoryModel>>.broadcast();

  void _initStreams() {
    _emitBooks();
    _emitAudios();
    _emitMemories();
  }

  void _emitBooks() => _booksController.add(List.unmodifiable(_localBooks));
  void _emitAudios() => _audiosController.add(List.unmodifiable(_localAudios));
  void _emitMemories() => _memoriesController.add(List.unmodifiable(_localMemories));

  // -------------------------------------------------------------
  // KUTUB (BOOKS)
  // -------------------------------------------------------------

  Stream<List<BookModel>> streamBooks() {
    if (isFirebaseAvailable && _firestore != null) {
      return _firestore!
          .collection(AppConstants.booksCollection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            final docs = snapshot.docs.map((doc) => BookModel.fromDocument(doc)).toList();
            if (docs.isEmpty) return _localBooks;
            return docs;
          })
          .handleError((_) => _localBooks);
    }

    _emitBooks();
    return _booksController.stream;
  }

  Future<String> addBook(BookModel book) async {
    final String id = book.id.isNotEmpty
        ? book.id
        : 'book_${DateTime.now().millisecondsSinceEpoch}';
    final newBook = book.copyWith(id: id);

    _localBooks.insert(0, newBook);
    _emitBooks();

    if (isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection(AppConstants.booksCollection).doc(id).set(newBook.toMap());
      } catch (_) {}
    }
    return id;
  }

  Future<void> deleteBook(String id) async {
    _localBooks.removeWhere((b) => b.id == id);
    _emitBooks();

    if (isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection(AppConstants.booksCollection).doc(id).delete();
      } catch (_) {}
    }
  }

  // -------------------------------------------------------------
  // SOUT O BAYAN (AUDIOS)
  // -------------------------------------------------------------

  Stream<List<AudioModel>> streamAudios() {
    if (isFirebaseAvailable && _firestore != null) {
      return _firestore!
          .collection(AppConstants.audiosCollection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            final docs = snapshot.docs.map((doc) => AudioModel.fromDocument(doc)).toList();
            if (docs.isEmpty) return _localAudios;
            return docs;
          })
          .handleError((_) => _localAudios);
    }

    _emitAudios();
    return _audiosController.stream;
  }

  Future<String> addAudio(AudioModel audio) async {
    final String id = audio.id.isNotEmpty
        ? audio.id
        : 'audio_${DateTime.now().millisecondsSinceEpoch}';
    final newAudio = audio.copyWith(id: id);

    _localAudios.insert(0, newAudio);
    _emitAudios();

    if (isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection(AppConstants.audiosCollection).doc(id).set(newAudio.toMap());
      } catch (_) {}
    }
    return id;
  }

  Future<void> deleteAudio(String id) async {
    _localAudios.removeWhere((a) => a.id == id);
    _emitAudios();

    if (isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection(AppConstants.audiosCollection).doc(id).delete();
      } catch (_) {}
    }
  }

  // -------------------------------------------------------------
  // YADAIN O SAWANEH (MEMORIES)
  // -------------------------------------------------------------

  Stream<List<MemoryModel>> streamMemories() {
    if (isFirebaseAvailable && _firestore != null) {
      return _firestore!
          .collection(AppConstants.memoriesCollection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            final docs = snapshot.docs.map((doc) => MemoryModel.fromDocument(doc)).toList();
            if (docs.isEmpty) return _localMemories;
            return docs;
          })
          .handleError((_) => _localMemories);
    }

    _emitMemories();
    return _memoriesController.stream;
  }

  Future<String> addMemory(MemoryModel memory) async {
    final String id = memory.id.isNotEmpty
        ? memory.id
        : 'mem_${DateTime.now().millisecondsSinceEpoch}';
    final newMemory = memory.copyWith(id: id);

    _localMemories.insert(0, newMemory);
    _emitMemories();

    if (isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection(AppConstants.memoriesCollection).doc(id).set(newMemory.toMap());
      } catch (_) {}
    }
    return id;
  }

  Future<void> deleteMemory(String id) async {
    _localMemories.removeWhere((m) => m.id == id);
    _emitMemories();

    if (isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection(AppConstants.memoriesCollection).doc(id).delete();
      } catch (_) {}
    }
  }
}

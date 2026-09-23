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

  List<BookModel> get localBooks => List.unmodifiable(_localBooks);
  List<AudioModel> get localAudios => List.unmodifiable(_localAudios);
  List<MemoryModel> get localMemories => List.unmodifiable(_localMemories);

  final List<BookModel> _localBooks = [
    BookModel(
      id: 'book_01',
      title: 'آدابِ صحبتِ شیخ',
      description: 'شیخِ طریقت کے آداب و فیوضات پر مشتمل نادر و نایاب تصنیفِ مبارک',
      coverUrl: 'assets/book_covers/adab_e_suhbat_e_shaikh.png',
      fileUrl: 'assets/books/adab_e_suhbat_e_shaikh.pdf',
      totalPages: 113,
      createdAt: DateTime(2026, 1, 1),
    ),
    BookModel(
      id: 'book_02',
      title: 'سرمستِ صوتِ سرمدی',
      description: 'عشق و معرفتِ الٰہیہ اور احوالِ باطنیہ کا بے مثال شاہکار (اُردو صوفیانہ کلام مع تشریحات)',
      coverUrl: 'assets/book_covers/soot_e_sarmadi.png',
      fileUrl: 'assets/books/sarmast_e_soot_e_sarmadi.pdf',
      totalPages: 160,
      createdAt: DateTime(2026, 1, 2),
    ),
    BookModel(
      id: 'book_03',
      title: 'لماتِ نور القدس',
      description: 'اسرار و رموزِ طریقت اور انوارِ قدسیہ کے فیضان کا تذکرہ (حمد، نعت اور مناقب)',
      coverUrl: 'assets/book_covers/lamaat_e_noor_ul_qudas.png',
      fileUrl: 'assets/books/lamaat_e_noor_ul_qudas.pdf',
      totalPages: 113,
      createdAt: DateTime(2026, 1, 3),
    ),
    BookModel(
      id: 'book_04',
      title: 'مَن کہ فقیرم یا علیؑ',
      description: 'بارگاہِ ولایت میں عاجزانہ نذرانہ اور مدحتِ مولا علیؑ (ترتیب و تدوین: صوفی نسیم احمد)',
      coverUrl: 'assets/book_covers/man_keh_faqiram_ya_ali.png',
      fileUrl: 'assets/books/man_keh_faqiram_ya_ali.pdf',
      totalPages: 33,
      createdAt: DateTime(2026, 1, 4),
    ),
    BookModel(
      id: 'book_05',
      title: 'نقشِ صابرؒ',
      description: 'سوانح و تعلیماتِ حضرت مخدوم علی احمد صابر کلیریؒ اور اولیاءِ کرام کے احوال',
      coverUrl: 'assets/book_covers/naqsh_e_sabr.png',
      fileUrl: 'assets/books/naqsh_e_sabr.pdf',
      totalPages: 289,
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
      title: 'مبارک یادگار و محافلِ نور',
      description: 'حضور قبلہ سرکار جیؒ کی حیاتِ مبارکہ، روحانی مجالس اور جلوہ افروزی کے نادر و تاریخی مناظر کا مرقع',
      imageUrl: 'assets/gallery/sarkar_g_01.jpg',
      date: 'تاریخی مرقع',
      createdAt: DateTime(2026, 1, 1),
    ),
    MemoryModel(
      id: 'mem_02',
      title: 'زیارتِ با برکت حضور سرکار جیؒ',
      description: 'سیدنا حضور قبلہ سرکار جی دامت برکاتہم العالیہ کا پرنور و پروقار چہرہ مبارک',
      imageUrl: 'assets/gallery/sarkar_g_02.jpg',
      date: 'مبارک پورٹریٹ',
      createdAt: DateTime(2026, 1, 2),
    ),
    MemoryModel(
      id: 'mem_03',
      title: 'محفلِ انوار و جلوۂ پاک',
      description: 'صحنِ چمن میں جلوہ افروز قبلہ سرکار جیؒ کا پرکیف و روحانی انداز',
      imageUrl: 'assets/gallery/sarkar_g_03.jpg',
      date: 'روحانی جلوہ',
      createdAt: DateTime(2026, 1, 3),
    ),
    MemoryModel(
      id: 'mem_04',
      title: 'سیادت و فضل و کمال',
      description: 'حضور سرکار جیؒ کا نورانی و با برکت سراپا، منبعِ تسکین و معرفت',
      imageUrl: 'assets/gallery/sarkar_g_04.jpg',
      date: 'مبارک زیارت',
      createdAt: DateTime(2026, 1, 4),
    ),
    MemoryModel(
      id: 'mem_05',
      title: 'محفلِ شب و نورِ صحبت',
      description: 'روح پرور محفلِ ذکر و سماع میں قبلہ سرکار جیؒ کی با برکت مجلس',
      imageUrl: 'assets/gallery/sarkar_g_05.jpg',
      date: 'شبِ نور',
      createdAt: DateTime(2026, 1, 5),
    ),
    MemoryModel(
      id: 'mem_06',
      title: 'عقیدت مندان کے ہمراہ مبارک مجلس',
      description: 'حضور قبلہ سرکار جیؒ غلامان و مریدینِ باوفا کو شفقت و فیض سے نوازتے ہوئے',
      imageUrl: 'assets/gallery/sarkar_g_06.jpg',
      date: 'محفلِ شفقت',
      createdAt: DateTime(2026, 1, 6),
    ),
    MemoryModel(
      id: 'mem_07',
      title: 'مجلسِ دربارِ عالیہ و خدام',
      description: 'دربارِ عالیہ پر نیاز مندوں اور خدام کے جھرمٹ میں قبلہ سرکار جیؒ کی بابرکت نشست',
      imageUrl: 'assets/gallery/sarkar_g_07.jpg',
      date: 'فیضانِ صحبت',
      createdAt: DateTime(2026, 1, 7),
    ),
    MemoryModel(
      id: 'mem_08',
      title: 'نگاہِ ولایت و تسکینِ باطن',
      description: 'حضور قبلہ سرکار جیؒ کی پرتاثیر نگاہِ فیض اور شفقت کا روح پرور عکس',
      imageUrl: 'assets/gallery/sarkar_g_08.jpg',
      date: 'نگاہِ کرم',
      createdAt: DateTime(2026, 1, 8),
    ),
    MemoryModel(
      id: 'mem_09',
      title: 'بزمِ کلام و ارشادِ عالیہ',
      description: 'حضور قبلہ سرکار جیؒ اپنے مبارک ارشادات و نصائح سے قلوب کو منور فرماتے ہوئے',
      imageUrl: 'assets/gallery/sarkar_g_09.jpg',
      date: 'ارشاداتِ عالیہ',
      createdAt: DateTime(2026, 1, 9),
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

  Stream<List<BookModel>> streamBooks() async* {
    yield List<BookModel>.unmodifiable(_localBooks);

    if (isFirebaseAvailable && _firestore != null) {
      try {
        final stream = _firestore!
            .collection(AppConstants.booksCollection)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map<List<BookModel>>((snapshot) {
              final docs = snapshot.docs.map((doc) => BookModel.fromDocument(doc)).toList();
              return docs.isEmpty ? List<BookModel>.unmodifiable(_localBooks) : docs;
            });

        await for (final books in stream) {
          yield books;
        }
      } catch (_) {
        yield List<BookModel>.unmodifiable(_localBooks);
      }
    } else {
      yield* _booksController.stream;
    }
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

  Stream<List<AudioModel>> streamAudios() async* {
    yield List<AudioModel>.unmodifiable(_localAudios);

    if (isFirebaseAvailable && _firestore != null) {
      try {
        final stream = _firestore!
            .collection(AppConstants.audiosCollection)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map<List<AudioModel>>((snapshot) {
              final docs = snapshot.docs.map((doc) => AudioModel.fromDocument(doc)).toList();
              return docs.isEmpty ? List<AudioModel>.unmodifiable(_localAudios) : docs;
            });

        await for (final audios in stream) {
          yield audios;
        }
      } catch (_) {
        yield List<AudioModel>.unmodifiable(_localAudios);
      }
    } else {
      yield* _audiosController.stream;
    }
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

  Stream<List<MemoryModel>> streamMemories() async* {
    yield List<MemoryModel>.unmodifiable(_localMemories);

    if (isFirebaseAvailable && _firestore != null) {
      try {
        final stream = _firestore!
            .collection(AppConstants.memoriesCollection)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map<List<MemoryModel>>((snapshot) {
              final docs = snapshot.docs.map((doc) => MemoryModel.fromDocument(doc)).toList();
              return docs.isEmpty ? List<MemoryModel>.unmodifiable(_localMemories) : docs;
            });

        await for (final memories in stream) {
          yield memories;
        }
      } catch (_) {
        yield List<MemoryModel>.unmodifiable(_localMemories);
      }
    } else {
      yield* _memoriesController.stream;
    }
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
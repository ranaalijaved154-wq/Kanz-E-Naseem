import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/audio_model.dart';
import '../models/book_model.dart';
import '../models/memory_model.dart';

class ContentService {
  final FirebaseFirestore _firestore;

  ContentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // -------------------------------------------------------------
  // KUTUB (BOOKS)
  // -------------------------------------------------------------

  /// Stream of all Books ordered by creation time descending
  Stream<List<BookModel>> streamBooks() {
    return _firestore
        .collection(AppConstants.booksCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BookModel.fromDocument(doc)).toList());
  }

  /// Add a new Book
  Future<String> addBook(BookModel book) async {
    final docRef = await _firestore
        .collection(AppConstants.booksCollection)
        .add(book.toMap());
    return docRef.id;
  }

  /// Delete a Book
  Future<void> deleteBook(String id) async {
    await _firestore.collection(AppConstants.booksCollection).doc(id).delete();
  }

  // -------------------------------------------------------------
  // SOUT O BAYAN (AUDIOS)
  // -------------------------------------------------------------

  /// Stream of all Audios ordered by creation time descending
  Stream<List<AudioModel>> streamAudios() {
    return _firestore
        .collection(AppConstants.audiosCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AudioModel.fromDocument(doc)).toList());
  }

  /// Add a new Audio recording
  Future<String> addAudio(AudioModel audio) async {
    final docRef = await _firestore
        .collection(AppConstants.audiosCollection)
        .add(audio.toMap());
    return docRef.id;
  }

  /// Delete an Audio recording
  Future<void> deleteAudio(String id) async {
    await _firestore.collection(AppConstants.audiosCollection).doc(id).delete();
  }

  // -------------------------------------------------------------
  // YADAIN O SAWANEH (MEMORIES)
  // -------------------------------------------------------------

  /// Stream of all historical memories
  Stream<List<MemoryModel>> streamMemories() {
    return _firestore
        .collection(AppConstants.memoriesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MemoryModel.fromDocument(doc)).toList());
  }

  /// Add a new Memory
  Future<String> addMemory(MemoryModel memory) async {
    final docRef = await _firestore
        .collection(AppConstants.memoriesCollection)
        .add(memory.toMap());
    return docRef.id;
  }

  /// Delete a Memory
  Future<void> deleteMemory(String id) async {
    await _firestore
        .collection(AppConstants.memoriesCollection)
        .doc(id)
        .delete();
  }
}

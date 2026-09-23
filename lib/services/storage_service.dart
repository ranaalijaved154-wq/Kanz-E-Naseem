import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Pick an image file (for book covers or historical memories)
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// Pick a PDF document
  Future<FilePickerResult?> pickPdf() async {
    return await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
  }

  /// Pick an Audio file (mp3, wav, m4a, aac)
  Future<FilePickerResult?> pickAudio() async {
    return await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac'],
    );
  }

  /// Upload a file to Firebase Storage with a real-time progress callback
  /// [folder] e.g. "books", "audios", "memories", "covers"
  /// [fileName] unique name for the file
  /// [file] local File object
  /// [onProgress] callback receiving double from 0.0 to 1.0
  Future<String> uploadFile({
    required String folder,
    required String fileName,
    required File file,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child('$folder/$fileName');
      final uploadTask = ref.putFile(file);

      // Listen for progress updates
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes > 0) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          if (onProgress != null) {
            onProgress(progress);
          }
        }
      });

      // Await completion and retrieve download URL
      final TaskSnapshot completedSnapshot = await uploadTask;
      final downloadUrl = await completedSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('StorageService upload error: $e');
      throw Exception('فائل اپلوڈ کرنے میں خرابی پیش آئی: $e');
    }
  }

  /// Upload raw bytes (useful for web or memory data)
  Future<String> uploadBytes({
    required String folder,
    required String fileName,
    required Uint8List bytes,
    String? mimeType,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child('$folder/$fileName');
      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: mimeType),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes > 0) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          if (onProgress != null) {
            onProgress(progress);
          }
        }
      });

      final TaskSnapshot completedSnapshot = await uploadTask;
      final downloadUrl = await completedSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('StorageService uploadBytes error: $e');
      throw Exception('فائل اپلوڈ کرنے میں خرابی پیش آئی: $e');
    }
  }

  /// Delete a file by download URL
  Future<void> deleteFileByUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('Could not delete storage file: $e');
    }
  }
}

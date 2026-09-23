import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String id;
  final String title;
  final String description;
  final String coverUrl;
  final String fileUrl;
  final int totalPages;
  final DateTime? createdAt;

  BookModel({
    required this.id,
    required this.title,
    required this.description,
    required this.coverUrl,
    required this.fileUrl,
    required this.totalPages,
    this.createdAt,
  });

  factory BookModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parsedCreatedAt;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(map['createdAt']);
      }
    }

    return BookModel(
      id: id,
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      coverUrl: (map['coverUrl'] ?? '').toString(),
      fileUrl: (map['fileUrl'] ?? '').toString(),
      totalPages: (map['totalPages'] as num?)?.toInt() ?? 0,
      createdAt: parsedCreatedAt,
    );
  }

  factory BookModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BookModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'coverUrl': coverUrl,
      'fileUrl': fileUrl,
      'totalPages': totalPages,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? description,
    String? coverUrl,
    String? fileUrl,
    int? totalPages,
    DateTime? createdAt,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      totalPages: totalPages ?? this.totalPages,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

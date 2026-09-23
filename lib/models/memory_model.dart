import 'package:cloud_firestore/cloud_firestore.dart';

class MemoryModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String date;
  final DateTime? createdAt;

  MemoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    this.createdAt,
  });

  factory MemoryModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parsedCreatedAt;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(map['createdAt']);
      }
    }

    return MemoryModel(
      id: id,
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      date: (map['date'] ?? '').toString(),
      createdAt: parsedCreatedAt,
    );
  }

  factory MemoryModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MemoryModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'date': date,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  MemoryModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? date,
    DateTime? createdAt,
  }) {
    return MemoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

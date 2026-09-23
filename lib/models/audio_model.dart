import 'package:cloud_firestore/cloud_firestore.dart';

class AudioModel {
  final String id;
  final String title;
  final String topic;
  final String duration;
  final String fileUrl;
  final DateTime? createdAt;

  AudioModel({
    required this.id,
    required this.title,
    required this.topic,
    required this.duration,
    required this.fileUrl,
    this.createdAt,
  });

  factory AudioModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parsedCreatedAt;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(map['createdAt']);
      }
    }

    return AudioModel(
      id: id,
      title: (map['title'] ?? '').toString(),
      topic: (map['topic'] ?? 'ملفوظات شریف').toString(),
      duration: (map['duration'] ?? '00:00').toString(),
      fileUrl: (map['fileUrl'] ?? '').toString(),
      createdAt: parsedCreatedAt,
    );
  }

  factory AudioModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AudioModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'topic': topic,
      'duration': duration,
      'fileUrl': fileUrl,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  AudioModel copyWith({
    String? id,
    String? title,
    String? topic,
    String? duration,
    String? fileUrl,
    DateTime? createdAt,
  }) {
    return AudioModel(
      id: id ?? this.id,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      duration: duration ?? this.duration,
      fileUrl: fileUrl ?? this.fileUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

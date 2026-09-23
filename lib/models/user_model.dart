import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool isApproved;
  final String status;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isApproved,
    required this.status,
    this.createdAt,
  });

  /// Factory constructor to parse from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    DateTime? parsedCreatedAt;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(map['createdAt']);
      }
    }

    final email = (map['email'] ?? '').toString().trim();
    final role = (map['role'] ?? AppConstants.roleUser).toString();
    final isApproved = (map['isApproved'] as bool?) ?? false;

    // Master admin automatically recognized
    final isMaster = AppConstants.isMasterAdmin(email);

    return UserModel(
      uid: uid,
      name: (map['name'] ?? '').toString(),
      email: email,
      role: isMaster ? AppConstants.roleAdmin : role,
      isApproved: isMaster ? true : isApproved,
      status: isMaster
          ? AppConstants.statusApproved
          : (map['status'] ?? AppConstants.statusPending).toString(),
      createdAt: parsedCreatedAt,
    );
  }

  /// Factory constructor from Firestore DocumentSnapshot
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, doc.id);
  }

  /// Convert model to Firestore Map representation
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'isApproved': isApproved,
      'status': status,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  /// Copy with modifications
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    bool? isApproved,
    String? status,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isApproved: isApproved ?? this.isApproved,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check whether this user has admin privileges
  bool get isAdmin =>
      role == AppConstants.roleAdmin || AppConstants.isMasterAdmin(email);

  /// Check if user has active approval to access content
  bool get hasAccess => isAdmin || isApproved == true;

  /// Check if user is currently pending approval
  bool get isPending => !hasAccess && status == AppConstants.statusPending;

  /// Check if user status is rejected
  bool get isRejected => status == AppConstants.statusRejected;
}

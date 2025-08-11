import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String status;
  final bool isOnline;
  final DateTime lastActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.status,
    required this.isOnline,
    required this.lastActive,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      id: documentId,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      role: map['userType'] ?? '',
      status: map['status'] ?? '',
      isOnline: map['isOnline'] ?? false,
      lastActive: (map['lastSeen'] is Timestamp)
          ? (map['lastSeen'] as Timestamp).toDate()
          : DateTime.tryParse(map['lastSeen'] ?? '') ?? DateTime.now(),
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'userType': role,
      'status': status,
      'isOnline': isOnline,
      'lastSeen': lastActive,
      'createdAt': createdAt,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsModel {
  FriendsModel({
    required this.user1id,
    required this.user1role,
    required this.user2id,
    required this.user2role,
  });

  final String user1id;
  final String user1role;
  final String user2id;
  final String user2role;

  factory FriendsModel.fromJson(Map<String, dynamic> _json) {
    return FriendsModel(
      user1id: _json['user1id'],
      user1role: _json['user1role'],
      user2id: _json['user2id'],
      user2role: _json['user2role'],
    );
  }
}

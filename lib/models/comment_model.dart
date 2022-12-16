/*
Summary of File:
  This file contains codes which define the comment model and how the data are transformed with database.

*/
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  CommentModel(
      {required this.avatar,
      required this.username,
      required this.time,
      required this.comment});

  final String avatar;
  final String username;
  final DateTime time;
  final String comment;

  factory CommentModel.fromJson(Map<String, dynamic> _json) {
    return CommentModel(
        avatar: _json['avatar'],
        username: _json['username'],
        time: _json['time'].toDate(),
        comment: _json['comment']);
  }
  Map<String, dynamic> toJson() {
    return {
      'avatar': avatar,
      'username': username,
      'time': time,
      'comment': comment
    };
  }

  //This function is for test
  void output() {
    print('avatar:$avatar, username:$username, time:$time, comment:$comment');
  }
}

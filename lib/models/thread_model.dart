/*
Summary of File:
  This file contains codes which define the Thread model and how the data are transformed with database.
*/
import 'package:PACCPolicyapp/models/comment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThreadModel {
  ThreadModel({
    required this.id,
    required this.avatar,
    required this.username,
    required this.title,
    required this.likes,
    required this.views,
    required this.time,
    required this.body,
    required this.votedusers,
  });

  final String id;
  final String avatar;
  final String username;
  final String title;
  final views;
  final DateTime time;
  final likes;
  List<CommentModel>? comments;
  final String body;
  List<String> votedusers;

  void addComment(List<CommentModel> _comment) {
    comments = _comment;
  }

  //This function is for test
  void output() {
    print('Threads:');
    print(
        'id:$id, avatar:$avatar, username:$username, title:$title, likes:$likes, views:$views, time:$time, body:$body');
    print('comment');
    if (comments != null) {
      for (var i = 0; i < comments!.length; i++) {
        comments![i].output();
      }
    }
  }
}

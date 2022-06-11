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

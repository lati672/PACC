import 'dart:async';

// Packages
import 'package:PACCPolicyapp/models/comment_model.dart';
import 'package:PACCPolicyapp/models/thread_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Services
import '../services/database_service.dart';

// Providers
import '../providers/authentication_provider.dart';

// Models

class CommentProvider extends ChangeNotifier {
  CommentProvider(this._auth, this._thread) {
    _database = GetIt.I.get<DatabaseService>();

    listenToComments();
  }
  final AuthenticationProvider _auth;
  final ThreadModel _thread; //thread without comment
  late DatabaseService _database;
  ThreadModel? thread; //thread with comment
  List<CommentModel>? comments;
  late StreamSubscription _commentStream;

// * Once not longer needed, it will be disposed
  @override
  void dispose() {
    super.dispose();
    _commentStream.cancel();
  }

  void listenToComments() async {
    try {
      //print('listing ${_database.getUser(_auth.user.uid)}');
      thread = _thread;
      _commentStream = _database.getCommentSnapshot(_thread.id).listen(
        (_snapshot) async {
          comments = await Future.wait(
            _snapshot.docs.map(
              (_eachDoc) async {
                final _commentdData = _eachDoc.data() as Map<String, dynamic>;

                return CommentModel(
                    avatar: _commentdData['avatar'],
                    username: _commentdData['username'],
                    time: _commentdData['time'].toDate(),
                    comment: _commentdData['comment']);
              },
            ).toList(),
          );
          if (comments != null) {
            thread!.addComment(comments!);
            notifyListeners();
          }
        },
      );
    } catch (error) {
      debugPrint('Error getting comments.');
      debugPrint('$error');
    }
  }

  void sendComment(String threadid, String comment) async {
    final _commentToAdd = CommentModel(
        avatar: _auth.user.imageUrl,
        username: _auth.user.name,
        time: DateTime.now(),
        comment: comment);
    await _database.addComment(threadid, _commentToAdd);
    notifyListeners();
  }

  void vote(String threadid) async {
    _database.upvote(_auth.user.uid, threadid);
  }
}

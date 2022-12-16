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

class ThreadsProvider extends ChangeNotifier {
  ThreadsProvider(this._auth) {
    _database = GetIt.I.get<DatabaseService>();
    listenToThreads();
  }
  final AuthenticationProvider _auth;
  late DatabaseService _database;

  List<ThreadModel>? threads;

  late StreamSubscription _threadsStream;

// * Once not longer needed, it will be disposed
  @override
  void dispose() {
    super.dispose();
    _threadsStream.cancel();
  }

  void listenToThreads() async {
    try {
      //print('listing ${_database.getUser(_auth.user.uid)}');
      _threadsStream = _database.getThreads().listen(
        (_snapshot) async {
          threads = await Future.wait(
            _snapshot.docs.map(
              (_eachDoc) async {
                final _threadData = _eachDoc.data() as Map<String, dynamic>;
                return ThreadModel(
                    id: _eachDoc.id,
                    avatar: _threadData['avatar'],
                    username: _threadData['username'],
                    title: _threadData['title'],
                    likes: _threadData['likes'],
                    views: _threadData['views'],
                    time: _threadData['time'].toDate(),
                    body: _threadData['body'],
                    votedusers: List.from(_threadData['votedUsers']));
              },
            ).toList(),
          );
          notifyListeners();
        },
      );
    } catch (error) {
      debugPrint('Error getting threads.');
      debugPrint('$error');
    }
  }

  void vote(String threadid) async {
    _database.upvote(_auth.user.uid, threadid);
    notifyListeners();
  }
}

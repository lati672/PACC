// Packages
import 'package:PACCPolicyapp/models/chats_model.dart';
import 'package:PACCPolicyapp/models/comment_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

// Models
import '../models/chat_message_model.dart';
import 'package:PACCPolicyapp/models/chat_user_model.dart';

const String userCollection = 'Users';
const String chatCollection = 'Chats';
const String messagesCollection = 'Messages';
const String threadsCollection = 'Threads';
const String commentCollection = 'Comments';

class DatabaseService {
  DatabaseService();
  final FirebaseFirestore _dataBase = FirebaseFirestore.instance;
  //#User
  // Create User
  Future<void> createUser(
      String _uid, String _email, String _name, String _imageUrl) async {
    try {
      // * Going to the collections (User) the to the user uid and overrides the values of the fields
      await _dataBase.collection(userCollection).doc(_uid).set(
        {
          'name': _name,
          'email': _email,
          'image': _imageUrl,
          'last_active': DateTime.now().toUtc(),
        },
      );
    } catch (error) {
      debugPrint('$error');
    }
  }

  // Getting the User from Firebase Cloud Store
  Future<DocumentSnapshot> getUser(String _uid) {
    return _dataBase.collection(userCollection).doc(_uid).get();
  }

  //get username by user id
  Future<String> getUserName(String _uid) async {
    DocumentSnapshot docshot =
        await _dataBase.collection(userCollection).doc(_uid).get();
    return docshot['name'];
  }

  //Getting all the Users
  Future<QuerySnapshot> getUsers() async {
    return _dataBase.collection(userCollection).get();
  }

  // Getting user by email
  Future<QuerySnapshot> getUserbyEmail(String _email) async {
    QuerySnapshot qshot = await _dataBase
        .collection(userCollection)
        .where('email', isEqualTo: _email)
        .get();
    return qshot;
  }

  //Getting user by name
  Future<QuerySnapshot> getUserbyName(String _name) async {
    QuerySnapshot qshot = await _dataBase
        .collection(userCollection)
        .where('name', isEqualTo: _name)
        .get();
    return qshot;
  }

  // Update time
  Future<void> updateUserLastSeenTime(String _uid) async {
    try {
      await _dataBase.collection(userCollection).doc(_uid).update(
        {
          'last_active': DateTime.now().toUtc(),
        },
      );
    } catch (e) {
      debugPrint('$e');
    }
  }

  //update user profile image
  Future<void> updataUserImage(String _uid, String _imageurl) async {
    try {
      await _dataBase.collection(userCollection).doc(_uid).update(
        {
          'image': _imageurl,
        },
      );
    } catch (e) {
      debugPrint('$e');
    }
  }

  //literally the function name
  Future<String> getRoleByID(String _uid) async {
    try {
      DocumentSnapshot qshot =
          await _dataBase.collection(userCollection).doc(_uid).get();
      return qshot['role'];
    } catch (error) {
      debugPrint('$error');
      throw ('error');
    }
  }

  //#Threads
  //Get all threads and ordered by time
  Stream<QuerySnapshot> getThreads() {
    try {
      return _dataBase
          .collection(threadsCollection)
          .orderBy('time', descending: true)
          .snapshots();
    } catch (error) {
      debugPrint('$error');
      throw ('error');
    }
  }

  //get thread by thread ID
  Future<DocumentSnapshot> getThread(String _threadid) {
    return _dataBase.collection(threadsCollection).doc(_threadid).get();
  }

  //get comment by threadID
  Stream<QuerySnapshot> getCommentSnapshot(String _threadsid) {
    try {
      return _dataBase
          .collection(threadsCollection)
          .doc(_threadsid)
          .collection(commentCollection)
          .orderBy('time', descending: false)
          .snapshots();
    } catch (error) {
      debugPrint('$error');
      throw ('error');
    }
  }

  //Comments
  Future<QuerySnapshot> getComments(String _threadsid) {
    return _dataBase
        .collection(threadsCollection)
        .doc(_threadsid)
        .collection(commentCollection)
        .orderBy('time', descending: false)
        .get();
  }

  //add a new comment to the thread
  Future<void> addComment(String _threadid, CommentModel _comment) async {
    try {
      await _dataBase
          .collection(threadsCollection)
          .doc(_threadid)
          .collection(commentCollection)
          .add(_comment.toJson());
    } catch (error) {
      debugPrint('$error');
      throw ('error');
    }
  }

  void upvote(String _uid, String _tid) {
    DocumentReference documentReference =
        _dataBase.collection(threadsCollection).doc(_tid);
    _dataBase.runTransaction((transaction) async {
      DocumentSnapshot docshot = await transaction.get(documentReference);
      int likeCount = docshot['likes'];
      if (docshot['votedUsers'].contains(_uid)) {
        transaction.update(documentReference, <String, dynamic>{
          'votedUsers': FieldValue.arrayRemove([_uid])
        });
        await transaction.update(documentReference, {'likes': likeCount - 1});
      } else {
        transaction.update(documentReference, <String, dynamic>{
          'votedUsers': FieldValue.arrayUnion([_uid])
        });
        await transaction.update(documentReference, {'likes': likeCount + 1});
      }
    });
  }
}

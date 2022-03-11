// Packages
import 'package:chatifyapp/models/chat_user_model.dart';
import 'package:chatifyapp/models/todo_list_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

// Models
import '../models/chat_message_model.dart';
import '../models/todo_list_model.dart';

const String userCollection = 'Users';
const String chatCollection = 'Chats';
const String messagesCollection = 'Messages';
const String whitelistCollection = 'Whitelist';
const String todolistCollection = 'Todolist';

class DatabaseService {
  DatabaseService();
  final FirebaseFirestore _dataBase = FirebaseFirestore.instance;

  // Create User
  Future<void> createUser(String _uid, String _email, String _name,
      String _imageUrl, String role) async {
    try {
      // print('Creating User');
      // * Going to the collections (User) the to the user uid and overrides the values of the fields
      await _dataBase.collection(userCollection).doc(_uid).set(
        {
          'name': _name,
          'email': _email,
          'image': _imageUrl,
          'role': role,
          'last_active': DateTime.now().toUtc(),
        },
      );
    } catch (error) {
      debugPrint('$error');
    }
  }

  Future<void> createChat(String _currentuserUid, bool _activity, bool _group,
      List<String> _members) async {
    try {
      await _dataBase.collection(chatCollection).add(
        {
          'currentUserUid': _currentuserUid,
          'is_activity': _activity,
          'is_group': _group,
          'members': _members,
        },
      ).then((docRef) => {addInitMessagesToChat(docRef.id, _currentuserUid)});
    } catch (error) {
      debugPrint('$error');
    }
  }

  Future<void> createwhitelist(String _from, String _to, List<String> _appname,
      List<bool> _check) async {
    try {
      await _dataBase
          .collection(userCollection)
          .doc(_from)
          .collection(whitelistCollection)
          .doc(_from + '-' + _to)
          .set(
        {
          'from': _from,
          'to': _to,
          'appname': _appname,
          'check': _check,
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

  Future<QuerySnapshot> getUsers() async {
    return _dataBase.collection(userCollection).get();
  }

  Future<QuerySnapshot> getUserbyEmail(String email) async {
    print('getting users by email');
    QuerySnapshot qshot = await _dataBase
        .collection(userCollection)
        .where('email', isEqualTo: email)
        .get();
    return qshot;
  }

  Future<QuerySnapshot> getUserbyName(String name) async {
    return _dataBase
        .collection(userCollection)
        .where('name', isEqualTo: name)
        .get();
  }

//* Getting the chats from the users
  Stream<QuerySnapshot> getChatsForsUser(String _uid) {
    return _dataBase
        .collection(chatCollection)
        .where(
          'members',
          arrayContains: _uid,
        )
        .snapshots();
  }

  //* Update to the last chat sent
  Future<QuerySnapshot> getLastMessageFroChat(String _chatID) {
    return _dataBase
        .collection(chatCollection)
        .doc(_chatID)
        .collection(messagesCollection)
        .orderBy(
          'sent_time',
          descending: true,
        )
        .limit(1)
        .get();
  }

  Stream<QuerySnapshot> streamMessagesForChatPage(String _chatId) {
    return _dataBase
        .collection(chatCollection)
        .doc(_chatId)
        .collection(messagesCollection)
        .orderBy('sent_time', descending: false)
        .snapshots();
  }

  // * Add messages to the firestore databse
  Future<void> addMessagesToChat(String _chatId, ChatMessage _message) async {
    try {
      //print('in the database service: $_message.type');
      await _dataBase
          .collection(chatCollection)
          .doc(_chatId)
          .collection(messagesCollection)
          .add(
            _message.toJson(),
          );
    } catch (error) {
      debugPrint('$error');
    }
  }

  Future<void> addTodoList(TodoListModel todolist) async {
    try {
      //print('in the database service: $_message.type');
      await _dataBase.collection(todolistCollection).add(
            todolist.toMap(),
          );
    } catch (error) {
      debugPrint('$error');
    }
  }

  Future<void> addInitMessagesToChat(
      String _chatId, String currentuserid) async {
    try {
      final _message = ChatMessage(
          senderID: currentuserid,
          content: 'Hello',
          type: MessageType.text,
          sentTime: DateTime.now());
      await _dataBase
          .collection(chatCollection)
          .doc(_chatId)
          .collection(messagesCollection)
          .add(
            _message.toJson(),
          );
    } catch (error) {
      debugPrint('$error');
    }
  }

  Future<void> updateChatData(
      String _chatId, Map<String, dynamic> _data) async {
    try {
      await _dataBase.collection(chatCollection).doc(_chatId).update(_data);
    } catch (error) {
      debugPrint('$error');
    }
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

  // *Delete chat
  Future<void> deleteChat(String _chatId) async {
    try {
      await _dataBase.collection(chatCollection).doc(_chatId).delete();
    } catch (error) {
      debugPrint('$error');
    }
  }

  //
  Future<String> getRoleBySenderID(String senderid) async {
    try {
      return await _dataBase
          .collection(userCollection)
          .doc(senderid)
          .get()
          .then((value) => value.toString());
    } catch (error) {
      debugPrint('$error');
      throw ('error');
    }
  }
}

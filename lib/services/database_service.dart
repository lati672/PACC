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
  //#User
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

  // Getting the User from Firebase Cloud Store
  Future<DocumentSnapshot> getUser(String _uid) {
    return _dataBase.collection(userCollection).doc(_uid).get();
  }

//left some problems
  Future<String> getUserRole(String _uid) async {
    print('getting user role: $_uid');
    await _dataBase.collection(userCollection).doc(_uid).get().then((value) {
      return value.data()!['role'];
    });
    return "Student";
  }

  //Getting all the Users
  Future<QuerySnapshot> getUsers() async {
    return _dataBase.collection(userCollection).get();
  }

  // Getting user by email
  Future<QuerySnapshot> getUserbyEmail(String email) async {
    //print('getting users by email');
    QuerySnapshot qshot = await _dataBase
        .collection(userCollection)
        .where('email', isEqualTo: email)
        .get();
    return qshot;
  }

  //Getting user by name
  Future<QuerySnapshot> getUserbyName(String name) async {
    print('getting users by name');
    QuerySnapshot qshot = await _dataBase
        .collection(userCollection)
        .where('name', isEqualTo: name)
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

  //literally the function name
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

  //#Chat
  // Create a new chat for the users and add a initial hello text message
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

  // query the result of whether the chat exist or not
  Future<bool> checkChatexist(String uid1, String uid2) async {
    QuerySnapshot qshot = await _dataBase
        .collection(chatCollection)
        .where('members', arrayContains: uid1)
        .get();
    List<dynamic> l = qshot.docs.map((e) => e.get('members')).toList();
    for (var i = 0; i < l.length; i++) {
      if (l[i].contains(uid2)) {
        return true;
      }
    }
    return false;
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

  //func
  Future<void> updateChatData(
      String _chatId, Map<String, dynamic> _data) async {
    try {
      await _dataBase.collection(chatCollection).doc(_chatId).update(_data);
    } catch (error) {
      debugPrint('$error');
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

  //#WhiteList
  // Create a new whitelist, currently not using
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

  //Get the latest whitelist in the chat
  Future<QuerySnapshot> getLatestWhitelist(String _chatId) async {
    return await _dataBase
        .collection(chatCollection)
        .doc(_chatId)
        .collection(messagesCollection)
        .orderBy('sent_time', descending: false)
        .where('type', isEqualTo: 'whitelist')
        .limit(1)
        .get();
  }

  MessageType convert(String type) {
    switch (type) {
      case 'text':
        {
          return MessageType.text;
        }
      case 'image':
        {
          return MessageType.image;
        }
      case 'whitelist':
        {
          return MessageType.whitelist;
        }
      default:
        {
          return MessageType.unknown;
        }
    }
  }

  Future<String> getlatestWhitelistfromAlluser(String _uid) async {
    QuerySnapshot qshot;
    List<String> docid = <String>[];
    List<ChatMessage> whitelist = [];
    qshot = await _dataBase.collection(chatCollection).get();
    qshot.docs.forEach((doc) {
      if (doc['members'].contains(_uid)) {
        docid.add(doc.id);
        //print('docid: ${doc.id}');
      }
      ;
    });
    for (var i = 0; i < docid.length; i++) {
      //print('getting the $i doc');
      QuerySnapshot q = await _dataBase
          .collection(chatCollection)
          .doc(docid[i])
          .collection(messagesCollection)
          .orderBy('sent_time', descending: true)
          .where('type', isEqualTo: 'whitelist')
          .get();

      if (q.size > 0) {
        //print(q.docs.first['sent_time']);
        whitelist.add(ChatMessage(
            senderID: q.docs.first['sender_id'],
            type: convert(q.docs.first['type']),
            content: q.docs.first['content'],
            sentTime: q.docs.first['sent_time'].toDate()));
        //print('docid is: ${docid[i]} and the latest whitelist content is:${q.docs.first['content']}');
      }
    }
    whitelist.sort(((a, b) => a.sentTime.compareTo(b.sentTime)));
    return whitelist.last.content;
  }

  //#Message
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

  //get Message stream
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

  //Add a inital hello message to the new friend
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

  //#Todolist
  //add a todo list
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
}

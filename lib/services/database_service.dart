// Packages
//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

// Models
import '../models/chat_message_model.dart';
import '../models/todo_list_model.dart';
import '../models/parent-student_model.dart';
import 'package:chatifyapp/models/friend_model.dart';
import 'package:chatifyapp/models/chat_user_model.dart';

const String userCollection = 'Users';
const String chatCollection = 'Chats';
const String messagesCollection = 'Messages';
const String whitelistCollection = 'Whitelist';
const String todolistCollection = 'Todolist';
const String friendsCollection = 'Friends';
const String parentstudentCollection = 'Parent-Student';

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
    await _dataBase.collection(userCollection).doc(_uid).get().then((value) {
      return value.data()!['role'];
    });
    return "Student";
  }

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
  Future<String> getRoleBySenderID(String senderid) async {
    try {
      DocumentSnapshot qshot =
          await _dataBase.collection(userCollection).doc(senderid).get();
      return qshot['role'];
    } catch (error) {
      debugPrint('$error');
      throw ('error');
    }
  }

  Future<List<String>> getmembers(String _chatid) async {
    try {
      DocumentSnapshot docshot =
          await _dataBase.collection(chatCollection).doc(_chatid).get();
      return docshot['members'];
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

  Future<void> friendrequest(String _currentuserUid, bool _activity,
      bool _group, List<String> _members) async {
    try {
      await _dataBase.collection(chatCollection).add(
        {
          'currentUserUid': _currentuserUid,
          'is_activity': _activity,
          'is_group': _group,
          'members': _members,
        },
      ).then((docRef) => {sendFriendRequest(docRef.id, _currentuserUid)});
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
    List<ChatMessage> allwhitelists = [];
    List<ChatMessage> parentwhitelist = [];
    //Get all the chat collections
    qshot = await _dataBase.collection(chatCollection).get();
    //Select those chat contains the user
    qshot.docs.forEach((doc) {
      if (doc['members'].contains(_uid)) {
        docid.add(doc.id);
      }
    });
    //Select those messages where type is equal to whitelist and order by sent time
    for (var i = 0; i < docid.length; i++) {
      QuerySnapshot q = await _dataBase
          .collection(chatCollection)
          .doc(docid[i])
          .collection(messagesCollection)
          .orderBy('sent_time', descending: true)
          .where('type', isEqualTo: 'whitelist')
          .get();
      // convert to ChatMessage class
      q.docs.forEach((doc) {
        allwhitelists.add(ChatMessage(
            senderID: doc['sender_id'],
            type: convert(doc['type']),
            content: doc['content'],
            sentTime: doc['sent_time'].toDate()));
      });
    }
    //Select those were sent by parent
    for (var i = 0; i < allwhitelists.length; i++) {
      String role = await getRoleBySenderID(allwhitelists[i].senderID);
      if (role == 'Parent') {
        parentwhitelist.add(allwhitelists[i]);
      }
    }
    //Sorted by time
    parentwhitelist.sort(((a, b) => a.sentTime.compareTo(b.sentTime)));

    return parentwhitelist.last.content;
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

  //Send a new friend request
  Future<void> sendFriendRequest(String _chatId, String currentuserid) async {
    try {
      String name = await getUserName(currentuserid);
      String role = await getRoleBySenderID(currentuserid);
      final _message = ChatMessage(
          senderID: currentuserid,
          content:
              (name + '希望添加您为好友,他/她的身份是' + (role == 'Student' ? '学生' : '家长')),
          type: MessageType.confirm,
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

  //confirm the friend request
  Future<void> confirmFriendRequest(
      String _chatId, String currentuserid) async {
    try {
      String name = await getUserName(currentuserid);
      final _message = ChatMessage(
          senderID: currentuserid,
          content: ('你们已经成功添加好友啦，开始聊天吧'),
          type: MessageType.confirm,
          sentTime: DateTime.now());
      await _dataBase
          .collection(chatCollection)
          .doc(_chatId)
          .collection(messagesCollection)
          .add(
            _message.toJson(),
          );
      await addParentStudentRel(_chatId);
    } catch (error) {
      debugPrint('$error');
    }
  }

  //#Todolist
  //add a todo list
  Future<void> addTodoList(TodoListModel todolist) async {
    try {
      await _dataBase.collection(todolistCollection).add(
            todolist.toMap(),
          );
    } catch (error) {
      debugPrint('$error');
    }
  }

  //remove a todo list
  Future<void> removeTodoList(String todoID) async {
    try {
      await _dataBase.collection(todolistCollection).doc(todoID).delete();
    } catch (error) {
      debugPrint('$error');
    }
  }

  Future<List<TodoListModel>> getTodoList(String userid) async {
    List<TodoListModel> todo = [];
    QuerySnapshot qshot = await _dataBase
        .collection(todolistCollection)
        .where('recipients', arrayContains: userid)
        .get();
    qshot.docs.forEach((doc) {
      todo.add(TodoListModel(
          sent_time: doc['sent_time'].toDate(),
          senderid: doc['senderid'],
          status: doc['status'],
          start_time: doc['start_time'].toDate(),
          description: doc['description'],
          todolist_name: doc['todolist_name'],
          interval: doc['interval'],
          recipients: List.from(doc['recipients'])));
    });
    return todo;
  }

  Stream<QuerySnapshot> getUserTodoList(String _userid) {
    return _dataBase
        .collection(todolistCollection)
        .orderBy('sent_time', descending: false)
        .where(
          'recipients',
          arrayContains: _userid,
        )
        .snapshots();
  }

  //update a todo list
  Future<void> updateTodoList(TodoListModel todolist, String todoID) async {
    try {
      await _dataBase.collection(todolistCollection).doc(todoID).set(
        {
          'status': todolist.status,
          'start_time': todolist.start_time,
          'description': todolist.description,
          'interval': todolist.interval,
          'recipients': todolist.recipients,
          'todolist_name': todolist.todolist_name,
        },
      );
    } catch (error) {
      debugPrint('$error');
    }
  }

  // check whether the chat members are friend
  Future<bool> checkFriendsbyChatid(String _chatid) async {
    bool result = false;
    DocumentSnapshot chatshot =
        await _dataBase.collection(chatCollection).doc(_chatid).get();
    List<String> members = List.from(chatshot['members']);
    String user1id = members[0];
    String user2id = members[1];
    QuerySnapshot friendshot =
        await _dataBase.collection(friendsCollection).get();
    friendshot.docs.forEach((doc) {
      String user1 = doc['user1id'];
      String user2 = doc['user2id'];
      if ((user1 == user1id && user2 == user2id) ||
          (user1 == user2id && user2 == user1id)) {
        result = true;
      }
    });
    return result;
  }

  //#Parent-Student
  //add a new parent-student relationship
  Future<void> addParentStudentRel(String _chatid) async {
    try {
      DocumentSnapshot docshot =
          await _dataBase.collection(chatCollection).doc(_chatid).get();

      List<String> members = List.from(docshot['members']);
      String user1id = members[0];
      String user2id = members[1];
      String user1role = await getRoleBySenderID(user1id);
      String user2role = await getRoleBySenderID(user2id);
      if (user1role == 'Parent' && user2role == 'Student') {
        await _dataBase
            .collection(parentstudentCollection)
            .add({'parentid': user1id, 'studentid': user2id});
      }
      if (user2role == 'Parent' && user1role == 'Student') {
        await _dataBase
            .collection(parentstudentCollection)
            .add({'parentid': user2id, 'studentid': user1id});
      }
    } catch (error) {
      debugPrint('$error');
    }
  }

  //Get parents' id by student id
  Future<List<String>> getParents(String student_id) async {
    List<String> parents = [];
    QuerySnapshot qshot =
        await _dataBase.collection(parentstudentCollection).get();
    qshot.docs.forEach((doc) {
      String parentid = doc['parentid'];
      String studentid = doc['studentid'];
      if (student_id == studentid) {
        parents.add(parentid);
      }
    });
    return parents;
  }

  //Get students' id by parent id
  Future<List<String>> getStudents(String parent_id) async {
    List<String> students = [];
    QuerySnapshot qshot =
        await _dataBase.collection(parentstudentCollection).get();
    qshot.docs.forEach((doc) {
      String parentid = doc['parentid'];
      String studentid = doc['studentid'];
      if (parent_id == parentid) {
        students.add(studentid);
      }
    });
    return students;
  }

  //get parentsname using stream, maybe later return a Chatuser model
  Stream<String> getParentsnameStream(String student_id) async* {
    List<String> parents = [];
    QuerySnapshot qshot = await _dataBase
        .collection(parentstudentCollection)
        .where('studentid', isEqualTo: student_id)
        .get();
    if (qshot.size > 0) {
      qshot.docs.forEach((doc) {
        parents.add(doc['parentid']);
      });
      for (var i = 0; i < parents.length; i++) {
        String name = await getUserName(parents[i]);
        yield name;
      }
    }
  }

  Stream<String> getStudentsnameStream(String parent_id) async* {
    List<String> students = [];
    QuerySnapshot qshot = await _dataBase
        .collection(parentstudentCollection)
        .where('parentid', isEqualTo: parent_id)
        .get();
    if (qshot.size > 0) {
      qshot.docs.forEach((doc) {
        students.add(doc['studentid']);
      });
      for (var i = 0; i < students.length; i++) {
        String name = await getUserName(students[i]);
        yield name;
      }
    }
  }

  Future<bool> checkPSrel(String _user1id, String _user2id) async {
    bool result = false;
    QuerySnapshot docshot =
        await _dataBase.collection(parentstudentCollection).get();
    docshot.docs.forEach((doc) {
      String user1 = doc['parentid'];
      String user2 = doc['studentid'];
      if ((user1 == _user1id && user2 == _user2id) ||
          (user1 == _user2id && user2 == _user1id)) {
        result = true;
      }
    });
    return result;
  }
}

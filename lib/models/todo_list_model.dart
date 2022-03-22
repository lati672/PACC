import 'package:flutter/material.dart';

import '../models/chat_user_model.dart';
import '../models/chat_message_model.dart';

class TodoListModel {
  final String uid;
  final String description;
  final DateTime start_time, end_time;
  final String name;
  final String interval;

  final List<ChatUserModel> recepients;

  TodoListModel({
    required this.uid,
    required this.description,
    required this.start_time,
    required this.end_time,
    required this.name,
    required this.interval,
    required this.recepients,
  });
  factory TodoListModel.fromJson(Map<String, dynamic> _json) {
    return TodoListModel(
        // uid: _json['senderid'],
        // description: _json['description'],
        // start_time: _json['start_time'],
        // end_time: _json['end_time'],
        // name: _json['todolist_name'],
        // interval: _json['interval'],
        // recepients: _json['recepient']);
        uid: _json['uid'],
        description: _json['description'],
        start_time: _json['start_time'],
        end_time: _json['end_time'],
        name: _json['name'],
        interval: _json['interval'],
        recepients: _json['recepients']);
  }
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'start_time': start_time,
      'end_time': end_time,
      'name': name,
      'interval': interval,
      'recepients': recepients
    };
  }
//

  // Group chat image

}

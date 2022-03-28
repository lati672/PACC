import 'package:flutter/material.dart';

import '../models/chat_user_model.dart';
import '../models/chat_message_model.dart';

class TodoListModel {
  final String senderid;
  final String description;
  final DateTime start_time;
  String status;
  final String todolist_name;
  final String interval;

  final List<String> recipients;

  TodoListModel({
    required this.senderid,
    required this.start_time,
    // required this.status,
    this.status = "0",
    required this.description,
    required this.todolist_name,
    required this.interval,
    required this.recipients,
  });
  factory TodoListModel.fromJson(Map<String, dynamic> _json) {
    return TodoListModel(
        senderid: _json['senderid'],
        start_time: _json['start_time'].toDate(),
        status: _json['status'],
        description: _json['description'],
        todolist_name: _json['todolist_name'],
        interval: _json['interval'],
        recipients: _json['recipients']);
  }
  Map<String, dynamic> toMap() {
    return {
      'senderid': senderid,
      'start_time': start_time,
      'status': status,
      'description': description,
      'todolist_name': todolist_name,
      'interval': interval,
      'recipients': recipients
    };
  }
//

  // Group chat image

}

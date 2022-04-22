import 'package:flutter/material.dart';

import '../models/chat_user_model.dart';
import '../models/chat_message_model.dart';

class TodoListModel {
  final String senderid;
  final String description;
  final List<DateTime> start_time;
  List<String> status;
  final String todolist_name;
  final int interval;
  final DateTime sent_time;

  final List<String> recipients;
  final List<String> recipientsName;

  TodoListModel({
    required this.senderid,
    required this.start_time,
    required this.status,
    required this.description,
    required this.todolist_name,
    required this.interval,
    required this.recipients,
    required this.recipientsName,
    required this.sent_time,
  });
  factory TodoListModel.fromJson(Map<String, dynamic> _json) {
    return TodoListModel(
        sent_time: _json['sent_time'],
        // sent_time: _json['sent_time'].toDate(),
        senderid: _json['senderid'],
        start_time: List.generate(_json['start_time'].length,
            (index) => _json['start_time'][index].toDate()),
        // start_time: _json['start_time'].toDate(),
        status: List.from(_json['status']),
        // status: _json['status'],
        description: _json['description'],
        todolist_name: _json['todolist_name'],
        interval: _json['interval'],
        recipients: List.from(_json['recipients']),
        recipientsName: List.from(_json['recipientsName']));
  }
  Map<String, dynamic> toMap() {
    return {
      'sent_time': sent_time,
      'senderid': senderid,
      'start_time': start_time,
      'status': status,
      'description': description,
      'todolist_name': todolist_name,
      'interval': interval,
      'recipients': recipients,
      'recipientsName': recipientsName
    };
  }

  UpdateStatus(String _uid, String _status) {
    int pos = 0;
    for (var i = 0; i < recipients.length; i++) {
      if (_uid == recipients[i]) {
        pos = i;
        break;
      }
      status[pos] = _status;
    }
  }

  UpdateStartTime(String _uid, DateTime _starttime) {
    int pos = 0;
    for (var i = 0; i < recipients.length; i++) {
      if (_uid == recipients[i]) {
        pos = i;
        break;
      }
      start_time[pos] = _starttime;
    }
  }
//

  // Group chat image

}

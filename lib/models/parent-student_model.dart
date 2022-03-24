import 'package:cloud_firestore/cloud_firestore.dart';

class ParentStudentModel {
  ParentStudentModel({
    required this.parentid,
    required this.studentid,
  });

  final String parentid;
  final String studentid;
  factory ParentStudentModel.fromJson(Map<String, dynamic> _json) {
    return ParentStudentModel(
      parentid: _json['parentid'],
      studentid: _json['studentid'],
    );
  }
}

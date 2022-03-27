import 'dart:io';

// Packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

const String userCollection = 'Users';

class CloudStorageService {
  CloudStorageService();

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<String?> saveUserImageProfileToStorage(
      String _uid, PlatformFile _file) async {
    try {
      final _reference =
          _firebaseStorage.ref('images/users/$_uid/profile.${_file.extension}');
      UploadTask _task = _reference.putFile(
        File(_file.path as String),
      );
      //* Returning the photo url
      return await _task.then(
        (_result) => _result.ref.getDownloadURL(),
      );
    } catch (error) {
      debugPrint('$error');
    }
    return null;
  }

  Future<String?> uploadUserImageProfileToStorage(
      String _uid, PlatformFile _file) async {
    try {
      final _reference =
          _firebaseStorage.ref('images/users/$_uid/profile.${_file.extension}');
      await _reference.delete();
      UploadTask _task = _reference.putFile(
        File(_file.path as String),
      );
      //* Returning the photo url
      return await _task.then(
        (_result) => _result.ref.getDownloadURL(),
      );
    } catch (error) {
      debugPrint('$error');
    }
    return null;
  }

  Future<String?> saveDefaultUserImageProfileToStorage(String _uid) async {
    try {
      final _reference = _firebaseStorage.ref('images/users/$_uid/profile.jpg');
      String img = 'assets/images/default-image.jpg';
      String imageName = img
          .substring(img.lastIndexOf("/"), img.lastIndexOf("."))
          .replaceAll("/", "");

      String path = img.substring(img.indexOf("/") + 1, img.lastIndexOf("/"));

      final Directory systemTempDir = Directory.systemTemp;
      final byteData = await rootBundle.load(img);
      final file = File('${systemTempDir.path}/$imageName.jpg');
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      TaskSnapshot taskSnapshot = await _reference.putFile(file);
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      debugPrint('$error');
    }
    return null;
  }

  Future<String?> saveChatImageToStorage(
    String _chatID,
    String _userID,
    PlatformFile _file,
  ) async {
    try {
      final _reference = _firebaseStorage.ref().child(
          'images/chats/$_chatID/${_userID}_${Timestamp.now().millisecondsSinceEpoch}.${_file.extension}');

      //* Uploading the image in the refered path
      UploadTask _task = _reference.putFile(
        File(_file.path as String),
      );
      //* Returning the photo url
      return await _task.then(
        (_result) => _result.ref.getDownloadURL(),
      );
    } catch (error) {
      debugPrint('$error');
    }
    return null;
  }
}

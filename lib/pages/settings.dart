// Packages
import 'package:chatifyapp/models/chat_user_model.dart';
import 'package:flutter/material.dart';
import 'package:chatifyapp/pages/whitelist_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingPage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SettingPage> {
  //List<ChatUserModel> _
  final db = FirebaseFirestore.instance;
  List<ChatUserModel> _itemList = [
    ChatUserModel(
        uid: 'QfrIAoXKV0gBlRC36wwdMd6bN9D3',
        name: "liwanting",
        email: "2088175536@qq.com",
        role: "teacher",
        imageUrl:
            "https://firebasestorage.googleapis.com/v0/b/chatifyapp-87454.appspot.com/o/images%2Fusers%2FQfrIAoXKV0gBlRC36wwdMd6bN9D3%2Fprofile.jpg?alt=media&token=3f5c5b7d-16c8-44ff-842a-8767901eab8d",
        lastActive: DateTime.now()),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Open a whitelist'),
        ),
        body: Center(
            child: ListView.builder(
          itemCount: _itemList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
                onTap: () {},
                child: Container(
                    margin: EdgeInsets.all(20),
                    child: Text(_itemList[index].name)));
          },
        )));
  }
}

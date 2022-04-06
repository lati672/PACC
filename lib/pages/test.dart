import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/media_service.dart';
import 'package:chatifyapp/widgets/rounded_image_network.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:ssh2/ssh2.dart';

class TestPage extends StatefulWidget {
  @override
  _TestState createState() => new _TestState();
}

class _TestState extends State<TestPage> {
  bool _isIpOnline = false;
  String _ipFound = "";
  String _result = '';
  PlatformFile? _profileImage;
  late double _deviceWidth;
  late double _deviceHeight;
  final int port = 8122;
  var client = SSHClient(
    host: "218.193.154.234",
    port: 8122,
    username: "lzx",
    passwordOrKey: "lzx123",
  );
  void connect() async {
    String? x = await client.connect();
    print(x);
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    connect();
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSH'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      onPressed: () {},
                      icon: Icon(Icons.wifi),
                      label: Text("network"),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.black.withAlpha(150),
                      maxRadius: 12,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        maxRadius: 10,
                        child: CircleAvatar(
                          backgroundColor:
                              _isIpOnline ? Colors.green : Colors.grey,
                          maxRadius: 8,
                        ),
                      ),
                    ),
                    Text("IP :\n$_ipFound",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, thickness: 2, indent: 10, endIndent: 10),
              _profileImageField(),
              TextButton(
                  onPressed: () {},
                  child: const Text(
                    'upload',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  )),
              const SizedBox(height: 20),
              const Divider(height: 1, thickness: 2, indent: 10, endIndent: 10),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black26.withAlpha(40),
                    border: Border.all(
                      color:
                          _result.isNotEmpty ? Colors.blueAccent : Colors.grey,
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      _result.isNotEmpty
                          ? const Text("RESPOSTA DO EQUIPAMENTO:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ))
                          : const Text(
                              "\nA resposta do comando será retornada aqui:",
                              style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 15),
                      ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(2.0),
                        children: <Widget>[
                          Text(_result),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileImageField() {
    return GestureDetector(
      onTap: () =>
          GetIt.instance.get<MediaService>().pickImageFromLibrary().then(
        (_file) {
          if (_file != null) {
            setState(
              () {
                _profileImage = _file;
              },
            );
          }
        },
      ),
      child: () {
        if (_profileImage != null) {
          // Selected imageFileImage(
          return Image.file(
            File(
              _profileImage!.path as String,
            ),
          );
          return RoundedImageFile(
            key: UniqueKey(),
            image: _profileImage!,
            size: _deviceHeight * .15,
          );
        } else {
          // Default Image
          return Image.asset('assets/images/default-image.jpg');
          return RoundedAssetImage(
            key: UniqueKey(),
            image: 'assets/images/default-image.jpg',
            size: _deviceHeight * .15,
          );
        }
      }(),
    );
  }
}

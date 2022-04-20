import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/media_service.dart';
import 'package:chatifyapp/widgets/rounded_image_network.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:ssh2/ssh2.dart';
import 'package:path_provider/path_provider.dart';

class TestPage extends StatefulWidget {
  @override
  _TestState createState() => new _TestState();
}

class _TestState extends State<TestPage> {
  final String hostname = '218.193.154.234';
  final String username = 'lzx';
  final String password = 'lzx123';
  final String testroute = "/home/lzx/TestData/";
  final String videoroute = '/home/lzx/Data/sourceVideo/';
  final String resroute = '/home/lzx/Data/resText/';
  bool _isIpOnline = false;
  String _ipFound = "";
  final ButtonStyle buttonStyle =
      TextButton.styleFrom(backgroundColor: Colors.blue);
  String _result = '';
  List _array = [];
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
  void resetValues() {
    setState(() {
      _result = 'Loading';
      _array = [];
    });
  }

  Future<void> onClickCmd() async {
    String result = '';

    resetValues();

    var client = SSHClient(
      host: hostname,
      port: 8122,
      username: username,
      passwordOrKey: password,
    );

    try {
      result = await client.connect() ?? 'Null result';
      if (result == "session_connected")
        result = await client.execute("ps") ?? 'Null result';
      await client.disconnect();
    } on PlatformException catch (e) {
      String errorMessage = 'Error: ${e.code}\nError Message: ${e.message}';
      result = errorMessage;
      print(errorMessage);
    }

    setState(() {
      _result = result;
    });
  }

  Future<void> onClickSFTP() async {
    String result = '';
    List array = [];

    resetValues();

    var client = SSHClient(
      host: hostname,
      port: 8122,
      username: username,
      passwordOrKey: password,
    );
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    print('the tempdir is $tempPath');
    // Create local test file
    final String fileName = 'ssh2_test_upload.txt';
    final File file = File('$tempPath/$fileName');
    await file.writeAsString('Testing file upload');

    print('Local file path is ${file.path}');
    try {
      result = await client.connect() ?? 'Null result';
      if (result == "session_connected") {
        result = await client.connectSFTP() ?? 'Null result';
        if (result == "sftp_connected") {
          array = await client.sftpLs() ?? [];

          // Create a test directory
          print(await client.sftpMkdir("testsftp"));

          // Rename the test directory
          print(await client.sftpRename(
            oldPath: "testsftp",
            newPath: "testsftprename",
          ));

          // Remove the renamed test directory
          print(await client.sftpRmdir("testsftprename"));

          // Get local device temp directory
          Directory tempDir = await getTemporaryDirectory();
          String tempPath = tempDir.path;
          print('the tempdir is $tempPath');
          // Create local test file
          final String fileName = 'ssh2_test_upload.txt';
          final File file = File('$tempPath/$fileName');
          await file.writeAsString('Testing file upload');

          print('Local file path is ${file.path}');

          // Upload test file
          print(await client.sftpUpload(
                path: file.path,
                toPath: "/home/lzx/TestData",
                callback: (progress) async {
                  print(progress);
                  // if (progress == 30) await client.sftpCancelUpload();
                },
              ) ??
              'Upload failed');

          // Download test file
          print(await client.sftpDownload(
                path: "/home/lzx/TestData/" + fileName,
                toPath: tempPath,
                callback: (progress) async {
                  print(progress);
                  // if (progress == 20) await client.sftpCancelDownload();
                },
              ) ??
              'Download failed');

          // Delete the remote test file
          print(await client.sftpRm(fileName));

          // Delete the local test file
          await file.delete();

          // Disconnect from SFTP client - don't use
          // There is a bug that prevents the ssh client connection from being
          // closed after calling disconnectSFTP()
          //print(await client.disconnectSFTP());

          // Disconnect from SSH client
          await client.disconnect();
        }
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Error: ${e.code}\nError Message: ${e.message}';
      result += errorMessage;
      print(errorMessage);
    }

    setState(() {
      _result = result;
      _array = array;
    });
  }

  Future<void> onClickGetres() async {
    String result = '';
    List array = [];

    resetValues();

    var client = SSHClient(
      host: hostname,
      port: 8122,
      username: username,
      passwordOrKey: password,
    );
    try {
      result = await client.connect() ?? 'Null result';
      if (result == "session_connected") {
        result = await client.connectSFTP() ?? 'Null result';
        if (result == "sftp_connected") {
          array = await client.sftpLs() ?? [];
          Directory tempDir = await getTemporaryDirectory();
          String tempPath = tempDir.path;
          String fileName = 'res.txt';

          print(await client.sftpDownload(
                path: resroute + fileName,
                toPath: tempPath,
                callback: (progress) async {
                  print(progress);
                  // if (progress == 20) await client.sftpCancelDownload();
                },
              ) ??
              'Download failed');
          final File file = File('$tempPath/$fileName');
          List<String> txt = await file.readAsLines();
          for (var i = 0; i < txt.length; i++) {
            print('the $i txt:${txt[i]}');
          }
          await client.disconnect();
        }
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Error: ${e.code}\nError Message: ${e.message}';
      result += errorMessage;
      print(errorMessage);
    }

    setState(() {
      _result = result;
      _array = array;
    });
  }

  Future<void> onClickUpload() async {
    String result = '';
    List array = [];

    resetValues();

    var client = SSHClient(
      host: hostname,
      port: 8122,
      username: username,
      passwordOrKey: password,
    );
    try {
      result = await client.connect() ?? 'Null result';
      if (result == "session_connected") {
        result = await client.connectSFTP() ?? 'Null result';
        if (result == "sftp_connected") {
          array = await client.sftpLs() ?? [];

          String tempPath = _profileImage!.path!;
          final File file = File(tempPath);
          print(await client.sftpUpload(
                path: file.path,
                toPath: "/home/lzx/TestData",
                callback: (progress) async {
                  print(progress);
                  // if (progress == 30) await client.sftpCancelUpload();
                },
              ) ??
              'Upload failed');

          // Download test file
          print(await client.sftpDownload(
                path: resroute + 'res.txt',
                toPath: tempPath,
                callback: (progress) async {
                  print(progress);
                  // if (progress == 20) await client.sftpCancelDownload();
                },
              ) ??
              'Download failed');

          // Delete the remote test file
          // print(await client.sftpRm(fileName));

          // Delete the local test file
          await file.delete();

          await client.disconnect();
        }
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Error: ${e.code}\nError Message: ${e.message}';
      result += errorMessage;
      print(errorMessage);
    }

    setState(() {
      _result = result;
      _array = array;
    });
  }

  Map<String, double> statusmap = {
    'play_phone': 1.0,
    'play_computer': 1.0,
    'study': -1.0,
    'leave_seat': -0.5,
    'talk': 0,
    'sleep': -0.5
  };
  bool decodeRes(List<String> seq) {
    double confidence = 0.0;
    for (var i = 0; i < seq.length; i++) {
      List<String> tmp = seq[i].split(',');
      String status = tmp[1];
      double weight = double.parse(seq[2]);
      confidence += weight * statusmap[status]!;
    }

    return confidence > 0 ? true : false;
  }

  Future<void> uploadvideo(String videopath) async {
    String hostname = '218.193.154.234';
    String username = 'lzx';
    String password = 'lzx123';
    String videoroute = '/home/lzx/Data/sourceVideo/';
    String resroute = '/home/lzx/Data/resText/';
    String respath = '/home/lzx/Data/resText/res.txt';
    String result = '';
    List array = [];

    resetValues();

    var client = SSHClient(
      host: hostname,
      port: 8122,
      username: username,
      passwordOrKey: password,
    );
    try {
      result = await client.connect() ?? 'Null result';
      if (result == "session_connected") {
        result = await client.connectSFTP() ?? 'Null result';
        if (result == "sftp_connected") {
          array = await client.sftpLs() ?? [];

          String tempPath = videopath;
          final File file = File(tempPath);
          print(await client.sftpUpload(
                path: file.path,
                toPath: videoroute,
                callback: (progress) async {
                  print(progress);
                  // if (progress == 30) await client.sftpCancelUpload();
                },
              ) ??
              'Upload failed');

          // Download test file
          print(await client.sftpDownload(
                path: resroute + 'res.txt',
                toPath: tempPath,
                callback: (progress) async {
                  print(progress);
                  // if (progress == 20) await client.sftpCancelDownload();
                },
              ) ??
              'Download failed');
          String fileName = 'res.txt';
          final File resfile = File('$tempPath/$fileName');
          List<String> txt = await resfile.readAsLines();
          for (var i = 0; i < txt.length; i++) {
            print('the $i txt:${txt[i]}');
          }
          // Delete the remote test file
          print(await client.sftpRm(respath));

          // Delete the local test file
          await file.delete();

          await client.disconnect();
        }
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Error: ${e.code}\nError Message: ${e.message}';
      result += errorMessage;
      print(errorMessage);
    }

    setState(() {
      _result = result;
      _array = array;
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Page'),
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
                    TextButton(
                      style: buttonStyle,
                      child: const Text(
                        'Test command',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: onClickCmd,
                    ),
                    TextButton(
                      style: buttonStyle,
                      child: const Text(
                        'Test SFTP',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: onClickSFTP,
                    ),
                  ],
                ),
              ),
              Text(_result),
              _array.length > 0
                  ? Column(
                      children: _array.map((f) {
                        return Text(
                            "${f["filename"]} ${f["isDirectory"]} ${f["modificationDate"]} ${f["lastAccess"]} ${f["fileSize"]} ${f["ownerUserID"]} ${f["ownerGroupID"]} ${f["permissions"]} ${f["flags"]}");
                      }).toList(),
                    )
                  : Container(),
              const SizedBox(height: 10),
              const Divider(height: 1, thickness: 2, indent: 10, endIndent: 10),
              _profileImageField(),
              TextButton(
                  onPressed: () {
                    onClickUpload();
                  },
                  child: const Text(
                    'upload',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  )),
              TextButton(
                  onPressed: () {
                    onClickGetres();
                  },
                  child: const Text(
                    'getRes',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileImageField() {
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxWidth: _deviceWidth * 0.8, maxHeight: _deviceHeight * 0.5),
      child: GestureDetector(
        onTap: () =>
            GetIt.instance.get<MediaService>().pickImageFromLibrary().then(
          (_file) {
            if (_file != null) {
              setState(
                () {
                  _profileImage = _file;
                  print('the file path is ${_profileImage!.path}');
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
          }
        }(),
      ),
    );
  }
}

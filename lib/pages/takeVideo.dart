//packages
import 'package:chatifyapp/pages/todolist_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:convert';
import 'package:chatifyapp/pages/test.dart';
import 'package:chatifyapp/services/ssh_service.dart';
import 'package:ssh2/ssh2.dart';
import '../services/cloud_storage_service.dart';
import '../services/database_service.dart';
// Services
import '../services/navigation_service.dart';

// A screen that allows users to take a picture using a given camera.
class TakeVideoScreen extends StatefulWidget {
  TakeVideoScreen({
    Key? key,
    required this.todolistid,
    required this.pos,
    required this.parentid,
    required this.studentid,
    required this.cameras,
    required this.isVideoOpen,
    required this.setIsVideoOpen,
  }) : super(key: key);

  // final CameraDescription camera;
  final List<CameraDescription> cameras;
  int pos;
  String todolistid;
  String parentid, studentid;
  bool isVideoOpen;
  final setIsVideoOpen;

  @override
  TakeVideoScreenState createState() => TakeVideoScreenState();
}

class TakeVideoScreenState extends State<TakeVideoScreen> {
  late CloudStorageService _cloudStorageService;
  late CameraController _controller;
  late DatabaseService _database;
  late Future<void> _initializeControllerFuture;
  late double _deviceWidth;
  late double _deviceHeight;

  bool isVideo = false;
  NavigationService _navigation = GetIt.instance.get<NavigationService>();

  startVideo() async {
    await _controller.startVideoRecording();
    setState(() {
      isVideo = true;
    });
  }

  stopVideo() async {
    XFile videopath = await _controller.stopVideoRecording();
    print("videopath.path:");
    print(videopath.path);

    //await Future.delayed(const Duration(minutes: 1), () => {});

    //视频上传服务器
    bool isdistracted = await uploadvideo(videopath.path);
    if (isdistracted) {
      //视频上传到firebase storage
      String? videourl = await _cloudStorageService.saveStudentVideoToStorage(
          widget.todolistid, videopath);
      //把待办状态更新为分心
      await _database.updateTodoListStatustoDistracted(
          widget.todolistid, widget.pos);
      //发送警告给家长
      await _database.sendAlarmMessage(
          widget.parentid, widget.studentid, videourl!);
      _showAlertWarn(context);
    }

    /// 视频名称
    // var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    setState(() {
      isVideo = false;
    });
    widget.setIsVideoOpen(true);
  }

  //Show Alert based on alert type
  void _showAlertWarn(BuildContext context) {
    final alert = AlertDialog(
      title: const Text("警告"),
      content: const Text('检测到当前未在学习！'),
      actions: [
        FlatButton(
          child: const Text("确定"),
          onPressed: () {
            _navigation.goBack();
          },
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    // super.didUpdateWidget();
    if (widget.isVideoOpen) {
      startVideo();
    } else if (isVideo) {
      stopVideo();
    }
  }

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.cameras[0],
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
    // fun();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future<bool> uploadvideo(String videopath) async {
    String hostname = '218.193.154.234';
    String username = 'lzx';
    String password = 'lzx123';
    String videoroute = '/home/lzx/Data/sourceVideo/';
    String resroute = '/home/lzx/Data/resText/';
    String respath = '/home/lzx/Data/resText/res.txt';
    int port = 8122;
    String result = '';
    List array = [];
    bool isdistract = false;
    Map<String, double> statusmap = {
      'play_phone': 1.0,
      'play_computer': 1.0,
      'study': -1.0,
      'leave_seat': -0.1,
      'talk': 0,
      'sleep': -0.1
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

    var client = SSHClient(
      host: hostname,
      port: port,
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
          //wait after process
          //Future.delayed(const Duration(seconds: 20), () => {});
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
          isdistract = decodeRes(txt);
          // Delete the remote test file
          print(await client.sftpRm(respath));

          // Delete the local test file
          await file.delete();

          await client.disconnect();
          return isdistract;
        }
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Error: ${e.code}\nError Message: ${e.message}';
      result += errorMessage;
      print(errorMessage);
      throw (errorMessage);
    }
    return isdistract;
  }

  @override
  Widget build(BuildContext context) {
    _cloudStorageService = GetIt.instance.get<CloudStorageService>();
    _database = GetIt.instance.get<DatabaseService>();
    //ssh = GetIt.instance.get<SSHService>();
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    // fun();
    return SizedBox(
        width: _deviceWidth * 0.3,
        height: _deviceHeight * 0.3,
        child: Scaffold(
          // You must wait until the controller is initialized before displaying the
          // camera preview. Use a FutureBuilder to display a loading spinner until the
          // controller has finished initializing.
          body: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return CameraPreview(_controller);
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          // floatingActionButton: FloatingActionButton(
          //   // Provide an onPressed callback.
          //   onPressed: () async {
          //     // Take the Picture in a try / catch block. If anything goes wrong,
          //     // catch the error.
          //     try {
          //       // Ensure that the camera is initialized.
          //       await _initializeControllerFuture;
          //       // Attempt to take a picture and get the file `image`
          //       // where it was saved.
          //       final image = await _controller.takePicture();
          //       // If the picture was taken, display it on a new screen.
          //       // await Navigator.of(context).push(
          //       //   MaterialPageRoute(
          //       //     builder: (context) => DisplayPictureScreen(
          //       //       // Pass the automatically generated path to
          //       //       // the DisplayPictureScreen widget.
          //       //       imagePath: image.path,
          //       //     ),
          //       //   ),
          //       // );
          //     } catch (e) {
          //       // If an error occurs, log the error to the console.
          //       print(e);
          //     }
          //   },
          //   child: const Icon(Icons.camera_alt),
          // ),
        ));
  }
}

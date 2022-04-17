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

// A screen that allows users to take a picture using a given camera.
class TakeVideoScreen extends StatefulWidget {
  TakeVideoScreen({
    Key? key,
    required this.cameras,
    required this.isVideoOpen,
    required this.setIsVideoOpen,
  }) : super(key: key);

  // final CameraDescription camera;
  final List<CameraDescription> cameras;
  bool isVideoOpen;
  final setIsVideoOpen;

  @override
  TakeVideoScreenState createState() => TakeVideoScreenState();
}

class TakeVideoScreenState extends State<TakeVideoScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late double _deviceWidth;
  late double _deviceHeight;
  bool isVideo = false;

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

    /// 视频名称
    // var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    setState(() {
      isVideo = false;
    });
    widget.setIsVideoOpen(true);
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
      widget.cameras[1],
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

  @override
  Widget build(BuildContext context) {
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

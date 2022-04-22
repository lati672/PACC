import 'package:ssh2/ssh2.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class SSHService {
  const SSHService();
  // Null checker in case we may not get any image to return
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
          Future.delayed(const Duration(seconds: 20), () => {});
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
}

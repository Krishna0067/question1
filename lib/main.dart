import 'dart:io';

import 'package:flutter/material.dart';
import 'pickFile.dart';
import 'saveVideo.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDlL_IW95xa_v1E3RUcPrlhivSpVoodPyo",
          appId: "1:86131047252:android:646420d3ecda56f4a926c1",
          projectId: "temtask-1a77a",
          messagingSenderId: "86131047252",
          storageBucket: "temtask-1a77a.appspot.com"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Myhomepage(),
    );
  }
}

class Myhomepage extends StatefulWidget {
  const Myhomepage({super.key});

  @override
  State<Myhomepage> createState() => _MyhomepageState();
}

class _MyhomepageState extends State<Myhomepage> {
  String? _errorMessage;
  String? _videoUploadURL;
  VideoPlayerController? _controller;
  String? _downloadVideoURL;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("video upload"),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: Center(
        child: _videoUploadURL != null
            ? _videoPreviewWidget()
            : const Text("Select The Video"),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _pickVideo,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.video_library),
              SizedBox(width: 8), // Add some spacing between icon and text
              Text('Pick Video'),
            ],
          ),
        ),
      ),
    );
  }

  void _pickVideo() async {
    _videoUploadURL = await pickVideo();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.file(File(_videoUploadURL!))
      ..initialize().then((_) {
        setState(() {});
        _controller!.play();
      });
  }

  Widget _videoPreviewWidget() {
    if (_controller != null) {
      return Column(
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          ElevatedButton(
            onPressed: () {
              if (_isVideoSizeValid()) {
                _uploadVideo();
              } else {
                setState(() {
                  _errorMessage = "Error:upload the video below 10mb ";
                });
              }
            },
            child: const Text("Upload"),
          ),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
        ],
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  bool _isVideoSizeValid() {
    if (_videoUploadURL != null) {
      File videoFile = File(_videoUploadURL!);
      int fileSizeInBytes = videoFile.lengthSync();
      int fileSizeInMB = fileSizeInBytes ~/ (1024 * 1024);
      return fileSizeInMB <= 10;
    } else {
      print("Error: please select video");
      return false;
    }
  }

  void _uploadVideo() async {
    if (_videoUploadURL != null) {
      _downloadVideoURL = await StoreData().uploadVideo(_videoUploadURL!);
      await StoreData().saveVideoData(_downloadVideoURL!);
      setState(() {
        _videoUploadURL = null;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = "Error: Please select video";
      });
    }
  }
}

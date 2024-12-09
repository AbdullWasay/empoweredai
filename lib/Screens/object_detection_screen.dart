import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'mic_button.dart';

class ObjectDetectionScreen extends StatefulWidget {
  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  // Variable to hold the CameraController
  CameraController? _controller;
  late List<CameraDescription> cameras;
  bool _isCameraInitialized =
      false; // Flag to check camera initialization status

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialize camera
  void _initializeCamera() async {
    try {
      // Ensure we have the list of available cameras
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // Initialize the first camera found
        _controller = CameraController(cameras[0], ResolutionPreset.high);

        // Initialize the camera and handle errors
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true; // Camera is initialized
          });
        }
      } else {
        throw Exception("No cameras available");
      }
    } catch (e) {
      // Handle any errors during camera initialization
      print("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    // Dispose of the camera controller when the screen is destroyed
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator until the camera is initialized
    if (!_isCameraInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Object Detection'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Camera is initialized, display the camera preview
    return Scaffold(
      appBar: AppBar(
        title: Text('Object Detection'),
      ),
      body: Stack(
        children: [
          // Full-screen camera preview
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),
          // Add content on top of the camera preview
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Object Detection Mode',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                SizedBox(height: 20),
                // Add the MicButton widget for voice commands
                MicButton(
                  onCommandRecognized: (command) {
                    if (command.contains('open scene description')) {
                      Navigator.pushNamed(context, '/sceneDescription');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

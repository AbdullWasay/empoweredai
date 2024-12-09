// import 'dart:convert';
// import 'dart:io';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import 'mic_button.dart';
// import 'voice_command_handler.dart';

// // Make sure to initialize the camera before using
// List<CameraDescription> cameras = [];

// class SceneDescriptionScreen extends StatefulWidget {
//   @override
//   _SceneDescriptionScreenState createState() => _SceneDescriptionScreenState();
// }

// class _SceneDescriptionScreenState extends State<SceneDescriptionScreen> {
//   CameraController? _cameraController;
//   late VoiceCommandHandler voiceHandler;
//   bool _isCameraInitialized = false;
//   XFile? _capturedImage;

//   @override
//   void initState() {
//     super.initState();
//     voiceHandler = VoiceCommandHandler();

//     // Initialize the camera
//     initializeCamera();
//   }

//   // Initialize the camera
//   Future<void> initializeCamera() async {
//     if (cameras.isEmpty) {
//       cameras = await availableCameras();
//     }

//     // Select the first camera (usually the back camera)
//     _cameraController = CameraController(cameras[0], ResolutionPreset.medium);

//     // Initialize the controller
//     await _cameraController?.initialize();
//     setState(() {
//       _isCameraInitialized = true;
//     });
//   }

//   // Capture image using the camera
//   Future<void> captureImage() async {
//     if (_cameraController != null && _cameraController!.value.isInitialized) {
//       final image = await _cameraController!.takePicture();
//       setState(() {
//         _capturedImage = image;
//       });
//       await voiceHandler.speak("Image captured successfully");

//       // Send the image to the backend for description
//       await sendImageToBackend(image);
//     }
//   }

//   Future<void> sendImageToBackend(XFile image) async {
//     final uri = Uri.parse(
//         'http://<your_backend_ip>/process_image'); // Replace with your backend URL

//     try {
//       // Create a multipart request to send the image
//       var request = http.MultipartRequest('POST', uri)
//         ..files.add(await http.MultipartFile.fromPath('image', image.path));

//       var response = await request.send();

//       if (response.statusCode == 200) {
//         // If the request is successful, read the response
//         final responseData = await response.stream.bytesToString();
//         final description = jsonDecode(responseData)[
//             'description']; // Assuming your backend returns a 'description'

//         // Convert the description to speech
//         await voiceHandler.speak(description);
//       } else {
//         // Handle error response from the server
//         await voiceHandler.speak("Failed to get description from the server");
//       }
//     } catch (e) {
//       await voiceHandler.speak("Error occurred while processing the image");
//       print('Error: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Scene Description'),
//       ),
//       body: _isCameraInitialized
//           ? Stack(
//               children: [
//                 // Display the camera preview
//                 CameraPreview(_cameraController!),
//                 // Display the microphone button
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: MicButton(
//                     onCommandRecognized: (command) {
//                       if (command.contains('capture image')) {
//                         captureImage();
//                       } else if (command.contains('open object detection')) {
//                         Navigator.pushNamed(context, '/objectDetection');
//                       }
//                     },
//                   ),
//                 ),
//                 if (_capturedImage != null)
//                   Align(
//                     alignment: Alignment.bottomLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Container(
//                         width: 100,
//                         height: 100,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.white, width: 2),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Image.file(
//                           File(_capturedImage!.path),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             )
//           : Center(child: CircularProgressIndicator()),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:empoweredai/Screens/mic_button.dart';
import 'package:empoweredai/Screens/voice_command_handler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Make sure to initialize the camera before using
List<CameraDescription> cameras = [];

class SceneDescriptionScreen extends StatefulWidget {
  @override
  _SceneDescriptionScreenState createState() => _SceneDescriptionScreenState();
}

class _SceneDescriptionScreenState extends State<SceneDescriptionScreen> {
  CameraController? _cameraController;
  late VoiceCommandHandler voiceHandler;
  bool _isCameraInitialized = false;
  XFile? _capturedImage;
  String description = '';
  String audioUrl = '';

  @override
  void initState() {
    super.initState();
    voiceHandler = VoiceCommandHandler();

    // Initialize the camera
    initializeCamera();
  }

  // Initialize the camera
  Future<void> initializeCamera() async {
    if (cameras.isEmpty) {
      cameras = await availableCameras();
    }

    // Select the first camera (usually the back camera)
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);

    // Initialize the controller
    await _cameraController?.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  // Capture image using the camera
  Future<void> captureImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final image = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = image;
      });
      await voiceHandler.speak("Image captured successfully");

      // Send the captured image to the backend for description generation
      await sendImageToBackend(image);
    }
  }

  Future<void> sendImageToBackend(XFile image) async {
    final uri = Uri.parse('http://<your_backend_ip>:5000/generate_description');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);
      setState(() {
        description = jsonResponse['description'];
        audioUrl = jsonResponse['audio_file'];
      });

      // Optionally, play the audio if needed
      // Use an audio player to play the audio file from audioUrl
    } else {
      print("Failed to get description");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scene Description'),
      ),
      body: _isCameraInitialized
          ? Stack(
              children: [
                // Display the camera preview
                CameraPreview(_cameraController!),
                // Display the microphone button
                Align(
                  alignment: Alignment.bottomCenter,
                  child: MicButton(
                    onCommandRecognized: (command) {
                      if (command.contains('capture image')) {
                        captureImage();
                      } else if (command.contains('open object detection')) {
                        Navigator.pushNamed(context, '/objectDetection');
                      }
                    },
                  ),
                ),
                if (_capturedImage != null)
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.file(
                          File(_capturedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                if (description.isNotEmpty)
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                      padding: EdgeInsets.all(16),
                      child: Text(
                        description,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

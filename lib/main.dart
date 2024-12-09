// import 'package:empoweredai/Screens/camera_page.dart';
// import 'package:empoweredai/Screens/notification_page.dart';
// import 'package:empoweredai/Screens/video_page.dart';
// import 'package:flutter/material.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // No changes needed here unless you updated the package names.

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Empowered AI',
//       theme: ThemeData(
//         primarySwatch: Colors.grey,
//         brightness: Brightness.dark,
//       ),
//       home: const HomePage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final PageController _pageController = PageController(initialPage: 1);
//   int _currentIndex = 1;

//   final List<Widget> _pages = [
//     const VideosPage(),
//     const CameraPage(),
//     const NotificationsPage(),
//   ];

//   void onPageChanged(int index) {
//     setState(() => _currentIndex = index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         // Using Stack to overlay the top app bar
//         children: [
//           PageView(
//             controller: _pageController,
//             onPageChanged: onPageChanged,
//             children: _pages,
//           ),
//           // Top App Bar
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: AppBar(
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//               leading: IconButton(
//                 icon: const Icon(Icons.person_outline),
//                 onPressed: () {
//                   // Profile action
//                 },
//               ),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.notifications_none_rounded),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const NotificationsPage(),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//               centerTitle: true,
//               title: GestureDetector(
//                 onTap: () {
//                   // Snap Map or other action
//                 },
//                 child: const Text(
//                   'EMPOWERED AI',
//                   style: TextStyle(fontFamily: 'Billabong', fontSize: 28),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:camera/camera.dart';
import 'package:empoweredai/Screens/mic_button.dart';
import 'package:empoweredai/Screens/object_detection_screen.dart';
import 'package:empoweredai/Screens/scene_description_screen.dart';
import 'package:empoweredai/Screens/voice_command_handler.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  VoiceCommandHandler voiceHandler = VoiceCommandHandler();
  await voiceHandler.initializeVoiceRecognition();

  // Initialize cameras before the app runs
  cameras = await availableCameras();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Navigation App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/objectDetection': (context) => ObjectDetectionScreen(),
        '/sceneDescription': (context) => SceneDescriptionScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Navigation App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Voice Navigation App'),
            SizedBox(height: 20),
            // Add the MicButton widget here as well
            MicButton(
              onCommandRecognized: (command) {
                if (command.contains('open object detection')) {
                  Navigator.pushNamed(context, '/objectDetection');
                } else if (command.contains('open scene description')) {
                  Navigator.pushNamed(context, '/sceneDescription');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'voice_command_handler.dart';

class MicButton extends StatefulWidget {
  final Function(String)? onCommandRecognized;

  MicButton({this.onCommandRecognized});

  @override
  _MicButtonState createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> {
  final VoiceCommandHandler voiceHandler = VoiceCommandHandler();
  bool isListening = false;

  @override
  void initState() {
    super.initState();
  }

  // Method to handle listening start/stop
  void _toggleListening() async {
    if (isListening) {
      voiceHandler.stopListening();
      setState(() {
        isListening = false;
      });
    } else {
      setState(() {
        isListening = true;
      });
      await voiceHandler.listen((command) {
        widget.onCommandRecognized?.call(command);
        setState(() {
          isListening = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.mic,
        size: 80,
        color: isListening ? Colors.red : Colors.blue,
      ),
      onPressed: _toggleListening,
    );
  }
}

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceCommandHandler {
  static final VoiceCommandHandler _instance = VoiceCommandHandler._internal();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  factory VoiceCommandHandler() {
    return _instance;
  }

  VoiceCommandHandler._internal();

  Future<void> initializeVoiceRecognition() async {
    await _speechToText.initialize();
  }

  Future<void> listen(Function(String) onCommandRecognized) async {
    if (_speechToText.isAvailable) {
      _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            String command = result.recognizedWords.toLowerCase();
            onCommandRecognized(command);
          }
        },
        listenMode: stt.ListenMode.dictation,
      );
    }
  }

  void stopListening() {
    if (_speechToText.isListening) {
      _speechToText.stop();
    }
  }

  Future<void> speak(String text) async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.speak(text);
  }
}

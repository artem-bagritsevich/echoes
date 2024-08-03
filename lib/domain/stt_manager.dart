import 'dart:developer';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechToTextManager {
  final SpeechToText _speechToText = SpeechToText();
  bool isListening = false;

  late final QuestionObserver _observer;

  SpeechToTextManager(QuestionObserver observer) {
    _observer = observer;
  }

  void startListeningForQuestion() async {
    log("startListeningForQuestion");
    if (!isListening) {
      bool isReady = await _speechToText.initialize(
          onError: (e) =>
              {_observer.onError("Speech recognition error occured.")});
      if (isReady) {
        await _speechToText.listen(
          listenFor: const Duration(seconds: 20),
          pauseFor: const Duration(seconds: 2),
          onResult: (result) => _processSTTResult(result),
        );
      } else {
        log("SpeechToTextManager:startListeningForQuestion:isReady=false");
        _observer.onError("Speech recognition error occured.");
      }
    } else {
      log("SpeechToTextManager:startListeningForQuestion:isListening=true");
      _observer.onError("Speech recognition error occured.");
    }
  }

  Future<void> stopListening() {
    return _speechToText.stop();
  }

  void _processSTTResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      if (result.confidence >= 0.7) {
        var question = result.recognizedWords;
        if (question.isNotEmpty) {
          _observer.onQuestionRecognized(question);
        } else {
          _observer.onError(
              "I am not able to recognize your question, please try again.");
        }
      } else {
        _observer.onError(
            "I am not able to recognize your question, please try again.");
      }
      _speechToText.stop();
      isListening = false;
    }
  }
}

abstract class QuestionObserver {
  void onQuestionRecognized(String question);
  void onError(String error);
}

class DefaultQuestionObserver extends QuestionObserver {
  Function(String) onErrorCallback;
  Function(String) onQuestionRecognizedCallback;

  DefaultQuestionObserver(
      {required this.onErrorCallback,
      required this.onQuestionRecognizedCallback});

  @override
  void onError(String error) {
    onErrorCallback(error);
  }

  @override
  void onQuestionRecognized(String question) {
    onQuestionRecognizedCallback(question);
  }
}

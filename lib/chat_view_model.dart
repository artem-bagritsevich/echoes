import 'dart:developer';

import 'package:echoes/domain/audio_manager.dart';
import 'package:echoes/domain/file_manager.dart';

import 'domain/ai_manager.dart';
import 'package:echoes/domain/stt_manager.dart';
import 'package:echoes/domain/tts_manager.dart';

import 'mvvm/view_model.dart';
import 'mvvm/view_state_observer.dart';

class ChatViewModel extends EventViewModel {
  ChatViewState _currentViewState = IdleState();

  late final SpeechToTextManager _sst;
  final TTSManager _tts = TTSManager();
  final AIManager _aiManager = AIManager();
  final FileManager _fileManager = FileManager();
  late final AudioManager _audioManager = AudioManager();

  ChatViewModel() {
    _sst = SpeechToTextManager(DefaultQuestionObserver(
        onErrorCallback: _onQuestionRecognitionError,
        onQuestionRecognizedCallback: _onQuestionRecognized));
  }

  void onMicButtonClick() {
    switch (_currentViewState) {
      case IdleState _:
        _startAskingState();
      case AskingState _:
        _stopAskingState();
      case ThingkingState _:
        _stopEverythingAndGoToIdle();
      case AnsweringState _:
        _stopEverythingAndGoToIdle();
      case ErrorState _:
        _handleErrorState();
    }
  }

  void onErrorDialogClosed() {
    _changeState(IdleState());
  }

  void _handleErrorState() {
    onErrorDialogClosed();
    _startAskingState();
  }

  void _startAskingState() {
    // initiate asking state, and wait for the answer to be recognized
    if (_sst.isListening) {
      log("Already listening");
      return; // we are already listening for question from the user
    }
    _sst.startListeningForQuestion();
    _changeState(AskingState());
  }

  void _stopAskingState() {
    // User does not want to wait for the answer, so stop listening
    _sst.stopListening();
    _changeState(IdleState());
  }

  void _stopEverythingAndGoToIdle() async {
    _sst.stopListening();
    await _audioManager.release();
    _changeState(IdleState());
  }

  void _onQuestionRecognitionError(String error) {
    log("_onQuestionRecognitionError: $error");
    _changeState(ErrorState(errorText: error));
  }

  void _onQuestionRecognized(String question) async {
    log("Question recognized: $question");
    _changeState(ThingkingState());

    var answer = await _aiManager.getAIAnswer(question);

    if (answer == null || answer.isEmpty) {
      _changeState(ErrorState(
          errorText: "Im not able to answer your question, please ask again."));
      return;
    }

    log("On answer received: $answer");
    try {
      var audioAnswer = await _tts.transformTextToBase64Mp3Audio(answer);
      var audioFile = await _fileManager.createAudioFile(audioAnswer);
      _changeState(AnsweringState()); // audio answer received, ready to play
      await _audioManager.playBase64MP3Audio(audioFile);
      await _audioManager.getPlayerCompleteStream().first;
      await _audioManager.release();
      await _fileManager.deleteAudioFile();
      _changeState(IdleState()); // going back Idle state after play completed
    } catch (e) {
      _changeState(ErrorState(errorText: "Unable to play answer."));
    }
  }

  void _changeState(ChatViewState state) {
    _currentViewState = state;
    notify(_currentViewState);
  }
}

sealed class ChatViewState extends ViewState {}

class IdleState extends ChatViewState {}

class AskingState extends ChatViewState {}

class ThingkingState extends ChatViewState {}

class AnsweringState extends ChatViewState {}

class ErrorState extends ChatViewState {
  final String errorText;
  ErrorState({required this.errorText});
}

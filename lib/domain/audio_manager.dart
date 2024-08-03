import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

const String filename = 'temp_audio.mp3';

class AudioManager {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playBase64MP3Audio(File audioFile) async {
    // Play the audio using audioplayer
    await _audioPlayer.play(DeviceFileSource(audioFile.path));
  }

  Stream<void> getPlayerCompleteStream() {
    return _audioPlayer.onPlayerComplete;
  }

  Future<void> release() {
    _audioPlayer.stop();
    return _audioPlayer.release();
  }
}

import 'dart:io';
import 'dart:developer';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

const String filename = 'temp_audio.mp3';

class FileManager {
  late final String _tempFilePath;

  FileManager() {
    _initTempFilePath();
  }

  Future<File> createAudioFile(String base64Audio) async {
    // Decode the base64 audio
    final audioContent = base64Decode(base64Audio);

    File tempFile = File(_tempFilePath);
    if (await tempFile.exists()) {
      log("Deliting old temp file");
      await tempFile.delete();
    }
    log("Creationg new temp file");
    await tempFile.create();
    log("Writing audio data to tempFile");
    return await tempFile.writeAsBytes(audioContent);
  }

  Future<void> deleteAudioFile() async {
    await File(_tempFilePath).delete();
  }

  void _initTempFilePath() async {
    _tempFilePath =
        "${(await getApplicationDocumentsDirectory()).path}/$filename";
  }
}

import 'dart:convert';
import "package:http/http.dart" as http;
import 'dart:developer' as developer;
import 'package:echoes/constants.dart';

const String _baseUrl =
    'https://texttospeech.googleapis.com/v1beta1/text:synthesize';

class TTSManager {
  Future<String> transformTextToBase64Mp3Audio(String text) async {
    // Create the authorization header
    const authorizationHeader = 'Bearer $googleCloudAccessToken';
    // Send the POST request
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authorizationHeader,
        'x-goog-user-project': gooogleCloudProjectId
      },
      body: _getRequestTTSBody(text),
    );
    if (response.statusCode == 200) {
      // Handle the synthesized audio response (base64 encoded)
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final audioContentBase64 = responseBody['audioContent'];
      return audioContentBase64;
    } else {
      developer.log('Error synthesizing text: ${response.statusCode}');
      throw Exception("Unable to synthesize audio.");
    }
  }

  String _getRequestTTSBody(String text) {
    final body = {
      'input': {
        'text': text,
      },
      'voice': {
        'languageCode': 'en-GB',
        'name': 'en-GB-Standard-D',
      },
      'audioConfig': {
        'audioEncoding': 'MP3',
        'effectsProfileId': ['handset-class-device'],
        'speakingRate': 0.95,
        'pitch': -10
      },
    };
    return jsonEncode(body);
  }
}

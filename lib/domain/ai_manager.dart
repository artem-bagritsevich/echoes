import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:echoes/constants.dart';

const systemInstruction = """
You are an ancient Greek philosopher Aristotle who died a long time ago, but we can communicate with you.

Keep your answers under 2 paragraphs long, and use a formal but accessible tone in your answers.

Rely on logic, reason, and Aristotle's books. Provide well-researched and accurate information in a clear and concise manner.

Present information in a way that encourages people to think critically and ask further questions.

Don't use text formatting like asterisks or quotes. Use only basic punctuation.
""";

const geminiVersion = 'gemini-1.5-pro-latest';
const textMimeType = 'text/plain';

class AIManager {
  late final GenerativeModel _gemini;
  late final ChatSession _chat;
  AIManager() {
    _gemini = GenerativeModel(
        model: geminiVersion,
        apiKey: geminiApiKey,
        systemInstruction: Content.text(systemInstruction),
        generationConfig: GenerationConfig(
          temperature: 1.0,
          topK: 64,
          topP: 0.95,
          maxOutputTokens: 8192,
          responseMimeType: textMimeType,
        ),
        safetySettings: _getSafetySettings());
    _chat = _gemini.startChat();
  }

  Future<String?> getAIAnswer(String question) async {
    var response = await _chat.sendMessage(Content.text(question));
    return response.text;
  }

  List<SafetySetting> _getSafetySettings() {
    return [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high)
    ];
  }
}

import 'package:http/http.dart' as http;
import 'dart:convert';

class AIChatService {
  final String apiKey = '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'; // Replace with your key

  Future<String> getChatResponse(String prompt) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final message = data['choices'][0]['message']['content'];
      return message;
    } else {
      throw Exception('Failed to fetch AI response');
    }
  }
}

// lib/features/ai_chat/data/gemini_chat_service.dart
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart' show GenerativeModel, Content, Part, TextPart, GenerativeModel, Content, GenerationConfig;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Keep if you're using dotenv

// IMPORTANT: The apiKey should be an empty string if running in Canvas.
// Canvas automatically provides it. If deploying your own app,
// you'd typically load it from dotenv or environment variables.
const String _geminiApiKey = ''; // Default for Canvas, actual value from dotenv.env['GEMINI_API_KEY'] if that's your deployment method

/// Generates a response from the Gemini model for a chat conversation.
/// It takes initial context (like recipe details) and the ongoing chat history.
///
/// [initialContextParts]: A list of Content Parts (e.g., TextPart) that set the stage
///   for the AI (e.g., recipe description, ingredients, instructions). This acts
///   like a "system message" or initial prompt to guide the AI.
/// [chatHistory]: The ongoing conversation history, as a list of Content objects.
///   Each Content object represents a turn in the conversation (user or model).
Future<String> generateChatResponse({
  required List<Content> initialContextParts,
  required List<Content> chatHistory,
}) async {
  final String? actualApiKey = _geminiApiKey.isEmpty ? dotenv.env['GEMINI_API_KEY'] : _geminiApiKey;

  final model = GenerativeModel(
    model: 'gemini-2.0-flash', // Flash is generally faster and cheaper for chat
    apiKey: actualApiKey ?? '',
  );

  // Combine initial context with the ongoing chat history
  // The AI will see the initial context first, then the conversation.
  final fullChatHistory = [...initialContextParts, ...chatHistory];

  try {
    final response = await model.generateContent(
      fullChatHistory,
      generationConfig: GenerationConfig(
        temperature: 0.7, // Adjust creativity (0.0-1.0), lower for more factual
        maxOutputTokens: 500, // Limit response length
      ),
    );

    // Get the text from the first candidate
    final String aiTextResponse = response.text ?? 'I could not generate a response.';
    return aiTextResponse;

  } catch (e) {
    print('Error generating AI chat response: $e');
    // For quota errors, provide a user-friendly message
    if (e.toString().contains('quota')) {
      return "I've hit my usage limit right now. Please try again later!";
    }
    return 'An error occurred while getting a response: ${e.toString()}';
  }
}

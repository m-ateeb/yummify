// lib/features/ai_chat/data/ai_chat_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart' show Content;
import 'gemini_chat_service.dart'; // Import the new chat service

// Provider for the Gemini chat service function
final geminiChatServiceProvider = Provider<Future<String> Function({
required List<Content> initialContextParts,
required List<Content> chatHistory,
})>((ref) {
  return generateChatResponse;
});

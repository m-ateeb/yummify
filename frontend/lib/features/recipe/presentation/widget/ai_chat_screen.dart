// lib/features/ai_chat/presentation/screens/ai_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart' show Content, TextPart;

// Adjust import paths to your project structure
import 'package:frontend/features/recipe/domain/recipe_entity.dart';
import '../../data/ai_chat_providers.dart'; // New providers for chat service

class AiChatScreen extends ConsumerStatefulWidget {
  final RecipeEntity recipe;

  const AiChatScreen({super.key, required this.recipe});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Stores the chat history (user and model messages)
  // Each map has 'role' ('user' or 'model') and 'message'
  final List<Map<String, String>> _messages = [];

  bool _isSending = false; // To manage loading state for sending messages

  @override
  void initState() {
    super.initState();
    _initializeChatWithRecipeContext();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Pre-populate chat with recipe context as a "system" message (or initial AI intro)
  void _initializeChatWithRecipeContext() {
    // This part is the AI's first message, greeting the user
    _messages.add({
      'role': 'model',
      'message': 'Hello! I am your AI recipe assistant for "${widget.recipe.name}". How can I help you with this recipe today?'
    });
    // Ensure scroll to bottom after initial message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  // Scrolls the chat list to the bottom
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Sends the user's message and gets AI response
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'message': text});
      _messageController.clear();
      _isSending = true; // Start loading indicator
    });

    _scrollToBottom(); // Scroll to bottom immediately after user sends message

    // --- Prepare initial context for AI (MODIFIED FOR FLEXIBILITY & CONSISTENCY) ---
    // This string acts as a system-level instruction for the AI's persona and context.
    // It is sent as the very first 'user' turn to establish the conversation's foundation.
    final String initialContextString = """
You are an expert culinary assistant named "Chef AI". Your main goal is to provide helpful and insightful information about the following recipe, and general cooking advice related to it. You are friendly and knowledgeable.

**Recipe Details:**
Recipe Name: ${widget.recipe.name}
Total Time: ${widget.recipe.totaltime} minutes
Cuisine: ${widget.recipe.cuisine}
Serving: ${widget.recipe.servingSize} (${widget.recipe.servingDescription})

Ingredients:
${widget.recipe.ingredients.map((ing) => '- ${ing.qty} ${ing.unit} ${ing.name}${ing.note != null && ing.note!.isNotEmpty ? ' (${ing.note})' : ''}').join('\n')}

Instructions:
${widget.recipe.instructionSet.asMap().entries.map((e) => '${e.key + 1}. ${e.value.description}').join('\n')}

Description:
${widget.recipe.descriptionBlocks.map((block) => '${block.heading1}: ${block.body}').join('\n\n')}

Nutrition (per serving):
Calories: ${widget.recipe.nutrition.calories} kcal, Carbs: ${widget.recipe.nutrition.carbsG}g, Fat: ${widget.recipe.nutrition.fatG}g, Fiber: ${widget.recipe.nutrition.fiberG}g, Protein: ${widget.recipe.nutrition.proteinG}g

---
**Your Guidance for responding to the user:**
- Use the provided recipe details as the primary context for your answers.
- If a question can be answered by drawing a reasonable inference or providing common culinary knowledge related to the recipe or its ingredients, feel free to do so.
- For example, if asked for a substitute for an ingredient, you can suggest common alternatives. If asked about a cooking technique mentioned, you can elaborate on it.
- If a question is entirely unrelated to the recipe or general cooking, gently steer the conversation back to food and recipes.
- Always provide a direct answer to the current question if possible, without referring to previous turns being unanswered.
- Maintain a friendly, helpful, and knowledgeable tone.
---
""";

    // Convert the current chat history (including the latest user message just added to _messages)
    // to Content format for Gemini API.
    // This list will be the actual `List<Content>` for the Gemini API call.
    final List<Content> chatHistoryForGemini = [];

    // Add the initial context as the very first 'user' turn.
    chatHistoryForGemini.add(Content('user', [TextPart(initialContextString)]));

    // Then, add the actual user-model conversation turns.
    // We start from index 0 because _messages already contains the initial model greeting
    // and the new user message.
    for (var i = 0; i < _messages.length; i++) {
      final message = _messages[i];
      chatHistoryForGemini.add(
        Content(
          message['role']!, // 'user' or 'model'
          [TextPart(message['message']!)],
        ),
      );
    }

    // DEBUGGING: Print the full history being sent to Gemini
    print("--- Full Chat History Sent to Gemini ---");
    for (var content in chatHistoryForGemini) {
      print("Role: ${content.role}, Parts: ${content.parts.map((p) => p is TextPart ? p.text : 'Non-text Part').join()}");
    }
    print("---------------------------------------");

    try {
      final chatService = ref.read(geminiChatServiceProvider);
      // Pass the fully constructed history to the service.
      // The service itself just needs the list of Content.
      final aiResponse = await chatService(
        initialContextParts: [], // No longer used as a separate parameter here
        chatHistory: chatHistoryForGemini, // The single, combined list
      );

      setState(() {
        _messages.add({'role': 'model', 'message': aiResponse});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'model', 'message': 'Error: Could not get a response. ${e.toString()}'});
      });
    } finally {
      setState(() {
        _isSending = false; // End loading
      });
      _scrollToBottom(); // Scroll to bottom after AI response
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat about: ${widget.recipe.name}'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16.0).copyWith(
                        bottomLeft: isUser ? const Radius.circular(16.0) : const Radius.circular(4.0),
                        bottomRight: isUser ? const Radius.circular(4.0) : const Radius.circular(16.0),
                      ),
                    ),
                    child: Text(
                      message['message']!,
                      style: TextStyle(
                        color: isUser ? Colors.blue.shade900 : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isSending)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask about this recipe...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    ),
                    onSubmitted: (text) => _sendMessage(), // Send on Enter
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _isSending ? null : _sendMessage,
                  mini: true,
                  backgroundColor: Colors.blue.shade500,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  child: _isSending
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

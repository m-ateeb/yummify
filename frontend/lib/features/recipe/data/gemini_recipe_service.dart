import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart'
    show GenerativeModel, Content, GenerationConfig, Schema, SchemaType;
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../domain/recipe_entity.dart';

// Environment-based API key loading
const String _geminiApiKey = '';

Future<RecipeEntity?> generateRecipeWithGemini({
  required String recipeRequest,
  required String userId,
  required String role,
}) async {
  final String? actualApiKey =
  _geminiApiKey.isEmpty ? dotenv.env['GEMINI_API_KEY'] : _geminiApiKey;

  final model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: actualApiKey ?? '',
  );

  final recipeSchema = Schema(
    SchemaType.object,
    properties: {
      'name': Schema(SchemaType.string),
      'img': Schema(SchemaType.string),
      'totaltime': Schema(SchemaType.integer),
      'tags': Schema(SchemaType.array, items: Schema(SchemaType.string)),
      'writer': Schema(SchemaType.string),
      'cuisine': Schema(SchemaType.string),
      'status': Schema(SchemaType.string, enumValues: ['public', 'private', 'draft']),
      'serving_description': Schema(SchemaType.string),
      'serving_size': Schema(SchemaType.string),
      'searchIndex': Schema(SchemaType.array, items: Schema(SchemaType.string)),
      'ingredients': Schema(
        SchemaType.array,
        items: Schema(
          SchemaType.object,
          properties: {
            'qty': Schema(SchemaType.number),
            'unit': Schema(SchemaType.string),
            'name': Schema(SchemaType.string),
            'note': Schema(SchemaType.string, nullable: true),
          },
        ),
      ),
      'descriptionBlocks': Schema(
        SchemaType.array,
        items: Schema(
          SchemaType.object,
          properties: {
            'heading1': Schema(SchemaType.string),
            'body': Schema(SchemaType.string),
            'image': Schema(SchemaType.string),
          },
        ),
      ),
      'instructionSet': Schema(
        SchemaType.array,
        items: Schema(
          SchemaType.object,
          properties: {
            'description': Schema(SchemaType.string),
          },
        ),
      ),
      'nutrition': Schema(
        SchemaType.object,
        properties: {
          'calories': Schema(SchemaType.number),
          'carbs_g': Schema(SchemaType.number),
          'fat_g': Schema(SchemaType.number),
          'fiber_g': Schema(SchemaType.number),
          'protein_g': Schema(SchemaType.number),
        },
      ),
      'review': Schema(SchemaType.number),
      'createdAt': Schema(SchemaType.string),
      'updatedAt': Schema(SchemaType.string),
    },
  );

  final content = [
    Content.text("""
You are an expert recipe generator. Create a full recipe that fits the user's request in a detailed JSON format that matches the provided schema.

**User Request:**
$recipeRequest

**Constraints:**
- Use realistic cooking times and nutritional values.
- Use placeholder image URLs (e.g., https://picsum.photos/800x600).
- Fill out all required fields in the JSON response.
- Ensure all timestamps are in ISO8601 format (e.g., 2025-06-14T20:30:00.000Z).
"""),
  ];

  try {
    final response = await model.generateContent(
      content,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: recipeSchema,
      ),
    );

    print("Gemini Response:");
    print(response.text);

    if (response.text == null || response.text!.trim().isEmpty) {
      print("Empty response from Gemini.");
      return null;
    }

    final rawJson = jsonDecode(response.text!);

    final currentTime = DateTime.now().toUtc();
    rawJson['createdAt'] ??= currentTime.toIso8601String();
    rawJson['updatedAt'] ??= currentTime.toIso8601String();

    // Inject userId and role
    rawJson['userId'] = userId;
    rawJson['role'] = role;

    // Assign ID manually
    final String newId = const Uuid().v4();
    final recipe = RecipeEntity.fromMap(rawJson, newId);

    // Basic validation
    if (recipe.name.isEmpty || recipe.ingredients.isEmpty || recipe.instructionSet.isEmpty) {
      print("Incomplete recipe data. Skipping.");
      return null;
    }

    print("Recipe generated: ${recipe.name}");
    return recipe;
  } catch (e) {
    print("Error: $e");
    if (e is FormatException) {
      print("JSON Format Exception: ${e.message}");
    }
    return null;
  }
}

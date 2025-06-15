import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../domain/recipe_entity.dart';
import '../../data/recipe_repository_provider.dart'; // Import your
import 'package:frontend/providers/providers.dart';// providers file
import '../widget/ai_chat_screen.dart';
class RecipeDetailScreen extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  final RecipeEntity recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState(); // Changed state class
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  late List<bool> _checkedIngredients;

  @override
  void initState() {
    super.initState();
    _checkedIngredients = List.filled(widget.recipe.ingredients.length, false);
  }

  Future<void> _submitRating(double newRating) async {
    // Access ref via `widget.ref`
    final userIdAsyncValue = ref.read(userIdProvider); // CORRECTED LINE

    final userId = userIdAsyncValue.when(
      data: (uid) => uid,
      loading: () => null,
      error: (err, stack) => null,
    );

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to rate this recipe!")),
      );
      return;
    }

    // Access ref via `widget.ref`
    final oldRatingAsyncValue = ref.read(userRecipeRatingProvider(widget.recipe.id)); // CORRECTED LINE
    final oldRating = oldRatingAsyncValue.when(
      data: (rating) => rating,
      loading: () => 0.0,
      error: (err, stack) {
        print('Error getting old rating: $err');
        return 0.0;
      },
    );

    try {
      final repo = ref.read(recipeRepositoryProvider); // CORRECTED LINE
      await repo.updateRecipeRating(
        recipeId: widget.recipe.id,
        userId: userId,
        newRating: newRating,
        oldRating: oldRating,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You rated this recipe ${newRating.toStringAsFixed(1)} stars!")),
      );
    } catch (e) {
      print('Error submitting rating: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit rating: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access ref via `widget.ref`
    final recipeAsyncValue = ref.watch(singleRecipeProvider(widget.recipe.id)); // CORRECTED LINE

    // Access ref via `widget.ref`
    final userRatingAsyncValue = ref.watch(userRecipeRatingProvider(widget.recipe.id)); // CORRECTED LINE

    return Scaffold(
      backgroundColor: Colors.white, // Modern B&W background
      appBar: AppBar(
        backgroundColor: Colors.black, // Modern B&W app bar
        foregroundColor: Colors.white, // Text and icons white
        elevation: 0, // No shadow for a flatter look
        title: Text(widget.recipe.name, // Use widget.recipe.name for app bar title
            style: const TextStyle(
                fontFamily: 'Montserrat', // Modern font
                fontSize: 20)),
        centerTitle: true,
      ),
      body: recipeAsyncValue.when( // Handle loading, data, and error states for the recipe
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (err, stack) => Center(child: Text('Error loading recipe: $err')),
        data: (recipe) { // Use the `recipe` object from the provider's data
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipe Header: Name, Author, Rating
                    Center(
                      child: Column(
                        children: [
                          Text(
                            recipe.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Montserrat',
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "by ${recipe.writer}",
                            style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 12),
                          // Displaying Average Rating and Count
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star_rounded, color: Colors.amber[700], size: 24),
                              const SizedBox(width: 4),
                              Text(
                                recipe.averageRating.toStringAsFixed(1), // Use averageRating
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                " (${recipe.ratingCount} ratings)", // Use ratingCount
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // User Rating Section
                          userRatingAsyncValue.when(
                            loading: () => const SizedBox(
                                height: 40,
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey))),
                            error: (err, stack) => Text('Error loading your rating: $err'),
                            data: (userRating) {
                              return Column(
                                children: [
                                  Text(
                                    userRating > 0 ? "Your Rating:" : "Rate this Recipe:",
                                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                                  ),
                                  const SizedBox(height: 8),
                                  RatingBar.builder(
                                    initialRating: userRating, // Shows user's existing rating
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 32.0,
                                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      _submitRating(rating);
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Description Blocks
                    ...recipe.descriptionBlocks.map((block) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              block.heading1,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                height: 200, // Fixed height for a consistent look
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(block.image),
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              block.body,
                              style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Ingredients Section with old notebook feel
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDFDFD), // Off-white for notebook paper
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Ingredients",
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'RobotoSlab', // A slightly more rustic font
                                color: Colors.black87),
                          ),
                          const Divider(color: Colors.grey, thickness: 0.8, height: 24),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recipe.ingredients.length,
                            itemBuilder: (context, i) {
                              final ing = recipe.ingredients[i];
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                decoration: BoxDecoration(
                                  color: _checkedIngredients[i] ? Colors.grey[200] : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: CheckboxListTile(
                                  value: _checkedIngredients[i],
                                  onChanged: (val) {
                                    setState(() => _checkedIngredients[i] = val!);
                                  },
                                  title: Text(
                                    "${ing.qty} ${ing.unit} ${ing.name}${ing.note != null ? ' (${ing.note})' : ''}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      decoration: _checkedIngredients[i]
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      decorationColor: Colors.black54,
                                    ),
                                  ),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  activeColor: Colors.black, // Black checkmark
                                  checkColor: Colors.white, // White square
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_outlined, color: Colors.black54, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  "${recipe.totaltime} mins",
                                  style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Instructions
                    const Text(
                      "Instructions",
                      style: TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Montserrat', color: Colors.black),
                    ),
                    const Divider(color: Colors.grey, thickness: 0.8, height: 24),
                    ...recipe.instructionSet.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade400)
                              ),
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                step.description,
                                style: const TextStyle(fontSize: 16.5, height: 1.5, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 60), // More space at the bottom

                    // The End Banner
                    Center(
                      child: Text(
                        "— End of Recipe —",
                        style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Montserrat',
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade600),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
              // AI Chatbot Button (positioned at bottom right)
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AiChatScreen(recipe: recipe)));
                  },
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.chat_bubble_outline_rounded, size: 28),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
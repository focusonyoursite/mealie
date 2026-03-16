import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../database/database_helper.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    List<String> ingredients = [];
    List<String> instructions = [];

    try {
      ingredients = List<String>.from(jsonDecode(recipe.ingredients));
    } catch(e) {
      ingredients = [recipe.ingredients];
    }

    try {
      instructions = List<String>.from(jsonDecode(recipe.instructions));
    } catch(e) {
      instructions = [recipe.instructions];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
               if (recipe.id != null) {
                  await DatabaseHelper.instance.delete(recipe.id!);
                  if (context.mounted) {
                     Navigator.pop(context);
                  }
               }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (recipe.imageUrl != null)
              Image.network(
                recipe.imageUrl!,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (recipe.prepTime != null)
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 20),
                        const SizedBox(width: 4),
                        Text(recipe.prepTime!),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (recipe.description != null) ...[
                     Text(recipe.description!, style: Theme.of(context).textTheme.bodyMedium),
                     const SizedBox(height: 16),
                  ],
                  Text('Ingrediënten', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...ingredients.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Expanded(child: Text(i)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 16),
                  Text('Instructies', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...instructions.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${entry.key + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Expanded(child: Text(entry.value)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

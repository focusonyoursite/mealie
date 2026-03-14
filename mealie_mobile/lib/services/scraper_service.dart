import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import '../models/recipe.dart';

class ScraperService {
  Future<Recipe?> scrapeRecipe(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = parse(response.body);

        // Find all script tags
        final scripts = document.getElementsByTagName('script');

        for (var script in scripts) {
          if (script.attributes['type'] == 'application/ld+json') {
            final jsonStr = script.text;
            if (jsonStr.isNotEmpty) {
               try {
                  dynamic jsonData = jsonDecode(jsonStr);

                  // JSON-LD can be a single object or a list of objects (like a Graph)
                  if (jsonData is List) {
                    for (var item in jsonData) {
                      if (_isRecipeNode(item)) {
                        return _parseRecipe(item, url);
                      }
                    }
                  } else if (jsonData is Map) {
                     // Sometimes it is nested inside @graph
                     if (jsonData.containsKey('@graph')) {
                        var graph = jsonData['@graph'];
                        if (graph is List) {
                           for (var item in graph) {
                             if (_isRecipeNode(item)) {
                               return _parseRecipe(item, url);
                             }
                           }
                        }
                     } else if (_isRecipeNode(jsonData)) {
                        return _parseRecipe(jsonData as Map<String, dynamic>, url);
                     }
                  }
               } catch (e) {
                 print("Error parsing JSON-LD: $e");
               }
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching URL: $e');
    }
    return null;
  }

  bool _isRecipeNode(dynamic node) {
    if (node is Map) {
      var type = node['@type'];
      if (type is String && type == 'Recipe') return true;
      if (type is List && type.contains('Recipe')) return true;
    }
    return false;
  }

  Recipe _parseRecipe(Map<dynamic, dynamic> data, String sourceUrl) {
    String title = data['name'] ?? 'Onbekend Recept';
    String? description = data['description'];

    // Ingredients
    List<String> ingredientsList = [];
    if (data['recipeIngredient'] != null) {
       var ing = data['recipeIngredient'];
       if (ing is List) {
         ingredientsList = ing.map((e) => e.toString()).toList();
       } else if (ing is String) {
         ingredientsList = [ing];
       }
    }

    // Instructions
    List<String> instructionsList = [];
    if (data['recipeInstructions'] != null) {
      var instr = data['recipeInstructions'];
      if (instr is List) {
        for (var step in instr) {
          if (step is Map && step['@type'] == 'HowToStep') {
             instructionsList.add(step['text'] ?? '');
          } else if (step is String) {
             instructionsList.add(step);
          }
        }
      } else if (instr is String) {
         instructionsList = [instr];
      }
    }

    String? prepTime = data['prepTime'] ?? data['totalTime'];

    // Image
    String? imageUrl;
    if (data['image'] != null) {
      var img = data['image'];
      if (img is String) {
        imageUrl = img;
      } else if (img is List && img.isNotEmpty) {
        if (img[0] is String) {
           imageUrl = img[0];
        } else if (img[0] is Map) {
           imageUrl = img[0]['url'];
        }
      } else if (img is Map) {
        imageUrl = img['url'];
      }
    }

    return Recipe(
      title: title,
      description: description,
      ingredients: jsonEncode(ingredientsList), // store as JSON string
      instructions: jsonEncode(instructionsList), // store as JSON string
      prepTime: prepTime,
      imageUrl: imageUrl,
      sourceUrl: sourceUrl,
    );
  }
}

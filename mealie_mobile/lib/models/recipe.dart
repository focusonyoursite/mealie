class Recipe {
  final int? id;
  final String title;
  final String? description;
  final String ingredients;
  final String instructions;
  final String? prepTime;
  final String? imageUrl;
  final String? sourceUrl;

  Recipe({
    this.id,
    required this.title,
    this.description,
    required this.ingredients,
    required this.instructions,
    this.prepTime,
    this.imageUrl,
    this.sourceUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'prepTime': prepTime,
      'imageUrl': imageUrl,
      'sourceUrl': sourceUrl,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      ingredients: map['ingredients'],
      instructions: map['instructions'],
      prepTime: map['prepTime'],
      imageUrl: map['imageUrl'],
      sourceUrl: map['sourceUrl'],
    );
  }
}

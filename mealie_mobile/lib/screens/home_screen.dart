import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../database/database_helper.dart';
import '../services/scraper_service.dart';
import '../services/google_drive_service.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> _recipes = [];
  bool _isLoading = true;
  final GoogleDriveService _driveService = GoogleDriveService();

  @override
  void initState() {
    super.initState();
    _refreshRecipes();
  }

  Future<void> _refreshRecipes() async {
    setState(() => _isLoading = true);
    _recipes = await DatabaseHelper.instance.readAllRecipes();
    setState(() => _isLoading = false);
  }

  Future<void> _backupToDrive() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup starten...')),
    );
    final success = await _driveService.backupDatabase();
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text(success ? 'Backup naar Google Drive geslaagd!' : 'Backup mislukt.'),
           backgroundColor: success ? Colors.green : Colors.red,
         ),
       );
    }
  }

  void _addRecipeDialog() {
    final TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Recept URL Toevoegen'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(hintText: 'Plak de recept URL hier'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuleren'),
            ),
            ElevatedButton(
              onPressed: () {
                final url = urlController.text;
                Navigator.pop(dialogContext);
                if (url.isNotEmpty) {
                  _scrapeAndSave(url);
                }
              },
              child: const Text('Toevoegen'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _scrapeAndSave(String url) async {
    setState(() => _isLoading = true);
    final scraper = ScraperService();
    final recipe = await scraper.scrapeRecipe(url);

    if (recipe != null) {
      await DatabaseHelper.instance.create(recipe);
      await _refreshRecipes();

      // Auto-backup in achtergrond
      _driveService.backupDatabase().then((success) {
         if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Auto-backup geslaagd'), duration: Duration(seconds: 1)),
            );
         }
      });

    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kon geen recept vinden op deze URL.')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mijn Recepten'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: _backupToDrive,
            tooltip: 'Backup naar Google Drive',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recipes.isEmpty
              ? const Center(child: Text('Nog geen recepten. Voeg er een toe!'))
              : ListView.builder(
                  itemCount: _recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _recipes[index];
                    return ListTile(
                      leading: recipe.imageUrl != null
                          ? Image.network(recipe.imageUrl!, width: 50, height: 50, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.restaurant))
                          : const Icon(Icons.restaurant),
                      title: Text(recipe.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(recipe.prepTime ?? 'Geen tijd opgegeven'),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)),
                        );
                        _refreshRecipes();
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRecipeDialog,
        tooltip: 'Recept toevoegen via URL',
        child: const Icon(Icons.add_link),
      ),
    );
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/recipe.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('recipes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const textNotNull = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE recipes (
  id $idType,
  title $textNotNull,
  description $textType,
  ingredients $textNotNull,
  instructions $textNotNull,
  prepTime $textType,
  imageUrl $textType,
  sourceUrl $textType
)
''');
  }

  Future<int> create(Recipe recipe) async {
    final db = await instance.database;
    return await db.insert('recipes', recipe.toMap());
  }

  Future<Recipe?> readRecipe(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'recipes',
      columns: ['id', 'title', 'description', 'ingredients', 'instructions', 'prepTime', 'imageUrl', 'sourceUrl'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Recipe.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Recipe>> readAllRecipes() async {
    final db = await instance.database;
    final result = await db.query('recipes', orderBy: 'id DESC');
    return result.map((json) => Recipe.fromMap(json)).toList();
  }

  Future<int> update(Recipe recipe) async {
    final db = await instance.database;
    return db.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

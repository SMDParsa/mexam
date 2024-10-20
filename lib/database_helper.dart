import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize the database by copying it from assets and handling merge
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    // Get the path to the internal storage
    var dbDir = await getDatabasesPath();
    var dbPath = join(dbDir, 'mexam.db');
    var tempDbPath = join(dbDir, 'temp_mexam.db');

    // Check if the database already exists in the internal storage
    bool exists = await databaseExists(dbPath);

    if (!exists) {
      // If not exists, copy it from assets
      await _copyDatabaseFromAssets(dbPath);
    } else {
      // If the database exists, copy the new version to a temp location
      await _copyDatabaseFromAssets(tempDbPath);

      // Merge data from temp DB to the existing one
      await _mergeDataFromTempDb(dbPath, tempDbPath);

      // Delete the temporary database file
      await deleteDatabase(tempDbPath);
    }

    // Open the database
    return await openDatabase(dbPath);
  }

  // Copy the database from assets to the given path
  Future<void> _copyDatabaseFromAssets(String dbPath) async {
    try {
      await Directory(dirname(dbPath)).create(recursive: true);
      ByteData data = await rootBundle.load('assets/databases/mexam.db');
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes, flush: true);
    } catch (e) {
      print('Error copying database: $e');
    }
  }

  // Merge data from the temporary DB to the storage DB
  Future<void> _mergeDataFromTempDb(
      String storageDbPath, String tempDbPath) async {
    Database storageDb = await openDatabase(storageDbPath);
    Database tempDb = await openDatabase(tempDbPath);

    // Example: Merge all rows from a table called "Category" without duplicates
    List<Map<String, dynamic>> tempCategoryItems =
        await tempDb.query('Category');
    List<Map<String, dynamic>> tempNMLEItems = await tempDb.query('QuizTable');

    for (var item in tempCategoryItems) {
      // Check if the item exists in the storage DB (assuming 'ID' is a unique key)
      List<Map<String, dynamic>> existingItem = await storageDb.query(
        'Category',
        where: 'ID = ?',
        whereArgs: [item['ID']],
      );

      // Insert the item if it doesn't exist
      if (existingItem.isEmpty) {
        await storageDb.insert('Category', item);
      }
    }

    for (var item in tempNMLEItems) {
      List<Map<String, dynamic>> existingItem = await storageDb.query(
        'QuizTable',
        where: 'id = ?',
        whereArgs: [item['id']],
      );

      if (existingItem.isEmpty) {
        await storageDb.insert('QuizTable', item);
      }
    }

    await storageDb.close();
    await tempDb.close();
  }

  Future<List<Map<String, dynamic>>> getQuiz(int categoryId) {
    final db = DatabaseHelper._database!;
    return db.query('QuizTable',
        where: "is_answered = ? AND category_id = ?",
        whereArgs: [0, categoryId],
        limit: 1);
  }

  Future<List<Map<String, dynamic>>> getAllQuiz(int categoryId) {
    final db = DatabaseHelper._database!;
    return db
        .query('QuizTable', where: "category_id = ?", whereArgs: [categoryId]);
  }

  Future<List<Map<String, dynamic>>> getUserInfo() {
    final db = DatabaseHelper._database!;
    return db.query('UserTable', limit: 1);
  }

  static Future<int?> saveUserInfo(String userName, Uint8List userPic) async {
    final db = DatabaseHelper._database;

    final data = {'ID': 1, 'UserName': userName, 'UserPicture': userPic};

    final result = await db?.insert('UserTable', data);
    return result;
  }

  static Future<int?> updateUserInfo(String userName, Uint8List userPic) async {
    final db = DatabaseHelper._database;

    final data = {'UserName': userName, 'UserPicture': userPic};

    final result =
        await db?.update('UserTable', data, where: "ID = ?", whereArgs: [1]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getCategory(int id) {
    final db = DatabaseHelper._database!;
    return db.query('Category', where: "ID = ?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getEveryQuiz() {
    final db = DatabaseHelper._database!;
    return db.rawQuery(
        '''SELECT c.ID, c.Name, c.Description, c.Image, COUNT(q.ID) AS QuizCount
FROM Category c
LEFT JOIN QuizTable q ON c.ID = q.category_id
GROUP BY c.ID;''');
  }

  Future<List<Map<String, dynamic>>> getQuizReport() {
    final db = DatabaseHelper._database!;
    return db.rawQuery(
        '''SELECT QuizTable.id, QuizTable.text, QuizTable.ans_a, QuizTable.ans_b, QuizTable.ans_c, QuizTable.ans_d, QuizTable.correct_ans, QuizTable.u_ans, QuizTable.extra, QuizTable.is_answered, QuizTable.category_id, QuizTable.favorite, Category.Name, Category.Image
FROM QuizTable
INNER JOIN Category ON QuizTable.category_id = Category.ID
WHERE QuizTable.is_answered = "1";''');
  }

  Future<List<Map<String, dynamic>>> getQuizList() {
    final db = DatabaseHelper._database!;
    return db.query('QuizTable');
  }

  Future<int> getQuizScore(int categoryId) async {
    final db = DatabaseHelper._database!;
    // Query to sum all 'score' values
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(score) as total_score FROM QuizTable WHERE is_answered = ? AND category_id = ?',
      [1, categoryId],
    );

    // If result is not empty, return the summed score, otherwise return 0
    if (result.isNotEmpty && result.first['total_score'] != null) {
      return result
          .first['total_score']; // Get the total score from the query result
    } else {
      return 0; // Return 0 if no result
    }
  }

  Future<List<Map<String, dynamic>>> getAnsweredQuiz(int categoryId) {
    final db = DatabaseHelper._database!;
    return db.query('QuizTable',
        where: "is_answered = ? AND category_id = ?",
        whereArgs: [1, categoryId]);
  }

  Future<List<Map<String, dynamic>>> getCorrectAnsweredQuiz(int categoryId) {
    final db = DatabaseHelper._database!;
    return db.query('QuizTable',
        where: "is_answered = ? AND category_id = ? AND score = ?",
        whereArgs: [1, categoryId, 10]);
  }

  static Future<int?> saveAnswer(int id, String uSelected, int score) async {
    final db = DatabaseHelper._database;

    final data = {'is_answered': 1, 'score': score, 'u_ans': uSelected};

    final result =
        await db?.update('QuizTable', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<int?> adFavorite(int id, int favorite) async {
    final db = DatabaseHelper._database;

    final data = {
      'favorite': favorite,
    };

    final result =
        await db?.update('QuizTable', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<int?> restartQuiz(int categoryId) async {
    final db = DatabaseHelper._database;

    final data = {'is_answered': 0, 'score': 0, 'u_ans': ''};

    final result = await db?.update('QuizTable', data,
        where: "category_id = ?", whereArgs: [categoryId]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getQuizCount() {
    final db = DatabaseHelper._database!;

    // List<Map<String, dynamic>> result = await db.query('QuizTable');

    // Use PRAGMA to get the table information
    /* final List<Map<String, dynamic>> result =
        await db.rawQuery('PRAGMA table_info(QuizTable)'); */

    // Return the column count
    return db.rawQuery('PRAGMA table_info(QuizTable)');
  }
}

import 'dart:convert';  // JSON変換用
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class RecipeDatabase {
  static final _databaseName = "RecipeDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'recipes';

  static final columnId = 'id';
  static final columnTitle = 'title';
  static final columnRecipe = 'recipe';
  static final columnImage = 'image';
  static final columnChecks = 'checks'; // チェック項目はJSON形式で保存

  // シングルトンパターン
  RecipeDatabase._privateConstructor();
  static final RecipeDatabase instance = RecipeDatabase._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // データベース初期化
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // テーブル作成
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnRecipe TEXT NOT NULL,
        $columnImage TEXT,
        $columnChecks TEXT
      )
    ''');
  }

  // データ挿入
 Future<int> insertData(Map<String, dynamic> row) async {
  Database? db = await instance.database;

  // checksフィールドをカンマ区切りの文字列に変換
  if (row.containsKey('checks')) {
    List<bool> checksList = row['checks'];
    // List<bool>をカンマ区切りの文字列に変換
    row['checks'] = checksList.map((e) => e.toString()).join(','); // ["true", "false", ...]形式に変換
  }

  return await db!.insert(table, row);
}

  // データの更新
  Future<int> updateData(int id, String title, String recipeStr, String image, List<bool> checks) async {
    Database? db = await instance.database;
    Map<String, dynamic> row = {
      columnTitle: title,
      columnRecipe: recipeStr,
      columnImage: image,
      columnChecks: checks.map((e) => e.toString()).join(",") // List<bool>をJSON形式で保存
    };
    return await db!.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // データ取得
  Future<List<Map<String, dynamic>>> getData() async {
    Database? db = await instance.database;
    return await db!.query(table);
  }

  // 特定のカテゴリ（チェック項目）でフィルタリング
  Future<List<Map<String, dynamic>>> getRowsWithSameCategory(String category) async {
    Database? db = await instance.database;
    
    // JSON文字列として保存されているので、LIKEを使ってフィルタリング
    return await db!.query(table, where: '$columnChecks = ?', whereArgs: [category]);
  }

  // データ削除
  Future<int> deleteData(int id) async {
    Database? db = await instance.database;
    return await db!.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}

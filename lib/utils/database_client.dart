import 'dart:async';
import 'dart:io';

import 'package:no_to_do/model/notodo_item.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  final String tableName = "notodo";
  final String columnId = "id";
  final String columnItemname = "itemName";
  final String columnDateCreated = "dateCreated";

  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(
        documentDirectory.path, "notodo.db"); // home//directory/files/nodo_db.db

    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  /*
  id | username | createdon
  --------------------------
  1  | Paulo    |
  2  | James    | bond
   */

  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $tableName(id INTEGER PRIMARY KEY, $columnItemname TEXT, $columnDateCreated TEXT)");
  }

  //CRUD - CREATE , READ , UPDATE , DELETE

  //INSERTION
  Future<int> saveItem(NoToItem item) async {
    var dbClient = await db;
    int res = await dbClient.insert("$tableName", item.toMap());
    print(res.toString());
    return res;
  }

  //Get
  Future<List> getItems() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableName ORDER BY $columnItemname ASC");

    return result.toList();
  }

  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery("SELECT COUNT (*) FROM $tableName")
    );
  }

  Future<NoToItem>getItem(int id) async{
    var dbClient = await db;

    var result = await dbClient.rawQuery("SELECT * FROM $tableName WHERE $columnId = $id");
    if(result.length == 0)return null;
    return new NoToItem.fromMap(result.first);
  }

  //delete user
  Future<int> deleteUser(int id) async{
    var dbClient = await db;

    return await dbClient.delete(tableName,
        where: "$columnId = ?",whereArgs: [id]);
  }

  //update user
  Future<int>updateUser(NoToItem user) async {
    var dbClient = await db;
    return await dbClient.update(tableName,
        user.toMap(), where: "$columnId = ?",whereArgs: [user.id]);
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }

}

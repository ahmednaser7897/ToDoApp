import 'package:sqflite/sqflite.dart';
import 'package:todo_app/models/task.dart';

late Database database;
List<Map> tasks = [];

class DataBase {
  static const tabelName = "tasks";
  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  createDB() async {
    await openDatabase(
      "a4.db",
      version: 1,
      onConfigure: _onConfigure,
      onCreate: (db, version) async {
        print("database is created");
        try {
          await db.execute("""
            create table $tabelName(
             id  INTEGER PRIMARY KEY AUTOINCREMENT,
             title STRING,note TEXT,date STRING,
             startTime STRING,endTime STRING,
             repeat STRING,remind int,
             color int,isCompleted int
            );
            """);
        } catch (e) {
          print("erorr is " + e.toString());
        }
      },
      onOpen: (db) {},
    ).then((value) {
      database = value;
      print("database is opend");
    });
  }

  Future<int> insertPersonDataToDB(Task t) async {
    return await database.insert(tabelName, t.toMap());
  }

  Future<List<Map>> getTableDataFromDB() async {
    print("table is $tabelName");
    String sql = "select * from $tabelName";
    // return list of map of persons
    return await database.rawQuery(sql);
  }

  Future<List<Map>> getItemDataFromDB(int id) async {
    print("table is $tabelName");
    String sql = "select * from $tabelName where id=$id";
    // return list of map of persons
    return await database.rawQuery(sql);
  }

  Future<void> update(Task t) async {
    await database
        .rawUpdate("UPDATE $tabelName set isCompleted= 1 WHERE id= ${t.id}");
  }

  void deletAll() async {
    await database.delete(tabelName);
  }

  void deletItemFromDB(
    int id,
  ) async {
    await database.transaction((txn) async {
      database.rawDelete('DELETE FROM $tabelName WHERE id = $id').then((value) {
        print("item $id in table $tabelName deleted successfully");
      }).catchError((error) {
        print("deleting item $id in table $tabelName error: $error");
      });
    });
  }
}
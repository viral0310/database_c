import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'model.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper dbHelper = DBHelper._();

  final String dbName = 'demo.db';

  final String tableName = 'Student';
  final String colId = 'id';
  final String colName = 'name';

  final String colAge = 'age';
  final String colCity = 'city';
  final String colImage = 'image';
  Database? db;
  // TODO: initDB();

  Future<void> initDB() async {
    String directory = await getDatabasesPath();
    String path = join(directory, dbName);

    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        String query =
            "CREATE TABLE IF NOT EXISTS $tableName($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colName TEXT,$colAge INTEGER, $colCity TEXT, $colImage BLOB);";
        // String query =
        //     "CREATE TABLE IF NOT EXISTS $tableName($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colName TEXT,$colAge INTEGER, $colCity TEXT);";
        await db.execute(query);
        print("----------------------------------");
        print("Table created successfully");
        print("------------------------------------");
      },
    );
  }

  // TODO: insertRecord();
  //without blob image
/*  Future<int> insertRecord() async {
    await initDB();
    String name = 'shag-ar';
    String city = 'Mumbai';
    int age = 20;

    String query =
        "INSERT INTO $tableName($colName,$colAge,$colCity) VALUES(?, ?, ?);";

    List args = [name, age, city];

    int id = await db!.rawInsert(query, args);
    print(args);
    return id;
  }*/
  Future<int> insertRecord(
      {required String name,
      required int age,
      required String city,
      Uint8List? image}) async {
    await initDB();
    String query =
        "INSERT INTO $tableName($colName,$colAge,$colCity,$colImage ) VALUES(?, ?, ?,?);";
    //  "INSERT INTO $tableName($colName,$colAge,$colCity) VALUES(?, ?, ?,?);";
    List args = [name, age, city, image!];
    //List args = [name, age, city];
    int id = await db!.rawInsert(query, args);
    print(args);
    return id;
  }

// TODO: fetchAllRecords();
  Future<List<Student>> fetchAllRecords() async {
    await initDB();
    String query = "SELECT * FROM $tableName";
    List<Map<String, dynamic>> allStudents = await db!.rawQuery(query);
    print(allStudents);
    List<Student> students =
        allStudents.map((e) => Student.fromMap(e)).toList();
    return students;
  }
// TODO: updateRecord();

  Future<int> updateRecord(
      {required String name,
      required int age,
      required String city,
      required int id,
      Uint8List? image}) async {
    await initDB();
    String query =
        "UPDATE $tableName SET $colName=?, $colAge=?, $colCity=?, $colImage=? WHERE $colId=?";

    List args = [name, age, city, id, image];
    return await db!.rawUpdate(query, args);
  }

// TODO: deleteRecords();
  Future<int> deleteRecord({required int id}) async {
    await initDB();
    String query = "DELETE FROM $tableName WHERE $colId=?";
    List args = [id];
    return await db!.rawDelete(query, args);
  }

  // TODO: fetchSearchedRecords();
  Future<List<Student>> fetchSearchedRecords({required String data}) async {
    await initDB();
    String query = "SELECT * FROM $tableName WHERE $colName LIKE '%$data%'";
    List<Map<String, dynamic>> allStudents = await db!.rawQuery(query);
    List<Student> students =
        allStudents.map((e) => Student.fromMap(e)).toList();
    return students;
  }
}

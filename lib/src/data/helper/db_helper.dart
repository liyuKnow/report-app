import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:final_report/src/data/models/models.dart';

class DatabaseProvider with ChangeNotifier {
  String _searchText = '';
  String get searchText => _searchText;
  set searchText(String value) {
    _searchText = value;
    notifyListeners();
    // when the value of the search text changes it will notify the widgets.
  }

  List<User> _users = [];
  List<User> get users {
    return _searchText != ''
        ? _users
            .where((e) =>
                e.firstName.toLowerCase().contains(_searchText.toLowerCase()))
            .toList()
        : _users;
  }

  User? _user;
  User? get user => _user;

  UpdateLocation? _updateLocation;
  UpdateLocation? get updateLocation => _updateLocation;

  // COMPLETES OUR DATABASE CREATION
  Database? _database;
  Future<Database> get database async {
    // database directory
    final dbDirectory = await getDatabasesPath();
    // database name
    const dbName = 'report_10.db';
    // full path
    final path = join(dbDirectory, dbName);

    _database = await openDatabase(path,
        version: 1,
        onCreate: _createDb,
        onConfigure: _onConfigure // will create this separately
        );

    return _database!;
  }

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // _createDb function
  static const userTable = 'users';
  static const updateLocationTable = 'update_locations';
  Future<void> _createDb(Database db, int version) async {
    // this method runs only once. when the database is being created
    // so create the tables here and if you want to insert some initial values
    // insert it in this function.

    await db.transaction((txn) async {
      // category table
      await txn.execute('''CREATE TABLE $userTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT,
        lastName TEXT,
        updated INTEGER DEFAULT 0,
        age INTEGER,
        date VARCHAR
      )''');

      // expense table
      await txn.execute('''CREATE TABLE $updateLocationTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lat VARCHAR,
        long VARCHAR,
        updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        userId INTEGER, 
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
      )''');

      // // ! TESTING INITIAL DATA
      await txn.insert(userTable, {
        'firstName': 'Kidus',
        'lastName': 'Taye',
        'age': 29,
        'date': DateTime.now().toIso8601String(),
      });
      await txn.insert(userTable, {
        'firstName': 'Kidus',
        'lastName': 'Taye',
        'age': 29,
        'date': DateTime.now().toIso8601String(),
      });

      await txn.insert(updateLocationTable, {
        'lat': '8.3685',
        'long': '11.3456',
        'userId': 1,
      });
    });
  }

  // CRUD OPERATIONS
  Future<List<User>> fetchAllUsers() async {
    // get the database
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(userTable, where: "updated == 0").then((data) {
        // 'data' is our fetched value
        // convert it from "Map<String, object>" to "Map<String, dynamic>"
        final converted = List<Map<String, dynamic>>.from(data);
        // create a 'ExpenseCategory'from every 'map' in this 'converted'
        List<User> nList = List.generate(
            converted.length,
            (index) => User.fromJson(
                  converted[index],
                ));
        // set the value of 'categories' to 'nList'
        _users = nList;
        // return the '_categories'
        return _users;
      });
    });
  }

  Future<List<User>> fetchUsers() async {
    // get the database
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(userTable).then((data) {
        // 'data' is our fetched value
        // convert it from "Map<String, object>" to "Map<String, dynamic>"
        final converted = List<Map<String, dynamic>>.from(data);
        // create a 'ExpenseCategory'from every 'map' in this 'converted'
        List<User> nList = List.generate(
            converted.length,
            (index) => User.fromJson(
                  converted[index],
                ));
        // set the value of 'categories' to 'nList'
        _users = nList;
        // return the '_categories'
        return _users;
      });
    });
  }

  // DELETE PREVIOUS RECORDS AND RESET DATABASE TABLE INDEX BACK TO 0
  Future<void> truncateTables() async {
    final db = await database;
    var sql = """ 
              DELETE FROM $userTable ;    
              DELETE FROM $updateLocationTable ; 
              """;

    var seq_sql = """    
              UPDATE SQLITE_SEQUENCE SET SEQ=0 WHERE NAME='users';
              UPDATE SQLITE_SEQUENCE SET SEQ=0 WHERE NAME='update_locations';
              """;

    await db.transaction(((txn) {
      return txn.rawQuery(sql);
    }));

    try {
      await db.transaction(((txn) {
        return txn.rawQuery(seq_sql);
      }));
    } catch (e) {
      print(e);
    }

    return;
  }

  Future<void> addMany(Map<String, Object?> users) async {
    final db = await database;
    Batch batch = db.batch();
    batch.insert(
      userTable,
      users,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> addUser(User user) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .insert(
        userTable,
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      )
          .then((generatedId) {
        // after inserting in a database. we store it in in-app memory with new expense with generated id
        final file = User(
          id: generatedId,
          firstName: user.firstName,
          lastName: user.lastName,
          date: user.date,
          age: user.age,
        );
        // add it to '_expenses'

        _users.add(file);
        // notify the listeners about the change in value of '_expenses'
        notifyListeners();
      });
    });
  }

  Future<User?> getUserById(int id) async {
    final db = await database;

    var result = await db.rawQuery('SELECT * FROM $userTable WHERE id=?', [id]);

    final converted = User.fromJson(result[0]);

    _user = converted;

    notifyListeners();
    return _user;
  }

  Future<UpdateLocation?> getUpdatedLocationByUserId(int userId) async {
    final db = await database;

    var result = await db.rawQuery(
        'SELECT * FROM $updateLocationTable WHERE userId=?', [userId]);

    final converted = UpdateLocation.fromJson(result[0]);

    _updateLocation = converted;

    notifyListeners();
    return _updateLocation;
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        userTable, // category table
        user.toJson(),
        where: 'id == ?', // in table where the title ==
        whereArgs: [user.id], // this category.
      ).then((_) {
        notifyListeners();
      });
    });
  }

  Future<void> addUpdateLocation(UpdateLocation updateLocation) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.insert(
        updateLocationTable,
        updateLocation.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }
}

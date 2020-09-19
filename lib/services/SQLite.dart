import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static const String UID = 'uid';
  static const String NAME = 'displayName';
  static const String LOCAL_NAME = 'localName';
  static const String LAST_SIGNIN_TIME = 'lastSignInTime';
  static const String CREATION_TIME = 'lastSignInTime';
  static const String PHOTO_URL = 'photoURL';
  static const String PHONE_NUMBER = 'phoneNumber';
  static const String TABLE = 'RECENT_USER';
  static const String DB_NAME = 'Contact.db';

  Future<Database> get db async {
    Database _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    print('INSIDE ON CREATE');
    await db.execute(
        "CREATE TABLE $TABLE ($UID TEXT , $LOCAL_NAME TEXT, $PHONE_NUMBER TEXT, $PHOTO_URL TEXT , $LAST_SIGNIN_TIME)");
    // "CREATE TABLE $TABLE ($UID TEXT PRIMARY KEY, $NAME TEXT, $LOCAL_NAME TEXT, $PHONE_NUMBER TEXT, $PHOTO_URL TEXT, $LAST_SIGNIN_TIME TEXT, $CREATION_TIME TEXT)");
  }

  Future<void> save(contact) async {
    print('ISSIDE SAAVE');
    var dbClient = await initDb();
    // await dbClient.insert(TABLE, test);

    await dbClient.transaction((txn) async {
      var query =
          'INSERT INTO $TABLE VALUES ("${contact['uid']}" , "${contact['localName']}", "${contact['phoneNumber']}", "${contact['photoURL']}",  "${DateTime.now()}")';
      return await txn.rawInsert(query);
    });

    close();
  }

  Future<List<dynamic>> getContacts() async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query(TABLE, columns: [UID, LOCAL_NAME, PHONE_NUMBER, PHOTO_URL]);
    //List<Map> maps = await dbClient.rawQuery("SELECT * FROM $TABLE");
    List<dynamic> contacts = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        Map<String, String> temp = new Map();
        maps[i].forEach((key, value) {
          temp[key] = value.toString();
        });
        contacts.add(temp);
      }
    }
    return contacts;
  }

  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE, where: '$UID = ?', whereArgs: [id]);
  }

  Future<int> update(contact) async {
    var dbClient = await db;
    return await dbClient.update(TABLE, contact.toMap(),
        where: '$UID = ?', whereArgs: [contact.id]);
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}

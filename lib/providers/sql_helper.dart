import 'package:ms_customer_app/providers/products_class.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class SQLHelper {
  ///Get Database
  static Database? _database;
  static get getDatabase async {
    if (_database != null) return _database;
    _database = await initDatabase();
    return _database;
  }

//init Database
//Create & Upgrade
  static Future<Database> initDatabase() async {
    String path = p.join(await getDatabasesPath(), "shopping_database.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future _onCreate(Database db, int version) async {
    Batch batch = db.batch();
    batch.execute('''
CREATE TABLE cart_items (
  documentId TEXT PRIMARY KEY,
  name TEXT,
  price DOUBLE,
  quentity INTEGER,
  inStock INTEGER,
  imagesUrl TEXT,
  supplierId TEXT
)
''');

    batch.execute('''
CREATE TABLE wish_items (
  documentId TEXT PRIMARY KEY,
  name TEXT,
  price DOUBLE,
  quentity INTEGER,
  inStock INTEGER,
  imagesUrl TEXT,
  supplierId TEXT
)
''');
    batch.commit();
  }

//insert data into datadbase
  static Future insertItem(Product product) async {
    Database db = await getDatabase;
    await db.insert("cart_items", product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //RETRIVE DATA FROM DATABASE

  static Future<List<Map>> loadCartItems() async {
    Database db = await getDatabase;
    return await db.query("cart_items");
  }

  static Future updateItem(Product newproduct, bool isIncrement) async {
    Database db = await getDatabase;
    await db.rawUpdate(
        'UPDATE cart_items SET quentity = ?, content = ? WHERE documentId = ?',
        [
          isIncrement == true
              ? newproduct.quentity + 1
              : newproduct.quentity - 1,
          newproduct.documentId
        ]);
  }

  static Future deleteCartItem(String id) async {
    Database db = await getDatabase;
    await db.delete("cart_items", where: "documentId = ?", whereArgs: [id]);
  }

  static Future deleteAllCartItems() async {
    Database db = await getDatabase;
    await db.rawDelete('DELETE FROM cart_items');
    // await db.execute('DELETE FROM notes');
  }
}

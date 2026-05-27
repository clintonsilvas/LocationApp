import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {
  static final DB instance = DB._init();
  static Database? _database;

  DB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('entregas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entrega (
        idEntrega TEXT,
        destinatario TEXT,
        endereco TEXT,
        status TEXT,
        latitude REAL,
        longitude REAL,
        datahora TEXT
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }

  Future<void> resetDB() async {
    final path = join(await getDatabasesPath(), 'entregas.db');

    await deleteDatabase(path);

    _database = null;
  }
}

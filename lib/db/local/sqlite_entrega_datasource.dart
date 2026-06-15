import 'package:locationapp/db/db.dart';
import 'package:locationapp/models/entrega.dart';
import 'package:sqflite/sqflite.dart';

class SqliteEntregaDataSource {
  Future<Database> get _db async => await DB.instance.database;

  Future<void> inserirEntrega(Entrega e) async {
    final db = await _db;

    await db.insert('entrega', {
      'idEntrega': e.idEntrega,
      'destinatario': e.destinatario,
      'endereco': e.endereco,
      'status': e.status.name,
      'latitude': e.latitude,
      'longitude': e.longitude,
      'datahora': e.dataHora.toIso8601String(),
      'sincronizado': e.sincronizado ? 1 : 0,
    });
  }

  Future<void> atualizarEntrega(Entrega entrega) async {
    final db = await _db;

    await db.update(
      'entrega',
      {
        'destinatario': entrega.destinatario,
        'endereco': entrega.endereco,
        'status': entrega.status.name,
        'latitude': entrega.latitude,
        'longitude': entrega.longitude,
        'datahora': entrega.dataHora.toIso8601String(),
        'sincronizado': 0,
      },
      where: 'idEntrega = ?',
      whereArgs: [entrega.idEntrega],
    );
  }

  Future<void> deletarEntrega(String idEntrega) async {
    final db = await _db;

    await db.delete('entrega', where: 'idEntrega = ?', whereArgs: [idEntrega]);
  }

  Future<List<Entrega>> listarEntregas() async {
    final db = await _db;

    final resultado = await db.query('entrega');

    return resultado.map((e) {
      return Entrega(
        idEntrega: e['idEntrega'] as String,
        destinatario: e['destinatario'] as String,
        endereco: e['endereco'] as String,
        status: StatusPedido.values.firstWhere((s) => s.name == e['status']),
        latitude: (e['latitude'] as num).toDouble(),
        longitude: (e['longitude'] as num).toDouble(),
        dataHora: DateTime.parse(e['datahora'] as String),
        sincronizado: (e['sincronizado'] as int) == 1,
      );
    }).toList();
  }

  Future<List<Entrega>> listarPendentesSincronizacao() async {
    final db = await _db;

    final resultado = await db.query(
      'entrega',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );

    return resultado.map((e) {
      return Entrega(
        idEntrega: e['idEntrega'] as String,
        destinatario: e['destinatario'] as String,
        endereco: e['endereco'] as String,
        status: StatusPedido.values.firstWhere((s) => s.name == e['status']),
        latitude: (e['latitude'] as num).toDouble(),
        longitude: (e['longitude'] as num).toDouble(),
        dataHora: DateTime.parse(e['datahora'] as String),
        sincronizado: (e['sincronizado'] as int) == 1,
      );
    }).toList();
  }

  Future<void> marcarComoSincronizado(String idEntrega) async {
    final db = await _db;

    await db.update(
      'entrega',
      {'sincronizado': 1},
      where: 'idEntrega = ?',
      whereArgs: [idEntrega],
    );
  }

  Future<int> contarPendentesSincronizacao() async {
    final db = await _db;

    final resultado = await db.rawQuery('''
    SELECT COUNT(*) as total
    FROM entrega
    WHERE sincronizado = 0
    ''');

    return resultado.first['total'] as int;
  }

  Future<void> adicionarExclusaoPendente(String idEntrega) async {
    final db = await _db;

    await db.insert('exclusoes_pendentes', {'idEntrega': idEntrega});
  }

  Future<List<String>> listarExclusoesPendentes() async {
    final db = await _db;

    final resultado = await db.query('exclusoes_pendentes');

    return resultado.map((e) => e['idEntrega'] as String).toList();
  }

  Future<void> removerExclusaoPendente(String idEntrega) async {
    final db = await _db;

    await db.delete(
      'exclusoes_pendentes',
      where: 'idEntrega = ?',
      whereArgs: [idEntrega],
    );
  }
}

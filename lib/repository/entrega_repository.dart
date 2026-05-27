import 'package:locationapp/models/entrega.dart';
import 'package:locationapp/db/db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class EntregaRepository {
  final uuid = Uuid();
  Future<Database> get _db async => await DB.instance.database;

  Future<void> inserirEntrega(Entrega e) async {
    final db = await _db;
    String idEntrega = uuid.v4();

    await db.insert('entrega', {
      'idEntrega': idEntrega,
      'destinatario': e.destinatario,
      'endereco': e.endereco,
      'status': e.status.name,
      'latitude': e.latitude,
      'longitude': e.longitude,
      'datahora': e.dataHora.toIso8601String(),
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

        latitude: e['latitude'] as double,
        longitude: e['longitude'] as double,

        dataHora: DateTime.parse(e['datahora'] as String),
      );
    }).toList();
  }
}

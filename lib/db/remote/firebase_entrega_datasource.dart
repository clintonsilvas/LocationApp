import 'package:firebase_database/firebase_database.dart';
import 'package:locationapp/models/entrega.dart';

class FirebaseEntregaDataSource {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('entregas');

  Future<void> inserirEntrega(Entrega entrega) async {
    await _ref.child(entrega.idEntrega).set({
      'idEntrega': entrega.idEntrega,
      'destinatario': entrega.destinatario,
      'endereco': entrega.endereco,
      'status': entrega.status.name,
      'latitude': entrega.latitude,
      'longitude': entrega.longitude,
      'datahora': entrega.dataHora.toIso8601String(),
    });
  }

  Future<void> atualizarEntrega(Entrega entrega) async {
    await _ref.child(entrega.idEntrega).update({
      'destinatario': entrega.destinatario,
      'endereco': entrega.endereco,
      'status': entrega.status.name,
      'latitude': entrega.latitude,
      'longitude': entrega.longitude,
      'datahora': entrega.dataHora.toIso8601String(),
    });
  }

  Future<void> deletarEntrega(String idEntrega) async {
    await _ref.child(idEntrega).remove();
  }

  Future<List<Entrega>> listarEntregas() async {
    final snapshot = await _ref.get();

    if (!snapshot.exists) {
      return [];
    }

    final dados = Map<String, dynamic>.from(snapshot.value as Map);

    return dados.values.map((e) {
      final entrega = Map<String, dynamic>.from(e);

      return Entrega(
        idEntrega: entrega['idEntrega'],
        destinatario: entrega['destinatario'],
        endereco: entrega['endereco'],

        status: StatusPedido.values.firstWhere(
          (s) => s.name == entrega['status'],
        ),

        latitude: (entrega['latitude'] as num).toDouble(),

        longitude: (entrega['longitude'] as num).toDouble(),

        dataHora: DateTime.parse(entrega['datahora']),
      );
    }).toList();
  }
}

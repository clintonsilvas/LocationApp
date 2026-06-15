import 'package:locationapp/db/local/sqlite_entrega_datasource.dart';
import 'package:locationapp/db/remote/firebase_entrega_datasource.dart';
import 'package:locationapp/models/entrega.dart';
import 'package:locationapp/services/connectivity_service.dart';
import 'package:uuid/uuid.dart';

class EntregaRepository {
  final SqliteEntregaDataSource local;
  final FirebaseEntregaDataSource remote;
  final ConnectivityService connectivity;

  final Uuid uuid = const Uuid();

  EntregaRepository({
    required this.local,
    required this.remote,
    required this.connectivity,
  });

  Future<void> inserirEntrega(Entrega entrega) async {
    final online = await connectivity.temInternet();
    final novaEntrega = Entrega(
      idEntrega: uuid.v4(),
      destinatario: entrega.destinatario,
      endereco: entrega.endereco,
      status: entrega.status,
      latitude: entrega.latitude,
      longitude: entrega.longitude,
      dataHora: entrega.dataHora,
      sincronizado: online,
    );

    await local.inserirEntrega(novaEntrega);

    if (await connectivity.temInternet()) {
      try {
        await remote.inserirEntrega(novaEntrega);
      } catch (_) {}
    }
  }

  Future<void> atualizarEntrega(Entrega entrega) async {
    await local.atualizarEntrega(entrega);

    if (await connectivity.temInternet()) {
      try {
        await remote.atualizarEntrega(entrega);
      } catch (_) {}
    }
  }

  Future<void> deletarEntrega(String id) async {
    await local.deletarEntrega(id);

    if (await connectivity.temInternet()) {
      try {
        await remote.deletarEntrega(id);
      } catch (_) {}
    } else {
      await local.adicionarExclusaoPendente(id);
    }
  }

  Future<List<Entrega>> listarEntregas() async {
    if (await connectivity.temInternet()) {
      try {
        final entregasFirebase = await remote.listarEntregas();

        return entregasFirebase;
      } catch (_) {
        return await local.listarEntregas();
      }
    }

    return await local.listarEntregas();
  }
}

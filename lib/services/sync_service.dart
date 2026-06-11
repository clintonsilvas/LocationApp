import 'package:locationapp/db/local/sqlite_entrega_datasource.dart';
import 'package:locationapp/db/remote/firebase_entrega_datasource.dart';
import 'package:locationapp/services/connectivity_service.dart';

class SyncService {
  final SqliteEntregaDataSource local;
  final FirebaseEntregaDataSource remote;
  final ConnectivityService connectivity;

  SyncService({
    required this.local,
    required this.remote,
    required this.connectivity,
  });

  Future<void> sincronizar() async {
    if (!await connectivity.temInternet()) {
      return;
    }

    final pendentes = await local.listarPendentesSincronizacao();

    for (final entrega in pendentes) {
      try {
        await remote.inserirEntrega(entrega);

        await local.marcarComoSincronizado(entrega.idEntrega);
      } catch (_) {}
    }
  }
}

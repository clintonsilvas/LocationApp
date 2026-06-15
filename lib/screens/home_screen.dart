import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locationapp/db/local/sqlite_entrega_datasource.dart';
import 'package:locationapp/db/remote/firebase_entrega_datasource.dart';

import 'package:locationapp/models/entrega.dart';
import 'package:locationapp/repository/entrega_repository.dart';
import 'package:locationapp/services/connectivity_service.dart';
import 'package:locationapp/services/sync_service.dart';
import 'package:locationapp/widgets/entrega/entrega_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final local = SqliteEntregaDataSource();
  final remote = FirebaseEntregaDataSource();
  final connectivity = ConnectivityService();
  late final EntregaRepository repository;
  late final SyncService syncService;
  int entregasPendentes = 0;

  List<Entrega> entregas = [];
  bool carregando = true;

  int get pendentesSync => entregas.where((e) => !e.sincronizado).length;
  @override
  void initState() {
    super.initState();

    repository = EntregaRepository(
      local: local,
      remote: remote,
      connectivity: connectivity,
    );

    syncService = SyncService(
      local: local,
      remote: remote,
      connectivity: connectivity,
    );

    carregarEntregas();
  }

  Future<void> carregarEntregas() async {
    setState(() {
      carregando = true;
    });

    await syncService.sincronizar();
    entregasPendentes = await local.contarPendentesSincronizacao();

    entregas = await repository.listarEntregas();

    setState(() {
      carregando = false;
    });
  }

  Future<void> abrirFormulario({Entrega? entrega}) async {
    await context.pushNamed('entrega-form', extra: entrega);

    carregarEntregas();
  }

  Future<void> excluirEntrega(Entrega entrega) async {
    await repository.deletarEntrega(entrega.idEntrega);

    carregarEntregas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entregas'), centerTitle: true),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => abrirFormulario(),
            child: const Icon(Icons.add),
          ),
        ],
      ),

      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : entregas.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 20),

                  Text(
                    'Nenhuma entrega cadastrada',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                if (entregasPendentes > 0)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_off, color: Colors.orange),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            '$entregasPendentes entrega(s) não sincronizada(s), aguardando conexão com a internet.',
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: carregarEntregas,

                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 10, bottom: 100),

                      itemCount: entregas.length,

                      itemBuilder: (context, index) {
                        final entrega = entregas[index];

                        return EntregaCard(
                          entrega: entrega,

                          onEditar: () {
                            abrirFormulario(entrega: entrega);
                          },

                          onExcluir: () async {
                            excluirEntrega(entrega);
                          },

                          onVerCompleto: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Tela de mapa em desenvolvimento',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

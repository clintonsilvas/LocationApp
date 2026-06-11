import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:locationapp/db/local/sqlite_entrega_datasource.dart';
import 'package:locationapp/db/remote/firebase_entrega_datasource.dart';
import 'package:locationapp/services/connectivity_service.dart';

import '../models/entrega.dart';
import '../repository/entrega_repository.dart';

class EntregaFormScreen extends StatefulWidget {
  final Entrega? entrega;

  const EntregaFormScreen({super.key, this.entrega});

  @override
  State<EntregaFormScreen> createState() => _EntregaFormScreenState();
}

class _EntregaFormScreenState extends State<EntregaFormScreen> {
  final local = SqliteEntregaDataSource();
  final remote = FirebaseEntregaDataSource();
  final connectivity = ConnectivityService();
  late final EntregaRepository repository;

  double? latitudeAtual;
  double? longitudeAtual;

  double? latitudeAnterior;
  double? longitudeAnterior;

  final destinatarioController = TextEditingController();

  final enderecoController = TextEditingController();

  StatusPedido statusSelecionado = StatusPedido.pendente;

  bool carregandoLocalizacao = true;

  bool get editando => widget.entrega != null;

  @override
  void initState() {
    super.initState();
    repository = EntregaRepository(
      local: local,
      remote: remote,
      connectivity: connectivity,
    );

    if (editando) {
      destinatarioController.text = widget.entrega!.destinatario;
      enderecoController.text = widget.entrega!.endereco;

      latitudeAnterior = widget.entrega!.latitude;
      longitudeAnterior = widget.entrega!.longitude;

      statusSelecionado = widget.entrega!.status;

      pegarLocalizacao();
    } else {
      pegarLocalizacao();
    }
  }

  Future<void> pegarLocalizacao() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      setState(() {
        carregandoLocalizacao = false;
      });

      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        carregandoLocalizacao = false;
      });

      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      latitudeAtual = position.latitude;
      longitudeAtual = position.longitude;

      carregandoLocalizacao = false;
    });
  }

  Future<void> salvar() async {
    if (latitudeAtual == null || longitudeAtual == null) {
      return;
    }

    if (editando) {
      await repository.atualizarEntrega(
        Entrega(
          idEntrega: widget.entrega!.idEntrega,

          destinatario: destinatarioController.text,

          endereco: enderecoController.text,

          status: statusSelecionado,

          latitude: latitudeAtual!,
          longitude: longitudeAtual!,

          dataHora: DateTime.now(),
          sincronizado: widget.entrega!.sincronizado,
        ),
      );
    } else {
      await repository.inserirEntrega(
        Entrega(
          idEntrega: '',

          destinatario: destinatarioController.text,

          endereco: enderecoController.text,

          status: StatusPedido.pendente,

          latitude: latitudeAtual!,
          longitude: longitudeAtual!,

          dataHora: DateTime.now(),
          sincronizado: false,
        ),
      );
    }

    // ignore: use_build_context_synchronously
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(editando ? 'Editar entrega' : 'Nova entrega')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            TextField(
              controller: destinatarioController,

              decoration: const InputDecoration(
                labelText: 'Destinatário',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: enderecoController,

              decoration: const InputDecoration(
                labelText: 'Endereço',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Localização atual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            if (editando)
              const Row(
                children: [
                  Icon(Icons.location_pin, color: Colors.blue),
                  Text(' Última posição'),

                  SizedBox(width: 20),

                  Icon(Icons.location_pin, color: Colors.red),
                  Text(' Localização atual'),
                ],
              ),

            Container(
              height: 300,
              clipBehavior: Clip.hardEdge,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),

              child: carregandoLocalizacao
                  ? const Center(child: CircularProgressIndicator())
                  : latitudeAtual == null || longitudeAtual == null
                  ? const Center(
                      child: Text('Não foi possível obter localização'),
                    )
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(latitudeAtual!, longitudeAtual!),

                        initialZoom: 8,
                      ),

                      children: [
                        if (editando &&
                            latitudeAnterior != null &&
                            longitudeAnterior != null)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [
                                  LatLng(latitudeAnterior!, longitudeAnterior!),
                                  LatLng(latitudeAtual!, longitudeAtual!),
                                ],
                                strokeWidth: 4,
                              ),
                            ],
                          ),
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          userAgentPackageName: 'com.db.locationapp',
                        ),

                        MarkerLayer(
                          markers: [
                            if (editando)
                              Marker(
                                point: LatLng(
                                  latitudeAnterior!,
                                  longitudeAnterior!,
                                ),
                                width: 80,
                                height: 80,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.blue,
                                  size: 40,
                                ),
                              ),

                            Marker(
                              point: LatLng(latitudeAtual!, longitudeAtual!),
                              width: 80,
                              height: 80,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            if (editando) ...[
              const Text(
                'Atualizar status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<StatusPedido>(
                // ignore: deprecated_member_use
                value: statusSelecionado,

                decoration: const InputDecoration(border: OutlineInputBorder()),

                items: StatusPedido.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.name),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    statusSelecionado = value!;
                  });
                },
              ),
            ],

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: salvar,

                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

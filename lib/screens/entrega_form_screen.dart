import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/entrega.dart';
import '../repository/entrega_repository.dart';

class EntregaFormScreen extends StatefulWidget {
  final Entrega? entrega;

  const EntregaFormScreen({super.key, this.entrega});

  @override
  State<EntregaFormScreen> createState() => _EntregaFormScreenState();
}

class _EntregaFormScreenState extends State<EntregaFormScreen> {
  final repository = EntregaRepository();

  final destinatarioController = TextEditingController();

  final enderecoController = TextEditingController();

  StatusPedido statusSelecionado = StatusPedido.pendente;

  double? latitude;
  double? longitude;

  bool carregandoLocalizacao = true;

  bool get editando => widget.entrega != null;

  @override
  void initState() {
    super.initState();

    if (editando) {
      destinatarioController.text = widget.entrega!.destinatario;

      enderecoController.text = widget.entrega!.endereco;

      latitude = widget.entrega!.latitude;

      longitude = widget.entrega!.longitude;

      statusSelecionado = widget.entrega!.status;

      carregandoLocalizacao = false;
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
      latitude = position.latitude;

      longitude = position.longitude;

      carregandoLocalizacao = false;
    });
  }

  Future<void> salvar() async {
    if (latitude == null || longitude == null) {
      return;
    }

    if (editando) {
      await repository.atualizarEntrega(
        Entrega(
          idEntrega: widget.entrega!.idEntrega,

          destinatario: destinatarioController.text,

          endereco: enderecoController.text,

          status: statusSelecionado,

          latitude: latitude!,

          longitude: longitude!,

          dataHora: DateTime.now(),
        ),
      );
    } else {
      await repository.inserirEntrega(
        Entrega(
          idEntrega: '',

          destinatario: destinatarioController.text,

          endereco: enderecoController.text,

          status: StatusPedido.pendente,

          latitude: latitude!,

          longitude: longitude!,

          dataHora: DateTime.now(),
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

            Container(
              height: 300,
              clipBehavior: Clip.hardEdge,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),

              child: carregandoLocalizacao
                  ? const Center(child: CircularProgressIndicator())
                  : latitude == null || longitude == null
                  ? const Center(
                      child: Text('Não foi possível obter localização'),
                    )
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(latitude!, longitude!),

                        initialZoom: 16,
                      ),

                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          userAgentPackageName: 'com.db.locationapp',
                        ),

                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(latitude!, longitude!),

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

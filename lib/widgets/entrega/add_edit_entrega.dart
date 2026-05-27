import 'package:flutter/material.dart';
import 'package:locationapp/models/entrega.dart';

class EntregaCard extends StatelessWidget {
  final Entrega entrega;
  final String statusAtual;

  final VoidCallback onEditar;
  final VoidCallback onExcluir;
  final VoidCallback onVerCompleto;

  const EntregaCard({
    super.key,
    required this.entrega,
    required this.statusAtual,
    required this.onEditar,
    required this.onExcluir,
    required this.onVerCompleto,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entrega.destinatario,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text('ID: ${entrega.idEntrega}'),
            Text('Endereço: ${entrega.endereco}'),

            Text('Latitude: ${entrega.latitude}'),

            Text('Longitude: ${entrega.longitude}'),

            const SizedBox(height: 10),

            Chip(label: Text(statusAtual)),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: onEditar,
                  child: const Text('Editar'),
                ),

                ElevatedButton(
                  onPressed: onVerCompleto,
                  child: const Text('Ver completo'),
                ),

                ElevatedButton(
                  onPressed: onExcluir,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Excluir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

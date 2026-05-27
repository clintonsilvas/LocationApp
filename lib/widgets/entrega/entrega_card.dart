import 'package:flutter/material.dart';
import 'package:locationapp/models/entrega.dart';

class EntregaCard extends StatelessWidget {
  final Entrega entrega;

  final VoidCallback onEditar;
  final VoidCallback onExcluir;
  final VoidCallback onVerCompleto;

  const EntregaCard({
    super.key,
    required this.entrega,
    required this.onEditar,
    required this.onExcluir,
    required this.onVerCompleto,
  });

  Color corStatus(StatusPedido status) {
    switch (status) {
      case StatusPedido.pendente:
        return Colors.orange;

      case StatusPedido.saiuParaEntrega:
        return Colors.blue;

      case StatusPedido.emTransporte:
        return Colors.purple;

      case StatusPedido.entregue:
        return Colors.green;
    }
  }

  String textoStatus(StatusPedido status) {
    switch (status) {
      case StatusPedido.pendente:
        return 'Pendente';

      case StatusPedido.saiuParaEntrega:
        return 'Saiu para entrega';

      case StatusPedido.emTransporte:
        return 'Em transporte';

      case StatusPedido.entregue:
        return 'Entregue';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,

      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    entrega.destinatario,

                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Chip(
                  backgroundColor: corStatus(entrega.status),

                  label: Text(
                    textoStatus(entrega.status),

                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Icon(Icons.location_on_outlined),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    entrega.endereco,

                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.calendar_month_outlined),

                const SizedBox(width: 8),

                Text(entrega.dataHora.toString()),
              ],
            ),

            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: Colors.grey.shade100,

                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text('Latitude: ${entrega.latitude}'),

                  const SizedBox(height: 5),

                  Text('Longitude: ${entrega.longitude}'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEditar,

                    icon: const Icon(Icons.edit),

                    label: const Text('Editar'),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onVerCompleto,

                    icon: const Icon(Icons.map),

                    label: const Text('Mapa'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: onExcluir,

                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

                icon: const Icon(Icons.delete),

                label: const Text('Excluir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

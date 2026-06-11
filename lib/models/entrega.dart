class Entrega {
  final String idEntrega;
  final String destinatario;
  final String endereco;
  final StatusPedido status;
  final double latitude;
  final double longitude;
  final DateTime dataHora;
  final bool sincronizado;

  Entrega({
    required this.idEntrega,
    required this.destinatario,
    required this.endereco,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.dataHora,
    this.sincronizado = false,
  });
}

enum StatusPedido { pendente, saiuParaEntrega, emTransporte, entregue }

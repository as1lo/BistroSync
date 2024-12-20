import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Conta {
  final String idMesa;
  final List<Map<String, dynamic>> pedidos;

  Conta({required this.idMesa, required this.pedidos});

  double get totalConta {
    return pedidos.fold(0.0, (total, pedido) {
      return total +
          pedido['itens'].fold(0.0, (sum, item) {
            return sum + (item['preco'] * item['quantidade']);
          });
    });
  }

  void atualizarStatusConta(String idPedido) {
    for (var pedido in pedidos) {
      if (pedido['id'] == idPedido) {
        pedido['statusConta'] = true;
      }
    }
  }
}

class ContaProvider with ChangeNotifier {
  List<Map<String, dynamic>> _pedidos = [];

  List<Map<String, dynamic>> get pedidos => [..._pedidos];

  double get totalConta {
    return _pedidos.fold(0.0, (total, pedido) {
      return total +
          pedido['itens'].fold(0.0, (sum, item) {
            final preco = item['preco'] ?? 0.0;
            final quantidade = item['quantidade'] ?? 0;
            return sum + (preco * quantidade);
          });
    });
  }

  List<Map<String, dynamic>> setPedidos() => _pedidos;

  void adicionarPedido(Map<String, dynamic> pedido) {
    _pedidos.add(pedido);
    notifyListeners();
  }

  void limparPedidos() {
    _pedidos = [];
    notifyListeners();
  }

  void atualizarStatusConta(String idPedido) {
    for (var pedido in _pedidos) {
      if (pedido['id'] == idPedido) {
        pedido['statusConta'] = true;
        notifyListeners();
      }
    }
  }

  Future<void> carregarPedidos(String idMesa) async {
    final pedidosData = await FirebaseFirestore.instance
        .collection('users')
        .doc(idMesa)
        .collection('pedidos')
        .get();

    _pedidos = pedidosData.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    notifyListeners();
  }
}

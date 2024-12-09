import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Pedido {
  final String id; // ID do pedido
  final String idMesa; // ID da mesa
  final DateTime data; // Data do pedido
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final List<Map<String, dynamic>> itens; // Itens do pedido
  final String status; // Status do pedido (pendente, finalizado, etc.)
  final bool statusConta; // Status da conta (se foi paga ou não)
  final num total; // Total do pedido
  final String nomeSessao; // Nome do cliente
  final String idSessao; // sessão do cliente
  final int numMesa;

  Pedido({
    required this.id,
    required this.idMesa,
    required this.numMesa,
    required this.data,
    required this.itens,
    required this.total,
    required this.idSessao,
    required this.nomeSessao,
    this.dataInicio,
    this.dataFim,
    this.status = 'pendente', // Status padrão é 'pendente'
    this.statusConta = false, // Status da conta é 'false' por padrão
  });

  Map<String, dynamic> toMap() {
    return {
      'idMesa': idMesa,
      'data': data,
      'itens': itens,
      'status': status,
      'statusConta': statusConta,
      'total': total,
      'idSessao': idSessao,
      'nomeSessao': nomeSessao
    };
  }
}

class CarrinhoItem {
  final String id; // ID do produto
  final String nome; // Nome do produto
  final int quantidade; // Quantidade do produto
  final double preco; // Preço unitário do produto

  CarrinhoItem({
    required this.id,
    required this.nome,
    required this.quantidade,
    required this.preco,
  });

  double get total => quantidade * preco; // Calcula o total para o item
}

class Carrinho {
  Map<String, CarrinhoItem> _itens = {};

  Map<String, CarrinhoItem> get itens => {..._itens};

  int get totalItens => _itens.length;

  double get totalCarrinho {
    return _itens.values.fold(0.0, (total, item) => total + item.total);
  }

  Future<String> gerarIdPedidoUnico(String userId) async {
    final uuid = Uuid();
    String idPedido = uuid.v4();

    final pedidosSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('pedidos')
        .doc(idPedido)
        .get();

    if (pedidosSnapshot.exists) {
      return await gerarIdPedidoUnico(userId);
    }

    return idPedido;
  }

  Future<void> salvarPedido(
      String idMesa, String userId, String idSessao, String nome, int numMesa) async {
    String idPedido = await gerarIdPedidoUnico(userId);

    final pedido = Pedido(
      id: idPedido,
      idSessao: idSessao,
      nomeSessao: nome,
      idMesa: idMesa,
      numMesa: numMesa,
      data: DateTime.now(),
      total: totalCarrinho,
      itens: _itens.values
          .map((item) => {
                'id': item.id,
                'nome': item.nome,
                'quantidade': item.quantidade,
                'preco': item.preco,
              })
          .toList(),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('pedidos')
        .doc(pedido.id)
        .set(pedido.toMap());
  }

  void adicionarItem(String id, String nome, double preco) {
    if (_itens.containsKey(id)) {
      _itens.update(
        id,
        (itemExistente) => CarrinhoItem(
          id: itemExistente.id,
          nome: itemExistente.nome,
          quantidade: itemExistente.quantidade + 1,
          preco: itemExistente.preco,
        ),
      );
    } else {
      _itens.putIfAbsent(
        id,
        () => CarrinhoItem(
          id: id,
          nome: nome,
          quantidade: 1,
          preco: preco,
        ),
      );
    }
  }

  void removerItem(String id) {
    _itens.remove(id);
  }

  void reduzirQuantidade(String id) {
    if (!_itens.containsKey(id)) return;

    if (_itens[id]!.quantidade > 1) {
      _itens.update(
        id,
        (itemExistente) => CarrinhoItem(
          id: itemExistente.id,
          nome: itemExistente.nome,
          quantidade: itemExistente.quantidade - 1,
          preco: itemExistente.preco,
        ),
      );
    } else {
      removerItem(id);
    }
  }

  void limparCarrinho() {
    _itens = {};
  }
}

class CarrinhoProvider with ChangeNotifier {
  Carrinho _carrinho = Carrinho();

  Map<String, CarrinhoItem> get itens => _carrinho.itens;

  int get totalItens => _carrinho.totalItens;

  double get totalCarrinho => _carrinho.totalCarrinho;

  void adicionarItem(String id, String nome, double preco) {
    _carrinho.adicionarItem(id, nome, preco);
    notifyListeners();
    print('Item adicionado ao carrinho: $id');
  }

  void removerItem(String id) {
    _carrinho.removerItem(id);
    notifyListeners();
  }

  void reduzirQuantidade(String id) {
    _carrinho.reduzirQuantidade(id);
    notifyListeners();
  }

  void limparCarrinho() {
    _carrinho.limparCarrinho();
    notifyListeners();
  }

  Future<void> salvarPedido(
      String idMesa, String userId, String idSessao, String nome, int numMesa) async {
    await _carrinho.salvarPedido(idMesa, userId, idSessao, nome, numMesa);
    notifyListeners();
  }
}

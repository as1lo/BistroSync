import 'package:flutter/material.dart';

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

  // Obter todos os itens do carrinho
  Map<String, CarrinhoItem> get itens => {..._itens};

  // Obter o número total de itens no carrinho
  int get totalItens => _itens.length;

  // Obter o valor total do carrinho
  double get totalCarrinho {
    return _itens.values
        .fold(0.0, (total, item) => total + item.total);
  }

  // Adicionar um item ao carrinho
  void adicionarItem(String id, String nome, double preco) {
    if (_itens.containsKey(id)) {
      // Se o item já existe, aumenta a quantidade
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
      // Caso contrário, adiciona um novo item
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

  // Remover um item do carrinho
  void removerItem(String id) {
    _itens.remove(id);
  }

  // Reduzir a quantidade de um item
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
      removerItem(id); // Remove o item se a quantidade for 1
    }
  }

  // Limpar o carrinho
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

  // Remover um item do carrinho
  void removerItem(String id) {
    _carrinho.removerItem(id);
    notifyListeners(); 
  }

  // Reduzir a quantidade de um item
  void reduzirQuantidade(String id) {
    _carrinho.reduzirQuantidade(id);
    notifyListeners(); 
  }

  // Limpar o carrinho
  void limparCarrinho() {
    _carrinho.limparCarrinho();
    notifyListeners(); 
  }
}

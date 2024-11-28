import 'dart:convert';

import 'package:bistro/screens/widgets/cores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
//import 'package:smart_pagamento/totalizadores/totalVendidos.dart';

class RegistraVenda extends StatefulWidget {
  final String? vendaId;
  final String? email;

  RegistraVenda({super.key, this.vendaId, this.email});

  @override
  _RegistraVendaState createState() => _RegistraVendaState();
}

class _RegistraVendaState extends State<RegistraVenda> {
  NumberFormat formatoDouble = NumberFormat("#,##0.00", "pt_BR");
  final _formKey = GlobalKey<FormState>();
  double _totalLiq = 0;
  double _totalVenda = 0;
  String? _dadosCliente;
  Map<String, dynamic> _dadosProduto = {};
  int quantidade = 1;
  String? _clienteId;
  String? _produtoId;

  //Listas para visualizar no dropdownsearch
  List<String> _listClienteDrop = [];
  List<Map<String, dynamic>> _listProdutoDrop = [];

  //lista para os produtos deletados
  List<Map<String, dynamic>> _listProdutoDropDeleted = [];

  //Lista dos produtos escolhidos
  List<Map<String, dynamic>> _listProdutosEscolhidos = [];

  //Lista da quantidade dos produtos escolhidos
  //List<int> _listQuantProd = [];

  //Lista do preço dos produtos
  //List<double?> _listPriceProd = [];

  //Lista do valor de desconto
  //List<int?> _listDescontoProd = [];

  //Lista do valor descontado
  List<double> _listValorDescontadoProd = [];

  List<double> _listValorBrutoProd = [];

  List<double> _listValorLiqProd = [];

  List<String?> _listProdutoId = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _setListCliente();
    _setListProduto();

    if (widget.vendaId != null) {
      _loadVenda();
    }
  }

  List data = [];

  // Função para fazer a requisição HTTP
  Future<void> fetchData() async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      
      setState(() {
        data = json.decode(response.body);
      });
    } else {
      
      throw Exception('Falha ao carregar dados');
    }
  }

  Future<void> sendAssinaturaData(String name, String value, String telefone) async {
  final url = Uri.parse('https://bbc9-186-250-7-224.ngrok-free.app/criar-assinatura');

  // Corpo da requisição que será enviado
  final Map<String, dynamic> requestBody = {
    "name": name,
    "value": value,
    "telefone": telefone,
  };

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),  // Convertendo o mapa em JSON
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Assinatura criada com sucesso!');
      print('Resposta: ${response.body}');
    } else {
      print('Erro ao criar assinatura: ${response.statusCode}');
      print('Resposta: ${response.body}');
    }
  } catch (e) {
    print('Erro ao enviar a requisição: $e');
  }
}


  //ADICIONAR OS DADOS DO CLIENTE NA LISTA DO DROPDOWNSEARCH
  void _setListCliente() async {
    FirebaseFirestore.instance
        .collection('clientes')
        .where('email_user', isEqualTo: widget.email)
        .snapshots()
        .listen((query) {
      setState(() {
        _listClienteDrop = [];

        query.docs.forEach((doc) {
          setState(() {
            _listClienteDrop.add(
                '${doc['name']} | Email: ${doc['email']} | Whatsapp: ${doc['whatsapp']}');
          });
        });
      });
    });
  }

  //ADICIONAR OS DADOS DO PRODUTO NA LISTA DO DROPDOWNSEARCH
  void _setListProduto() async {
    FirebaseFirestore.instance
        .collection('products')
        .where('email_user', isEqualTo: widget.email)
        .snapshots()
        .listen((query) {
      setState(() {
        _listProdutoDrop = [];

        query.docs.forEach((doc) {
          setState(() {
            _listProdutoDrop.add({
              'nome': doc['name'],
            });
          });
        });
      });
    });
  }

  //BUSCAR E INSERIR O ID DO CLIENTE
  Future<String?> fetchAndSetIdCliente(String? cliSelecionado) async {
    var query = await FirebaseFirestore.instance
        .collection('clientes')
        .where('email_user', isEqualTo: widget.email)
        .get();
    for (var doc in query.docs) {
      if (cliSelecionado ==
          '${doc['name']} | Email: ${doc['email']} | Whatsapp: ${doc['whatsapp']}') {
        return doc.id;
      }
    }
    return null;
  }

  //BUSCAR E INSERIR O ID DO PRODUTO
  Future<String?> fetchAndSetIdProduto(String? prodSelecionado) async {
    var query = await FirebaseFirestore.instance
        .collection('products')
        .where('email_user', isEqualTo: widget.email)
        .get();
    for (var doc in query.docs) {
      if (prodSelecionado == '${doc['name']}') {
        return doc.id;
      }
    }
    return null;
  }

  //buscar preço do produto
  Future<double?> fetchPriceProduto(String? prodSelecionado) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('email_user', isEqualTo: widget.email)
        .get();
    for (var doc in querySnapshot.docs) {
      if (prodSelecionado == '${doc['name']}') {
        return doc['price'];
      }
    }
    return null;
  }

  //BUSCAR DESCONTO DO PRODUTO
  Future<int?> fetchDescontoProduto(String? prodSelecionado) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('email_user', isEqualTo: widget.email)
        .get();
    for (var doc in querySnapshot.docs) {
      if (prodSelecionado == '${doc['name']}') {
        return doc['desconto'];
      }
    }
    return null;
  }

  //ADICIONAR DADOS DO PRODUTO NA LISTA DE PRODUTOS ESCOLHIDOS
  void _addProduto(Map<String, dynamic> dadosProduto, int quantidade,
      double? price, int? desconto, String? produtoId) {
    double valorDescontado = 0;

    setState(() {
      if (price != null) {
        _totalVenda += quantidade * price;

        if (quantidade > 1) {
          valorDescontado = ((desconto ?? 0.0) / 100) * (quantidade * price);
        }

        _totalLiq += (quantidade * price) - valorDescontado;
      }

      _listProdutoId.add(_produtoId);
      _listValorLiqProd.add((quantidade * (price ?? 0)) - valorDescontado);
      _listValorBrutoProd.add(quantidade * (price ?? 0));
      _listValorDescontadoProd.add(valorDescontado);
      _listProdutosEscolhidos.add({
        'nome': dadosProduto['nome'],
        'price': price,
        'desconto': desconto,
        'quantidade': quantidade,
        'produtoId': _produtoId,
        'valorDescontado': valorDescontado,
        'valorLiq': (quantidade * (price ?? 0)) - valorDescontado,
        'valorBruto': quantidade * (price ?? 0)
      });
      //_listQuantProd.add(quantidade);
      //_listPriceProd.add(price);
      //_listDescontoProd.add(desconto);

      //_listProdutoDrop.remove(dadosProduto['nome']);
      //_listProdutoDropDeleted.add(dadosProduto['nome']);
      _listProdutoDrop
          .removeWhere((produto) => produto['nome'] == dadosProduto['nome']);

      _listProdutoDropDeleted.add({'nome': dadosProduto['nome']});
    });
  }

  //REMOVER DADOS DO PRODUTO DA LISTA DE PRODUTOS ESCOLHIDOS
  void _removeProduto(int index) {
    try {
      double? price = _listProdutosEscolhidos[index]['price'];
      int quantidade = _listProdutosEscolhidos[index]['quantidade'];
      double valorDescontado =
          _listProdutosEscolhidos[index]['valorDescontado'];

      setState(() {
        if (price != null) {
          _totalVenda -= quantidade * price;

          _totalLiq -= (quantidade * price) - valorDescontado;
        }
        print('_listProdutosEscolhidos: ${_listProdutosEscolhidos.length}');
        print('_listProdutoDrop: ${_listProdutosEscolhidos.length}');
        print('_listProdutoDropDeleted: ${_listProdutosEscolhidos.length}');
        //_listProdutoId.removeAt(index);
        //_listValorLiqProd.removeAt(index);
        //_listValorBrutoProd.removeAt(index);
        //_listDescontoProd.removeAt(index);
        //_listValorDescontadoProd.removeAt(index);
        _listProdutosEscolhidos.removeAt(index);
        //_listQuantProd.removeAt(index);
        //_listPriceProd.removeAt(index);
        _listProdutoDrop.add(_listProdutoDropDeleted[index]);
        _listProdutoDropDeleted.removeAt(index);

        if (_listProdutosEscolhidos.isEmpty) {
          _totalVenda = 0;
          _totalLiq = 0;
        }
      });
      print('INDEX: $index');
    } catch (e) {
      print(e);
    }
  }

  //Showdialog para selecionar produtos e a quantidade
  void _setProdutosAndQuant(BuildContext context) {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    int quantidade = 1;
    double? price;
    int? desconto;
    _dadosProduto = {};

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text(
              "Escolha o Produto",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            content: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //ESCOLHER O PRODUTO
                    DropdownSearch<String>(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, escolha o produto!';
                        }
                        return null;
                      },
                      popupProps: const PopupProps.menu(
                          showSelectedItems: true,
                          //disabledItemFn: (String s) => s.startsWith('I'),
                          showSearchBox: true),
                      items: _listProdutoDrop
                          .map((produto) => produto['nome'].toString())
                          .toList(),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                          ),
                          labelText: "Produto",
                          hintText: "Selecione um dos produtos.",
                        ),
                      ),
                      onChanged: (String? prodSelecionado) {
                        setState(() async {
                          _dadosProduto['nome'] = prodSelecionado.toString();

                          _produtoId =
                              await fetchAndSetIdProduto(prodSelecionado);
                          price = await fetchPriceProduto(prodSelecionado);
                          desconto =
                              await fetchDescontoProduto(prodSelecionado);
                          print('PRICE ESCOLHE PRODUTO: $price');
                        });
                      },
                      selectedItem: _dadosProduto['nome'],
                    ),

                    const SizedBox(height: 20),

                    //QUANTIDADE DO PRODUTO
                    Text(
                      'Quantidade: $quantidade',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //BOTÃO MENOS
                        ElevatedButton(
                            onPressed: () {
                              if (quantidade > 1) {
                                setState(() {
                                  quantidade--;
                                });
                              }
                            },
                            child: const Text('-1')),

                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                quantidade++;
                              });
                            },
                            child: const Text('+1')),
                      ],
                    ),
                  ],
                )),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: corPadrao(),
                  minimumSize: const Size(20, 42),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
                child: const Text(
                  "Adicionar",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addProduto(
                        _dadosProduto, quantidade, price, desconto, _produtoId);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  void _loadVenda() async {
    setState(() {
      _isLoading = true;
    });

    DocumentSnapshot venda = await FirebaseFirestore.instance
        .collection('vendas')
        .doc(widget.vendaId)
        .get();

    _dadosCliente = venda['cliente'];
    //mostrar em uma área os itens da venda com a coleção itens_vendas
    //valor da venda

    setState(() {
      _isLoading = false;
    });
  }

  void _registerOrEditVenda() async {
    DateTime datahora = DateTime.now();
    DateFormat formatoData = DateFormat('dd/MM/yyyy | HH:mm');
    String nomeCliente = '';
    String telefone = '';
    
    if (_formKey.currentState!.validate()) {
      var query = await FirebaseFirestore.instance
          .collection('clientes')
          .where('email_user', isEqualTo: widget.email)
          .get();
      for (var doc in query.docs) {
        if (_dadosCliente == '${doc['name']} | Email: ${doc['email']} | Whatsapp: ${doc['whatsapp']}') {
          nomeCliente = doc['name'];
          telefone = doc['whatsapp'];
        }
      }
      if (widget.vendaId == null) {
        // Registrar venda
        DocumentReference vendaRef =
            await FirebaseFirestore.instance.collection('vendas').add({
          'cliente': _dadosCliente,
          'nome_cliente': nomeCliente,
          'idcliente': _clienteId,
          'total_bruto': _totalVenda,
          'total_liq': _totalLiq,
          'data_hora': formatoData.format(datahora),
          'data': datahora,
          'email_user': widget.email
        });

        // Registrar itens_vendas
        for (var index = 0; index < _listProdutosEscolhidos.length; index++) {
          await FirebaseFirestore.instance.collection('itens_vendas').add({
            'idvenda': vendaRef.id,
            'produto': _listProdutosEscolhidos[index]['nome'],
            'idproduto': _listProdutosEscolhidos[index]['produtoId'],
            'quantidade': _listProdutosEscolhidos[index]['quantidade'],
            'total_bruto_prod': _listProdutosEscolhidos[index]['valorBruto'],
            'valor_descontado': _listProdutosEscolhidos[index]['valorDescontado'],
            'total_liq_prod': _listProdutosEscolhidos[index]['valorLiq'],
            'email_user': widget.email
          });
        }

        // Chame a função sendAssinaturaData() com os parâmetros adequados
        //await sendAssinaturaData(nomeCliente, _totalVenda.toString(), telefone); // Exemplo de telefone

      } else {
        // Atualizar venda
        await FirebaseFirestore.instance
            .collection('vendas')
            .doc(widget.vendaId)
            .update({
          'cliente': _dadosCliente,
          'idcliente': _clienteId,
          'total_bruto': _totalVenda,
          'total_liq': _totalLiq,
          'data_hora': formatoData.format(datahora),
          'data': datahora,
          'email_user': widget.email
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Venda ${widget.vendaId == null ? 'registrada' : 'atualizada'} com sucesso!')));
      _listProdutosEscolhidos.clear();

      for (var i = 0; i < _listProdutoDropDeleted.length; i++) {
        _listProdutoDrop.add(_listProdutoDropDeleted[i]);
        _listProdutoDropDeleted.removeAt(i);
      }

      if (_listProdutosEscolhidos.isEmpty) {
        _totalVenda = 0;
        _totalLiq = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print(_totalVenda);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.vendaId == null ? 'Registro de Venda' : 'Edição de Venda',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 38,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: corPadrao(),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 0),
                    )
                  ],
                ),
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      //column principal
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // row dos valores e cliente
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //column de valores
                              Expanded(
                                  child: Container(
                                //color: Colors.amber,
                                //height: 400,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Total Bruto: R\$${formatoDouble.format(_totalVenda)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        )),
                                    Text(
                                        'Total Liq.: R\$${formatoDouble.format(_totalLiq)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        )),
                                  ],
                                ),
                              )),

                              //column de cliente e produto
                              Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: (Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //CLIENTES
                                          const Text('Clientes',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20)),

                                          const SizedBox(
                                            height: 8,
                                          ),
                                          DropdownSearch<String>(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty ||
                                                  _listProdutosEscolhidos
                                                      .isEmpty) {
                                                return 'Por favor, escolha o cliente e/ou produto!';
                                              }
                                              return null;
                                            },
                                            popupProps: const PopupProps.menu(
                                                showSelectedItems: true,
                                                //disabledItemFn: (String s) => s.startsWith('I'),
                                                showSearchBox: true),
                                            items: _listClienteDrop,
                                            dropdownDecoratorProps:
                                                const DropDownDecoratorProps(
                                              dropdownSearchDecoration:
                                                  InputDecoration(
                                                labelText:
                                                    "Selecione um dos clientes.",
                                                //hintText: "Selecione um dos clientes.",
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              30.0)),
                                                ),
                                              ),
                                            ),
                                            onChanged:
                                                (String? cliSelecionado) {
                                              setState(() async {
                                                _dadosCliente = cliSelecionado;
                                                _clienteId =
                                                    await fetchAndSetIdCliente(
                                                        cliSelecionado);
                                              });
                                            },
                                            selectedItem: _dadosCliente,
                                          ),
                                          const SizedBox(height: 20),

                                          //BOTÃO PARA ADICIONAR PRODUTO NA VENDA
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: gradientBtn(),
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                _setProdutosAndQuant(context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  fixedSize: Size(
                                                      size.width * 0.2,
                                                      size.height * 0.01),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5))),
                                              child: Text('Adicionar Produtos',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          size.height * 0.022,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                        ],
                                      ))))
                            ],
                          ),
                          //PRODUTOS

                          SingleChildScrollView(
                            child: SizedBox(
                              height: size.height * 0.45,
                              child: DataTable(
                                columnSpacing: size.width * 0.045,
                                horizontalMargin: 0,
                                columns: [
                                  DataColumn(
                                      label: Text(
                                    'Produto',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: size.height * 0.03),
                                  )),
                                  DataColumn(
                                      label: Text('Preço',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: size.height * 0.03))),
                                  DataColumn(
                                      label: Text('Desconto (%)',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: size.height * 0.03))),
                                  DataColumn(
                                      label: Text('Quantidade',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: size.height * 0.03))),
                                  DataColumn(
                                      label: Text('Total Bruto',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: size.height * 0.03))),
                                  DataColumn(
                                      label: Text('Valor Descontado',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: size.height * 0.03))),
                                  DataColumn(
                                      label: Text('Total Liq.',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: size.height * 0.03))),
                                  DataColumn(
                                      label: Text('Deletar',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: size.height * 0.03))),
                                ],
                                rows: _listProdutosEscolhidos
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry
                                      .key; // Aqui está o índice do item atual
                                  var produto = entry.value;
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(produto['nome'],
                                          style: TextStyle(
                                              fontSize: size.height * 0.025))),
                                      DataCell(Text('R\$ ${produto['price']}',
                                          style: TextStyle(
                                              fontSize: size.height * 0.025))),
                                      DataCell(Text('${produto['desconto']}%',
                                          style: TextStyle(
                                              fontSize: size.height * 0.025))),
                                      DataCell(Text('${produto['quantidade']}',
                                          style: TextStyle(
                                              fontSize: size.height * 0.025))),
                                      DataCell(Text(
                                          'R\$ ${formatoDouble.format(produto['valorBruto'])}',
                                          style: TextStyle(
                                              fontSize: size.height * 0.025))),
                                      DataCell(Text(
                                          'R\$ ${formatoDouble.format(produto['valorDescontado'])}',
                                          style: TextStyle(
                                              fontSize: size.height * 0.025))),
                                      DataCell(Text(
                                          'R\$ ${formatoDouble.format(produto['valorLiq'])}',
                                          style: TextStyle(
                                              fontSize: size.height * 0.025))),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    backgroundColor:
                                                        Colors.black87,
                                                    title: const Text(
                                                        'Deseja excluir o produto?',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: const Text(
                                                            'Cancelar',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors:
                                                                gradientBtn(),
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: TextButton(
                                                          onPressed: () {
                                                            _removeProduto(
                                                                index);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: const Text(
                                                              'Excluir',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          //VISUALIZAÇÃO DOS PRODUTOS DA VENDA
                          /*
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                                itemCount: _listProdutosEscolhidos.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                      child: ListTile(
                                          title: Text(
                                              _listProdutosEscolhidos[index]),
                                          subtitle: Text(
                                              'Total Bruto: ${_listValorBrutoProd[index]} | Desconto Aplicado: ${_listValorDescontadoProd[index]} | Valor Liq.: ${_listValorLiqProd[index]}'),
                                          trailing:
                                              _removeAtListProdutosEscolhidos(
                                                  index)));
                                }),
                          ),
                          */
                          const SizedBox(height: 20),

                          //BOTÃO DE CONFIRMAÇÃO
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientBtn(),
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ElevatedButton(
                              onPressed: _registerOrEditVenda,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  fixedSize: Size(
                                      size.width * 0.2, size.height * 0.01),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5))),
                              child: Text(
                                  widget.vendaId != null
                                      ? 'Editar'
                                      : 'Cadastrar',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.height * 0.022,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    )),
              ));
  }
}

import 'dart:convert'; // For base64 decoding

import 'package:bistro/classes/carrinho.dart';
import 'package:bistro/classes/user.dart';
import 'package:bistro/screens/widgets/cores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Opcao extends StatefulWidget {
  final BistroUser user;
  final List<dynamic> categories;

  Opcao({required this.user, required this.categories});
  @override
  _OpcaoState createState() => _OpcaoState();
}

class _OpcaoState extends State<Opcao> {
  List<Map<String, dynamic>> produtos = [];

  @override
  void initState() {
    super.initState();
    print('categories: ${widget.categories}');
    _loadData();
  }

  void _loadData() async {
    print('id: ${widget.categories[0]['categoryId']}');
    print('id user: ${widget.user.idMaster}');

    var data = await _getProducts(widget.categories[0]['categoryId']);

    setState(() {
      produtos = data;
    });

    //print(data);
    //print('PRODUTOS DO LOAD: $produtos');
  }

  Future<List<Map<String, dynamic>>> _getProducts(String idCategory) async {
    var listProdutos = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.idMaster)
        .collection('categories')
        .doc(idCategory)
        .collection('products')
        .get();

    // Mapeando os dados e incluindo o campo 'id' de cada documento
    return listProdutos.docs.map((doc) {
      var produto = doc.data() as Map<String, dynamic>;
      produto['id'] = doc.id; // Adicionando o campo 'id' ao mapa
      return produto;
    }).toList();
  }

  Widget _buildMenuList() {
    try {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          print(category);

          return ListTile(
            title: Text(
              category['categoryName'] ?? 'Nenhuma opção disponível.',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              produtos = await _getProducts(category['id']);

              setState(() {});

              print(
                  'Tapped on ${category['categoryName'] ?? 'Nenhuma opção disponível.'}');
            },
          );
        },
      );
    } catch (e) {
      print(e);
      return Center(
        child: Text(
          'Nenhuma opção disponível.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final carrinhoProvider = Provider.of<CarrinhoProvider>(context);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      endDrawer: Drawer(
        child: CarrinhoModal(carrinhoProvider: carrinhoProvider),
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            alignment: Alignment.center,
            width: size.width * 0.35,
            color: hexToColor(widget.user.primaryColor!),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        padding: EdgeInsets.all(size.width * 0.004),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius:
                              BorderRadius.circular(size.width * 0.01),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.table_bar, color: Colors.white),
                            SizedBox(width: size.width * 0.001),
                            Text(
                              'Mesa ${widget.user.num}',
                              style: TextStyle(
                                fontSize: size.width * 0.01,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      )
                    ]),
                    SizedBox(height: size.width * 0.01),
                    Image.memory(
                      base64Decode(widget.user.logobase64!),
                      fit: BoxFit.cover,
                      width: size.width * 0.25,
                    ),
                  ],
                ),

                //menu
                Container(
                  height: size.height * 0.4,
                  width: size.width * 0.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(size.width * 0.01),
                    //border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: _buildMenuList(),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Column(
              children: [
                ElevatedButton(
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    child: Text('Carrinho')),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: produtos.length,
                    itemBuilder: (context, index) {
                      final produto = produtos[index];
                      //print('PRODUTO: $produto');

                      return Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: size.width * 0.01,
                            vertical: size.width * 0.01),
                        child: Card(
                          child: Container(
                            height: size.height * 0.3,
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                              size.width * 0.01),
                                          bottomLeft: Radius.circular(
                                              size.width * 0.01)),
                                      image: DecorationImage(
                                          image: MemoryImage(base64Decode(
                                              produto['image_base64'])),
                                          fit: BoxFit.cover)),
                                  height: size.height * 0.3,
                                  width: size.width * 0.15,
                                ),
                                Container(
                                  padding: EdgeInsets.all(size.width * 0.01),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            produto['name'],
                                            style: TextStyle(
                                                fontSize: size.width * 0.023,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(produto['description'],
                                              style: TextStyle(
                                                fontSize: size.width * 0.012,
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: size.height * 0.05,
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                'R\$${produto['price'].toString()}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize:
                                                        size.height * 0.03),
                                              ),
                                              Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  hexToColor(widget
                                                                      .user
                                                                      .primaryColor!),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        size.width *
                                                                            0.01),
                                                              )),
                                                      onPressed: () =>
                                                          carrinhoProvider
                                                              .adicionarItem(
                                                                  produto['id'],
                                                                  produto[
                                                                      'name'],
                                                                  produto[
                                                                      'price']),
                                                      child: Text(
                                                        'Adicionar',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      )))
                                            ]),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CarrinhoModal extends StatelessWidget {
  final CarrinhoProvider carrinhoProvider;

  const CarrinhoModal({super.key, required this.carrinhoProvider});

  @override
  Widget build(BuildContext context) {
    final itensCarrinho = carrinhoProvider.itens.values.toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBar(
            title: const Text('Meu Carrinho'),
            automaticallyImplyLeading: false,
          ),
          Expanded(
            child: itensCarrinho.isEmpty
                ? const Center(
                    child: Text('Seu carrinho está vazio!'),
                  )
                : ListView.builder(
                    itemCount: itensCarrinho.length,
                    itemBuilder: (ctx, i) {
                      final item = itensCarrinho[i];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(item.quantidade.toString()),
                        ),
                        title: Text(item.nome),
                        subtitle: Text(
                          'R\$ ${item.preco.toStringAsFixed(2)} x ${item.quantidade}',
                        ),
                        trailing: Text(
                          'R\$ ${item.total.toStringAsFixed(2)}',
                        ),
                      );
                    },
                  ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: R\$ ${carrinhoProvider.totalCarrinho.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          carrinhoProvider.limparCarrinho();
                          Navigator.pop(context); // Fecha o modal
                        },
                        child: const Text('Limpar Carrinho'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Simula o fechamento do pedido
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pedido realizado com sucesso!'),
                            ),
                          );
                          carrinhoProvider.limparCarrinho();
                          Navigator.pop(context); // Fecha o modal
                        },
                        child: const Text('Finalizar Pedido'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

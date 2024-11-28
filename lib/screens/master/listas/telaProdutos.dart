import 'dart:convert';
//import 'dart:typed_data';

import 'package:bistro/classes/api_service.dart';
import 'package:bistro/classes/user.dart';
import 'package:bistro/screens/widgets/cores.dart';
//import 'package:bistro/screens/widgets/editarNumero.dart';
//import 'package:bistro/screens/widgets/exibirLink.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../cadastros/telaCadastroProduto.dart';

class ProductListScreen extends StatefulWidget {
  final String? email;
  //final String tipoUser;
  final String idUser;
  final BistroUser user;

  const ProductListScreen(
      {super.key, required this.email, required this.idUser, required this.user
      //required this.tipoUser
      });

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: corPadrao(),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductRegisterScreen(
                      bistroUser: widget.user,
                    ))),
      ),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Meus Produtos',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 38,
            )),
        centerTitle: true,
        backgroundColor: corPadrao(),
      ),
      body: Container(
        padding: size.width <= 720
            ? const EdgeInsets.only(top: 40, left: 10, right: 10)
            : const EdgeInsets.only(top: 40, left: 50, right: 50),
        child: Column(
          children: [
            TextField(
              cursorColor: corPadrao(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                labelText: 'Pesquisar Produto',
                labelStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400, // Cor da borda
                    width: 2.0, // Espessura da borda
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400, // Cor da borda
                    width: 2.0, // Espessura da borda
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(
                    color:
                        corPadrao(), // Cor da borda quando o campo está focado
                    width: 3.0, // Espessura da borda quando o campo está focado
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collectionGroup('products')
                    .where('status', isEqualTo: true)
                    .where('email_master', isEqualTo: widget.email)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!.docs.where((product) {
                    return product['name']
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery);
                  }).toList();

                  if (products.isEmpty) {
                    return const Center(
                        child: Text('Nenhum produto encontrado',
                            style: TextStyle(fontWeight: FontWeight.bold)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          leading: Image.memory(
                            base64Decode(product['image_base64']),
                            height: 100,
                            width: 100,
                          ),
                          title: Text(
                            product['name'],
                            style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Preço: R\$${product['price']}\nDescrição: ${product['description']}',
                            //style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductRegisterScreen(
                                        productId: product.id,
                                        bistroUser: widget.user,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: gradientBtn(),
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.white),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        //backgroundColor: Colors.black87,
                                        title: const Text(
                                          'Deseja desativar o produto?',
                                          //style:TextStyle(color: Colors.white)
                                        ),

                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Cancelar',
                                                style: TextStyle(
                                                    color:
                                                        Colors.grey.shade400)),
                                          ),
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
                                                onPressed: () async {
                                                  ApiService apiService =
                                                      ApiService();
                                                  try {
                                                    await apiService
                                                        .deletarPlano(
                                                            product['plan_id']);
                                                  } finally {
                                                    _updateStateProduct(
                                                        product.id);
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .transparent,
                                                    fixedSize: Size(
                                                        size.width * 0.1,
                                                        size.height * 0.01),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5))),
                                                child: Text('Desativar',
                                                    style:
                                                        TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                size.height *
                                                                    0.022,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStateProduct(String productId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.id)
        .collection('products')
        .doc(productId)
        .update({'status': false});
  }
}

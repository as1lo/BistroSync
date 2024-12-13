import 'dart:convert';

import 'package:bistro/classes/user.dart';
import 'package:bistro/inutilizados/exibirLink.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../cadastros/telaCadastroProduto.dart';

class CategoryListScreen extends StatefulWidget {
  final BistroUser bistroUser;

  const CategoryListScreen({super.key, required this.bistroUser});

  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Categorias de Produto',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 38,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            Colors.blue, // Substituir pela função `corPadrao()` se necessário
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          _showAddCategoryModal();
        },
      ),
      body: Container(
        padding: size.width <= 720
            ? const EdgeInsets.all(10)
            : const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        child: Column(
          children: [
            TextField(
              cursorColor: Colors.blue,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                labelText: 'Pesquisar Categoria',
                labelStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Colors.blue, width: 3.0),
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
                    .collection('users')
                    .doc(widget.bistroUser.id)
                    .collection('categories')
                    .where('status', isEqualTo: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = snapshot.data!.docs.where((category) {
                    return category['name']
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery);
                  }).toList();

                  if (categories.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhuma categoria encontrada',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Card(
                        child: ExpansionTile(
                          title: Text(
                            category['name'],
                            style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold),
                          ),
                          children: [
                            StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.bistroUser.id)
                                  .collection('categories')
                                  .doc(category.id)
                                  .collection('products')
                                  .where('status', isEqualTo: true)
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot>
                                      productSnapshot) {
                                if (productSnapshot.hasError) {
                                  return Center(
                                      child: Text(
                                          'Erro: ${productSnapshot.error}'));
                                }

                                if (productSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                final products = productSnapshot.data!.docs;

                                if (products.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child:
                                        Text('Nenhum produto nesta categoria'),
                                  );
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: products.length,
                                  itemBuilder: (context, productIndex) {
                                    final product = products[productIndex];

                                    return ListTile(
                                      leading: Image.memory(
                                        base64Decode(product['image_base64']),
                                      ),
                                      title: Text(product['name']),
                                      subtitle:
                                          Text('Preço: R\$${product['price']}'),
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
                                                    bistroUser:
                                                        widget.bistroUser,
                                                    categoryId: category.id,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () async {
                                              bool result =
                                                  await showModal(context) ??
                                                      false;

                                              if (result) {
                                                _deactivateProduct(
                                                    category.id, product.id);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      minimumSize: Size(double.minPositive, 45),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                  onPressed: () async {
                                    bool result =
                                        await showModal(context) ?? false;

                                    if (result) {
                                      _deactivateCategory(category.id);
                                    }
                                  },
                                  child: const Text(
                                    'Desativar Categoria',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      minimumSize: Size(double.minPositive, 45),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductRegisterScreen(
                                          categoryId: category.id,
                                          bistroUser: widget.bistroUser,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Adicionar Produto',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      minimumSize: Size(double.minPositive, 45),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                  onPressed: () async {
                                    await _showOptionsModal(category.id, category['name']);
                                  },
                                  child: const Text(
                                    'Opção de Menu',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
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

  Future<void> _showOptionsModal(String categoryId, String categoryName) async {
    try {

      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.bistroUser.id);


      DocumentSnapshot userSnapshot = await userRef.get();


      List<dynamic> options = userSnapshot['options'] ?? [];

      // Verifique se há opções disponíveis
      if (options.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Nenhuma opção disponível para selecionar.'),
        ));
        return;
      }

      // Exibe o modal com os itens de options
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Selecione um item de opções'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  return ListTile(
                    title: Text(option['name'] ?? 'Sem nome'),
                    onTap: () {
                      // Atualiza o item selecionado com a categoria
                      _addCategoryToOption(categoryId, index, options, userRef, categoryName);
                      Navigator.pop(context); // Fecha o modal
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao exibir opções: $e'),
      ));
    }
  }

  Future<void> _addCategoryToOption(String categoryId, int index,
      List<dynamic> options, DocumentReference userRef, String categoryName) async {
    try {
     
      if (!options[index].containsKey('categories')) {
        options[index]['categories'] = [];
      }

     
      List<dynamic> categories = options[index]['categories'];
      if (!categories.contains(categoryId)) {
        categories.add({'categoryId': categoryId, 'categoryName': categoryName});
      }

      
      await userRef.update({'options': options});

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Categoria adicionada com sucesso!'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao salvar categoria: $e'),
      ));
    }
  }

  void _showAddCategoryModal() {
    final TextEditingController _categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Categoria'),
          content: TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Nome da Categoria'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.minPositive, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  )),
              onPressed: () {
                _addCategory(_categoryController.text.trim());
                Navigator.pop(context);
              },
              child: const Text(
                'Salvar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addCategory(String categoryName) {
    if (categoryName.isEmpty) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.bistroUser.id)
        .collection('categories')
        .add({'name': categoryName, 'status': true});
  }

  void _deactivateCategory(String categoryId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.bistroUser.id)
        .collection('categories')
        .doc(categoryId)
        .update({'status': false});
  }

  void _deactivateProduct(String categoryId, String productId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.bistroUser.id)
        .collection('categories')
        .doc(categoryId)
        .collection('products')
        .doc(productId)
        .update({'status': false});
  }
}

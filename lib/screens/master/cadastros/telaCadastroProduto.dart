import 'dart:convert';
import 'dart:io';
import 'package:bistro/classes/user.dart';
import 'package:bistro/screens/widgets/cores.dart';
import 'package:bistro/screens/widgets/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ProductRegisterScreen extends StatefulWidget {
  final String? productId; // ID do produto (opcional)
  final BistroUser bistroUser; // Objeto da classe BistroUser
  final String? categoryId; // ID da categoria (opcional)

  ProductRegisterScreen({
    super.key,
    this.productId,
    required this.bistroUser,
    this.categoryId,
  });

  @override
  _ProductRegisterScreenState createState() => _ProductRegisterScreenState();
}

class _ProductRegisterScreenState extends State<ProductRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isLoading = false;
  String? base64Image;

  // Cozinhas e categorias disponíveis
  List<String> availableKitchens = [];
  List<String> selectedKitchens = [];
  List<Map<String, String>> categories = []; // [{id: '...', name: '...'}]
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _fetchKitchens();
    _fetchCategories();
    selectedCategoryId = widget.categoryId; // Usar o valor default se fornecido

    if (widget.productId != null) {
      _loadProducts();
    }
  }

  Future<void> _fetchKitchens() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.bistroUser.id)
          .collection('cozinha')
          .get();

      final kitchens =
          querySnapshot.docs.map((doc) => doc['name'].toString()).toList();

      setState(() {
        availableKitchens = kitchens;
      });
    } catch (e) {
      print("Erro ao buscar cozinhas: $e");
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.bistroUser.id)
          .collection('categories')
          .get();

      setState(() {
        categories = querySnapshot.docs
            .map((doc) => {'id': doc.id, 'name': doc['name'].toString()})
            .toList();
      });
    } catch (e) {
      print("Erro ao buscar categorias: $e");
    }
  }

  Future<void> _uploadImageAndSaveProduct() async {
    if (_formKey.currentState!.validate() &&
        _imageFile != null &&
        selectedKitchens.isNotEmpty &&
        selectedCategoryId != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.bistroUser.id)
            .collection('categories')
            .doc(
                selectedCategoryId) // Adiciona o produto na categoria selecionada
            .collection('products')
            .add({
          'name': _nameController.text,
          'price': double.parse(_priceController.text),
          'description': _descriptionController.text,
          'image_base64': base64Image,
          'email_master': widget.bistroUser.email,
          'status': true,
          'kitchens': selectedKitchens,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produto cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        _nameController.clear();
        _priceController.clear();

        setState(() {
          _imageFile = null;
          //selectedKitchens.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar o produto: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, preencha todos os campos, selecione uma imagem, escolha pelo menos uma cozinha e selecione uma categoria.'),
        ),
      );
    }
  }

  void _showKitchenSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Selecione as Cozinhas'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    ...availableKitchens.map((kitchen) {
                      return CheckboxListTile(
                        title: Text(kitchen),
                        value: selectedKitchens.contains(kitchen),
                        onChanged: (bool? selected) {
                          setStateDialog(() {
                            if (selected == true) {
                              selectedKitchens.add(kitchen);
                            } else {
                              selectedKitchens.remove(kitchen);
                            }
                          });
                          setState(() {});
                        },
                      );
                    }),
                    CheckboxListTile(
                      title: Text('Selecionar todas'),
                      value:
                          selectedKitchens.length == availableKitchens.length,
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            selectedKitchens = List.from(availableKitchens);
                          } else {
                            selectedKitchens.clear();
                          }
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadProducts() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.bistroUser.id)
        .collection('categories')
        .doc(widget.categoryId)
        .collection('products')
        .doc(widget.productId)
        .get();

    setState(() {
      _nameController.text = querySnapshot['name'];
      _priceController.text = querySnapshot['price'].toString();
      _descriptionController.text = querySnapshot['description'];
      base64Image = querySnapshot['image_base64'];
      selectedKitchens = querySnapshot['kitchens'] as List<String>;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();

      setState(() {
        _imageFile = File(pickedFile.path);
        base64Image = base64Encode(bytes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categoryId != null && widget.productId != null && base64Image == null) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('Cadastro de Produtos',
              style: TextStyle(color: Colors.white)),
          backgroundColor: corPadrao(),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            // Nome do produto
                            TextFormField(
                              controller: _nameController,
                              decoration: inputDec('Nome do Produto'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, digite o nome do produto';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),

                            // Dropdown de categorias
                            DropdownButtonFormField<String>(
                              value: selectedCategoryId,
                              decoration: inputDec('Categoria'),
                              items: categories.map((category) {
                                return DropdownMenuItem(
                                  value: category['id'],
                                  child: Text(category['name']!),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCategoryId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Por favor, selecione uma categoria';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),

                            // Outras informações (preço, descrição, cozinhas)
                            TextFormField(
                              controller: _descriptionController,
                              decoration:
                                  inputDec('Descrição do Produto (opcional)'),
                            ),
                            SizedBox(height: 20),

                            TextFormField(
                              controller: _priceController,
                              decoration: inputDec('Preço'),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, digite o preço';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _showKitchenSelectionDialog,
                                    style: ElevatedButton.styleFrom(
                                        //backgroundColor: Colors.green,
                                        minimumSize: Size(double.infinity, 45),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        )),
                                    child: Text('Selecionar Cozinhas',
                                        style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                Expanded(
                                  child: Wrap(
                                    children: selectedKitchens
                                        .map((kitchen) =>
                                            Chip(label: Text(kitchen)))
                                        .toList(),
                                  ),
                                )
                              ],
                            ),

                            SizedBox(height: 20),

                            ElevatedButton(
                              onPressed: _uploadImageAndSaveProduct,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  minimumSize: Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  )),
                              child: const Text(
                                'Cadastrar Produto',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botão para selecionar imagem
                      Expanded(
                          child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            margin: EdgeInsets.only(left: 10.0),
                            decoration: BoxDecoration(
                              //borda circular
                              color: Colors.grey[200],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            //height: 150,
                            child: _imageFile != null
                                ? Image.memory(
                                    base64Decode(base64Image!),
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Text(
                                    'Selecione uma imagem',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.grey[600]),
                                  )),
                          ),
                        ),
                      ))
                    ],
                  ),
                ),
              ));
  }
}

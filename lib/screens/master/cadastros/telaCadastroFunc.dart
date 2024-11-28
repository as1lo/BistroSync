import 'package:bistro/classes/user.dart';
import 'package:bistro/screens/widgets/cores.dart';
import 'package:bistro/screens/widgets/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class FuncionarioRegisterScreen extends StatefulWidget {
  final BistroUser bistroUser;

  FuncionarioRegisterScreen({super.key, required this.bistroUser});

  @override
  _FuncionarioRegisterScreenState createState() =>
      _FuncionarioRegisterScreenState();
}

class _FuncionarioRegisterScreenState extends State<FuncionarioRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final MaskedTextController _telefoneController =
      MaskedTextController(mask: '(00) 00000-0000');
  bool _isLoading = false;
  String? _selectedCozinha;
  List<String> _cozinhas = [];

  @override
  void initState() {
    super.initState();
    _fetchCozinhas();
  }

  Future<void> _fetchCozinhas() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.bistroUser.id)
          .collection('cozinha') // Nome da coleção no Firestore
          .get();

      setState(() {
        _cozinhas =
            querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar cozinhas: $e')),
      );
    }
  }

  Future<void> _registerFuncionario() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCozinha == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, selecione uma cozinha.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Criar usuário no Firebase Auth
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password:
              _emailController.text, // Substitua por uma senha gerada ou fixa
        );

        // Salvar no Firestore na subcoleção de funcionários
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.bistroUser.id)
            .collection('funcionarios')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text,
          'email': _emailController.text,
          'telefone': _telefoneController.text,
          'cozinha': _selectedCozinha,
          'email_master': widget.bistroUser.email,
          'status': true, // Ativado por padrão
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Funcionário cadastrado com sucesso!')),
        );

        // Limpar os campos
        _nameController.clear();
        _emailController.clear();
        _telefoneController.clear();
        setState(() {
          _selectedCozinha = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar funcionário: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      appBar: AppBar(
        title: Text('Cadastro de Funcionários',
            style: TextStyle(color: Colors.white)),
        backgroundColor: corPadrao(),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Nome
                    TextFormField(
                      controller: _nameController,
                      decoration: inputDec('Nome do Funcionário'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite o nome';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // E-mail
                    TextFormField(
                      controller: _emailController,
                      decoration: inputDec('E-mail'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite o e-mail';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Digite um e-mail válido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Telefone
                    TextFormField(
                      controller: _telefoneController,
                      decoration: inputDec('Telefone'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite o telefone';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Dropdown de Cozinha
                    DropdownButtonFormField<String>(
                      value: _selectedCozinha,
                      decoration: inputDec('Selecione a Cozinha'),
                      items: _cozinhas
                          .map((cozinha) => DropdownMenuItem(
                                value: cozinha,
                                child: Text(cozinha),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCozinha = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecione uma cozinha.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Botão para cadastrar
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: Size(double.minPositive, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          )),
                      onPressed: _registerFuncionario,
                      child: const Text(
                        'Cadastrar Funcionário',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

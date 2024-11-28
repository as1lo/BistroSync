import 'package:bistro/classes/user.dart';
import 'package:bistro/screens/widgets/cores.dart';
import 'package:bistro/screens/widgets/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class SedeRegisterScreen extends StatefulWidget {
  final BistroUser bistroUser;

  SedeRegisterScreen({super.key, required this.bistroUser});

  @override
  _SedeRegisterScreenState createState() => _SedeRegisterScreenState();
}

class _SedeRegisterScreenState extends State<SedeRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final MaskedTextController _telefoneController =
      MaskedTextController(mask: '(00) 00000-0000');
  bool _isLoading = false;

  Future<void> _registerSede() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _emailController.text,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.bistroUser.id)
            .collection('cozinha')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text,
          'email': _emailController.text,
          'telefone': _telefoneController.text,
          'email_master': widget.bistroUser.email,
          'status': true,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cozinha cadastrada com sucesso!')),
        );

        // Limpar os campos
        _nameController.clear();
        _emailController.clear();
        _telefoneController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar Cozinha: $e')),
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
        title:
            Text('Cadastro de Cozinhas', style: TextStyle(color: Colors.white)),
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
                      decoration: inputDec('Nome da Cozinha (Sede)'),
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

                    // Botão para cadastrar
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: Size(double.minPositive, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          )),
                      onPressed: _registerSede,
                      child: const Text('Cadastrar Cozinha',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

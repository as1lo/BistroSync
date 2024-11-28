import 'package:bistro/classes/user.dart';
import 'package:bistro/screens/widgets/cores.dart';
import 'package:bistro/screens/widgets/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegistraMesa extends StatefulWidget {
  final String? mesaId;
  final String idUser;
  final BistroUser user;

  RegistraMesa(
      {super.key, this.mesaId, required this.idUser, required this.user});

  @override
  _RegistraMesaState createState() => _RegistraMesaState();
}

class _RegistraMesaState extends State<RegistraMesa> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numController = TextEditingController();

  String? _selectedCozinhaId; // Cozinha selecionada no dropdown
  List<Map<String, dynamic>> _cozinhas = []; // Lista de cozinhas disponíveis

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMesaData();
    _loadCozinhas();
  }

  /// Carrega os dados da mesa para edição
  void _loadMesaData() async {
    if (widget.mesaId == null) return;

    setState(() {
      _isLoading = true;
    });

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.idUser)
        .collection('mesas')
        .doc(widget.mesaId)
        .get();

    if (doc.exists) {
      var data = doc.data()!;
      _nameController.text = data['name'];
      _emailController.text = data['email'];
      _numController.text = data['num'].toString();
      _selectedCozinhaId = data['cozinhaId']; // Cozinha vinculada
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Carrega a lista de cozinhas disponíveis
  void _loadCozinhas() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.idUser)
        .collection('cozinha')
        .get();

    setState(() {
      _cozinhas = querySnapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['name']})
          .toList();
    });
  }

  /// Salva ou atualiza os dados da mesa
  void _registerOrEditMesa() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final mesaData = {
        'name': _nameController.text,
        'email': _emailController.text,

        'email_master': widget.user.email,
        'num': int.parse(_numController.text),
        'cozinhaId': _selectedCozinhaId, // Cozinha vinculada
        'data_registro': DateTime.now(),
        'status': true
      };

      if (widget.mesaId == null) {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _emailController.text,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.idUser)
            .collection('mesas')
            .doc(userCredential.user!.uid)
            .set(mesaData);
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.idUser)
            .collection('mesas')
            .doc(widget.mesaId)
            .update(mesaData);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Mesa ${widget.mesaId == null ? 'registrada' : 'atualizada'} com sucesso!')));

      _nameController.clear();
      _emailController.clear();
      _numController.clear();
      //Navigator.of(context).pop();
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.mesaId == null ? 'Cadastrar Mesa' : 'Editar Mesa',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              )),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          backgroundColor: corPadrao(),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: inputDec('Nome da Mesa'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, digite o nome!';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            decoration: inputDec('Email'),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, digite o email!';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _numController,
                            decoration: inputDec('Número da Mesa'),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, digite o número!';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: _selectedCozinhaId,
                            decoration: inputDec('Cozinha'),
                            items: _cozinhas
                                .map((cozinha) => DropdownMenuItem<String>(
                                      value: cozinha['id'],
                                      child: Text(cozinha['name']),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCozinhaId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, selecione uma cozinha!';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),
                          _isLoading
                              ? CircularProgressIndicator(
                                  color: corPadrao(),
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      minimumSize: Size(double.minPositive, 45),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                  onPressed: _registerOrEditMesa,
                                  child: Text(
                                    'Confirmar',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                        ],
                      )),
                ),
              ));
  }
}

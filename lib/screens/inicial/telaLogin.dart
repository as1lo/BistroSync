import 'dart:async';

import 'package:bistro/classes/user.dart';
import 'package:bistro/screens/cozinha/pedidos.dart';
//import 'package:bistro/screens/inicial/telaLogin.dart';
import 'package:bistro/screens/master/home.dart';
import 'package:bistro/screens/mesa/menuMesa.dart';
import 'package:bistro/screens/salao/pedidosFunc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<Map<String, dynamic>?> _fetchMasterData(String masterEmail) async {
    var masterSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: masterEmail)
        .get();

    if (masterSnapshot.docs.isNotEmpty) {
      var doc = masterSnapshot.docs.first;

      // Inclui o ID no mapa de dados
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }
    return null;
  }

  Future<BistroUser?> _fetchUserData(String email) async {
    email = email.trim();
    try {
      var userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        var data = userSnapshot.docs.first.data();
        return BistroUser(
          id: userSnapshot.docs.first.id,
          email: data['email'],
          tipoUser: data['tipo_user'],
          name: data['name'],
          telefone: data['telefone'].toString(),
        );
      }

      var funcionarioSnapshot = await FirebaseFirestore.instance
          .collectionGroup('funcionarios')
          .where('email', isEqualTo: email)
          .get();

      if (funcionarioSnapshot.docs.isNotEmpty) {
        var data = funcionarioSnapshot.docs.first.data();
        return BistroUser(
          id: funcionarioSnapshot.docs.first.id,
          email: data['email'],
          tipoUser: 'salao',
          name: data['name'],
          telefone: data['telefone'].toString(),
          emailMaster: data['email_master'],
        );
      }

      var mesaSnapshot = await FirebaseFirestore.instance
          .collectionGroup('mesas')
          .where('email', isEqualTo: email)
          .get();

      if (mesaSnapshot.docs.isNotEmpty) {
        var data = mesaSnapshot.docs.first.data();

        var dataMaster = await _fetchMasterData(data['email_master']);

        print(dataMaster!.containsKey('primaryColor'));
        print(dataMaster['primaryColor']);

        return BistroUser(
          id: mesaSnapshot.docs.first.id,
          email: data['email'],
          tipoUser: 'mesa',
          name: data['name'],
          telefone: data['telefone'].toString(),
          emailMaster: data['email_master'],
          num: data['num'],
          idMaster: dataMaster['id'],
          primaryColor: dataMaster.containsKey('primaryColor')
              ? dataMaster['primaryColor']
              : null,
          secondaryColor: dataMaster.containsKey('tertiaryColor')
              ? dataMaster['tertiaryColor']
              : null,
          logobase64: dataMaster.containsKey('image_base64')
              ? dataMaster['image_base64']
              : null,
          senhaWifi: dataMaster.containsKey('senhaWiFi')
              ? dataMaster['senhaWiFi']
              : null,
          menuOptions: dataMaster.containsKey('options')
              ? (dataMaster['options'] as List)
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList()
              : [],
        );
      }

      var cozinhaSnapshot = await FirebaseFirestore.instance
          .collectionGroup('cozinha')
          .where('email', isEqualTo: email)
          .get();

      if (cozinhaSnapshot.docs.isNotEmpty) {
        var data = cozinhaSnapshot.docs.first.data();
        return BistroUser(
          id: cozinhaSnapshot.docs.first.id,
          email: data['email'],
          tipoUser: 'cozinha',
          name: data['name'],
          telefone: data['telefone'].toString(),
          emailMaster: data['email_master'],
        );
      }
    } catch (e) {
      print("Erro ao buscar dados do usuário: $e");
    }
    return null;
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      BistroUser? user = await _fetchUserData(_emailController.text);

      if (user != null) {
        if (user.tipoUser == 'master') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => Master(user: user)));
        } else if (user.tipoUser == 'cozinha') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => Cozinha(user: user)));
        } else if (user.tipoUser == 'salao') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => Salao(user: user)));
        } else if (user.tipoUser == 'mesa') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => Mesa(user: user)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tipo de usuário inválido.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário não encontrado.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no login: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/login_image.png',
              height: 150,
            ),
            SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: Text('Entrar'),
                  ),
          ],
        ),
      ),
    );
  }
}

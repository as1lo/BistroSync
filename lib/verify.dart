import 'package:bistro/classes/user.dart';
import 'package:bistro/screens/cozinha/pedidos.dart';
import 'package:bistro/screens/inicial/telaLogin.dart';
import 'package:bistro/screens/master/home.dart';
import 'package:bistro/screens/mesa/menuMesa.dart';
import 'package:bistro/screens/salao/pedidosFunc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyState extends StatefulWidget {
  @override
  State<VerifyState> createState() => _VerifyState();
}

class _VerifyState extends State<VerifyState> {
  BistroUser? _bistroUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _bistroUser = await _fetchUserData(user.email!);
    }
    setState(() {
      _isLoading = false;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bistroUser != null) {
      if (_bistroUser!.tipoUser == 'master') {
        return Master(user: _bistroUser!);
      } else if (_bistroUser!.tipoUser == 'cozinha') {
        return Cozinha(user: _bistroUser!);
      } else if (_bistroUser!.tipoUser == 'salao') {
        return Salao(user: _bistroUser!);
      } else if (_bistroUser!.tipoUser == 'mesa') {
        return Mesa(user: _bistroUser!);
      }
    }

    return LoginScreen();
  }
}

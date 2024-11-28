// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:bistro/charts/allCharts.dart';
import 'package:bistro/classes/user.dart';
import 'package:bistro/screens/widgets/cores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/screens/widgets/menuDrawer.dart';
import '../inicial/telaLogin.dart';

class Master extends StatefulWidget {

  final BistroUser user;
  const Master({ required this.user});

  @override
  State<Master> createState() => _MasterState();
}

class _MasterState extends State<Master> {
  String tipoUser = '';
  String idUser = '';

  void _tipoUser(String email) async {
    var user = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    setState(() {
      tipoUser = user.docs.first['tipo_user'];
      idUser = user.docs.first.id;

      print('USER NO HOME: ${user.docs.first['tipo_user']}');
    });
  }

  @override
  void initState() {
    //print('USER NO HOME: ${widget.tipoUser}');
    // TODO: implement initState
    super.initState();

    _tipoUser(widget.user.email);

    print('USER NO HOME: $tipoUser');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 38,
            )),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: corPadrao(),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: Icon(Icons.logout),
            onPressed: () async {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('Deseja realmente sair?'),
                        //content: Text('Deseja realmente sair?'),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancelar')),
                          TextButton(
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                Navigator.of(context).pop();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                );
                              },
                              child: Text('Confirmar')),
                        ],
                      ));
            },
          ),
        ],
      ),
      drawer: menuDrawer(context, widget.user.email, tipoUser, idUser, widget.user),
      body: AllCharts(widget.user.email, tipoUser, idUser),
    );
  }
}

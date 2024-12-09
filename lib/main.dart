import 'package:bistro/classes/carrinho.dart';
import 'package:bistro/classes/conta.dart';
import 'package:bistro/verify.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => CarrinhoProvider()),
      ChangeNotifierProvider(create: (_) => ContaProvider())
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VerifyState() ),
  ));
}

/*
Cozinha(
        user: BistroUser(
            email: 'cozinha@gmail.com',
            id: 'id',
            tipoUser: 'cozinha',
            name: 'cozinha',
            telefone: '939270332'),
      )
*/
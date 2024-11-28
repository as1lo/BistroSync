// ignore_for_file: prefer_const_constructors, file_names

import 'package:bistro/classes/user.dart';
import 'package:bistro/screens/master/cadastros/telaCadastroMesa.dart';
import 'package:bistro/screens/master/cadastros/telaCadastroSede.dart';
import 'package:bistro/screens/master/config.dart';
import 'package:bistro/screens/master/listas/telaCategoria.dart';
import 'package:bistro/screens/master/listas/telaSede.dart';
import 'package:bistro/screens/master/listas/telaFunc.dart';
import 'package:bistro/screens/master/listas/telaMesa.dart';
import 'package:bistro/screens/master/listas/telaVendas.dart';
import 'package:bistro/screens/recebimentos.dart';
import 'package:bistro/screens/widgets/cores.dart';
import 'package:flutter/material.dart';

import '../master/listas/telaProdutos.dart';

Widget menuDrawer(BuildContext context, String email, String tipoUser,
    String idUser, BistroUser user) {
  return Drawer(
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(40),
          width: double.infinity,
          height: 230,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientBtn(),
              begin: Alignment.topLeft,
              end: Alignment(1.0, 3.0),
            ),
          ),
          child: Center(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10),
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(
                              "https://static.vecteezy.com/system/resources/thumbnails/005/545/335/small/user-sign-icon-person-symbol-human-avatar-isolated-on-white-backogrund-vector.jpg"),
                          fit: BoxFit.cover)),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Minhas Listas",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Desenvolvido por BistroBot",
                  style: TextStyle(fontSize: 12, color: Colors.white),
                )
              ],
            ),
          ),
        ),
        Expanded(
            child: ListView(children: [
          /*
          ListTile(
            leading: Icon(
              Icons.new_label,
              color: corPadrao(),
            ),
            title: Text(
              "Novo Produto",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProductRegisterScreen(
                            bistroUser: user,
                          )));
            },
          ),
          */
          ListTile(
            leading: Icon(Icons.category, color: corPadrao()),
            title: Text(
              "Categorias",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CategoryListScreen(
                            bistroUser: user,
                            //tipoUser: tipoUser
                          )));
            },
          ),
          ListTile(
            leading: Icon(Icons.local_offer, color: corPadrao()),
            title: Text(
              "Produtos",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProductListScreen(
                            idUser: idUser,
                            email: email,
                            user: user,
                            //tipoUser: tipoUser
                          )));
            },
          ),
          /*
          ListTile(
            leading: Icon(Icons.person_add_alt_1_rounded, color: corPadrao()),
            title: Text(
              "Novo Funcionário",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FuncionarioRegisterScreen(
                            bistroUser: user,
                          )));
            },
          ),
          */
          ListTile(
            leading: Icon(Icons.people_alt_rounded, color: corPadrao()),
            title: Text(
              "Funcionários",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FuncListScreen(
                            email: email,
                            tipoUser: tipoUser,
                            idUser: idUser,
                            user: user,
                          )));
            },
          ),
          /*
          ListTile(
            leading: Icon(Icons.soup_kitchen_rounded, color: corPadrao()),
            title: Text(
              "Cadastrar Cozinha",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SedeRegisterScreen(bistroUser: user)));
            },
          ),*/
          ListTile(
            leading: Icon(Icons.soup_kitchen_rounded, color: corPadrao()),
            title: Text(
              "Cozinhas (Sedes)",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CozinhaListScreen(
                            user: user,
                            tipoUser: tipoUser,
                            idUser: idUser,
                          )));
            },
          ),
          /*
          ListTile(
            leading: Icon(Icons.table_bar, color: corPadrao()),
            title: Text(
              "Cadastrar Mesa",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegistraMesa(
                            user: user,
                            idUser: idUser,
                          )));
            },
          ),
          */
          ListTile(
            leading: Icon(Icons.table_bar, color: corPadrao()),
            title: Text(
              "Mesas",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MesaListScreen(
                            user: user,
                            idUser: idUser,
                          )));
            },
          ),
          ListTile(
            leading:
                Icon(Icons.shopping_cart_checkout_rounded, color: corPadrao()),
            title: Text(
              "Minhas Vendas",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VendasListScreen(
                          email: email, idUser: idUser, tipoUser: tipoUser)));
            },
          ),
          ListTile(
            leading: Icon(Icons.monetization_on, color: corPadrao()),
            title: Text(
              "Recebimentos",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          RecebimentosRelatorio(email, idUser)));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings, color: corPadrao()),
            title: Text(
              "Configurações",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Config(bistroUser: user)));
            },
          ),
        ]))
      ],
    ),
  );
}




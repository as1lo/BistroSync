import 'package:bistro/classes/user.dart';
import 'package:bistro/screens/inicial/telaLogin.dart';
import 'package:bistro/screens/salao/detalhesPedido.dart';
import 'package:bistro/screens/widgets/cores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Salao extends StatefulWidget {
  final BistroUser user;

  Salao({required this.user});

  @override
  _SalaoState createState() => _SalaoState();
}

class _SalaoState extends State<Salao> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos'),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Em andamento'),
            _buildPedidosStream('em_andamento', context),
            _buildSectionTitle('Concluído'),
            _buildPedidosStream('concluido', context),
            _buildSectionTitle('Cancelados'),
            _buildPedidosStream('cancelado', context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPedidosStream(String status, BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pedidos')
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        final pedidos = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: pedidos.length,
          itemBuilder: (context, index) {
            final pedidoData = pedidos[index].data() as Map<String, dynamic>;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PedidoDetalhesScreen(
                      pedidoId: pedidos[index].id,
                    ),
                  ),
                );
              },
              child: Card(
                child: ListTile(
                  leading: Image.network(
                    pedidoData['imagem'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text('Mesa ${pedidoData['mesa']}'),
                  subtitle: Text('Pedido: ${pedidoData['descricao']}'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:bistro/classes/user.dart';
import 'package:bistro/screens/inicial/telaLogin.dart';
import 'package:bistro/screens/widgets/cores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Cozinha extends StatefulWidget {
  final BistroUser user;

  Cozinha({required this.user});

  @override
  _CozinhaState createState() => _CozinhaState();
}

class _CozinhaState extends State<Cozinha> {
  @override

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), 
    );
  }
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos'),
        backgroundColor: corPadrao(),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
        ],
      ),
      body: Column(
        children: [
          // Carrossel de Pedidos Pendentes
          Text(
            'Pedidos Pendentes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pedidos')
                  .where('status', isEqualTo: 'pendente')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final pedidosPendentes = snapshot.data!.docs;
                return CarouselSlider(
                  options: CarouselOptions(
                    height: 150.0,
                    autoPlay: false,
                    enlargeCenterPage: true,
                  ),
                  items: pedidosPendentes.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return PedidoCard(
                      pedidoId: doc.id,
                      mesa: data['mesa'],
                      itens: List<String>.from(data['itens']),
                      status: 'pendente',
                      onStatusChange: () => _atualizarStatusPedido(doc.id, 'em_andamento'),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          // Carrossel de Pedidos Em Andamento
          Text(
            'Em Andamento',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pedidos')
                  .where('status', isEqualTo: 'em_andamento')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final pedidosEmAndamento = snapshot.data!.docs;
                return CarouselSlider(
                  options: CarouselOptions(
                    height: 150.0,
                    autoPlay: false,
                    enlargeCenterPage: true,
                  ),
                  items: pedidosEmAndamento.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return PedidoCard(
                      pedidoId: doc.id,
                      mesa: data['mesa'],
                      itens: List<String>.from(data['itens']),
                      status: 'em_andamento',
                      onStatusChange: () => _atualizarStatusPedido(doc.id, 'finalizado'),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _atualizarStatusPedido(String pedidoId, String novoStatus) async {
    await FirebaseFirestore.instance
        .collection('pedidos')
        .doc(pedidoId)
        .update({'status': novoStatus});
  }
}

class PedidoCard extends StatelessWidget {
  final String pedidoId;
  final String mesa;
  final List<String> itens;
  final String status;
  final VoidCallback onStatusChange;

  const PedidoCard({
    required this.pedidoId,
    required this.mesa,
    required this.itens,
    required this.status,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: status == 'pendente' ? Colors.orange : Colors.brown,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mesa $mesa',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            ...itens
                .map((item) => Text(
                      item,
                      style: TextStyle(color: Colors.green),
                    ))
                .toList(),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: onStatusChange,
              child: Text(
                status == 'pendente' ? 'Iniciar Preparação' : 'Finalizar Pedido',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: status == 'pendente' ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

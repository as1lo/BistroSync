import 'package:bistro/classes/user.dart';
import 'package:bistro/screens/inicial/telaLogin.dart';
import 'package:bistro/screens/widgets/cores.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Cozinha extends StatefulWidget {
  final BistroUser user;

  Cozinha({required this.user});

  @override
  _CozinhaState createState() => _CozinhaState();
}

class _CozinhaState extends State<Cozinha> {
  @override
  @override
  void initState() {
    super.initState();
    print('USER ID: ${widget.user.idMaster}');
  }

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
        title:  Text('Pedidos', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
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
                  .collection('users')
                  .doc(widget.user.idMaster)
                  .collection('pedidos')
                  .where('status', isEqualTo: 'pendente')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final pedidosPendentes = snapshot.data!.docs;
                return CarouselSlider(
                  options: CarouselOptions(
                    enableInfiniteScroll: false,
                    viewportFraction: 0.1,
                    height: 200.0,
                    autoPlay: false,
                    enlargeCenterPage: false,
                  ),
                  items: pedidosPendentes.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return PedidoCard(
                      pedidoId: doc.id,
                      mesa: data['numMesa'].toString(),
                      itens: List<String>.from(
                          data['itens'].map((item) => item['nome'])),
                      quant: List<String>.from(data['itens']
                          .map((item) => item['quantidade'].toString())),
                      status: 'pendente',
                      onStatusChange: () =>
                          _atualizarStatusPedido(doc.id, 'em andamento'),
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
                  .collection('users')
                  .doc(widget.user.idMaster)
                  .collection('pedidos')
                  .where('status', isEqualTo: 'em andamento')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final pedidosEmAndamento = snapshot.data!.docs;
                return CarouselSlider(
                  options: CarouselOptions(
                    enableInfiniteScroll: false,
                    viewportFraction: 0.1,
                    height: 200.0,
                    autoPlay: false,
                    enlargeCenterPage: false,
                  ),
                  items: pedidosEmAndamento.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return PedidoCard(
                      pedidoId: doc.id,
                      mesa: data['numMesa'].toString(),
                      itens: List<String>.from(
                          data['itens'].map((item) => item['nome'])),
                      quant: List<String>.from(data['itens']
                          .map((item) => item['quantidade'].toString())),
                      status: 'em andamento',
                      onStatusChange: () =>
                          _atualizarStatusPedido(doc.id, 'finalizado'),
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

  Future<void> _atualizarStatusPedido(
      String pedidoId, String novoStatus) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.idMaster)
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
  final List<String> quant;

  const PedidoCard({
    required this.pedidoId,
    required this.quant,
    required this.mesa,
    required this.itens,
    required this.status,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  'Mesa $mesa',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ...itens
                    .map((item) => Text(
                          item,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ))
                    .toList(),
              ],
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: onStatusChange,
              child: Text(
                status == 'pendente' ? 'Preparar' : 'Finalizar',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    status == 'pendente' ? Colors.amber : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

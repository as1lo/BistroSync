import 'package:bistro/classes/user.dart';
import 'package:bistro/screens/mesa/fecharConta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MeusPedidos extends StatefulWidget {
  final BistroUser user;

  MeusPedidos({required this.user});

  @override
  _MeusPedidosState createState() => _MeusPedidosState();
}

class _MeusPedidosState extends State<MeusPedidos> {
  
  Widget buildPedidoColumn(String statusFilter) {
    print(statusFilter);
    print(widget.user.idMaster);
    print(widget.user.idSessao);
    if (widget.user.idMaster == null ||
        widget.user.idSessao == null ||
        widget.user.id == null) {
      return Center(
          child: Text('Informações insuficientes para carregar pedidos.'));
    }
    try {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.idMaster)
            .collection('pedidos')
            .where('idMesa', isEqualTo: widget.user.id)
            .where('status', isEqualTo: statusFilter)
            .where('idSessao', isEqualTo: widget.user.idSessao)
            .orderBy('data', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          print('HAS DATA: ${snapshot.hasData}');
          //print(snapshot.data!.docs.isEmpty);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Erro ao carregar pedidos.'));
          }

          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum pedido $statusFilter.'));
          }

          final pedidos = snapshot.data!.docs;
          print(pedidos);
          return ListView.builder(
              itemCount: pedidos.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final pedido = pedidos[index].data() as Map<String, dynamic>;
                final idPedido = pedidos[index].id;
                DateTime dataPedido = pedido['data'].toDate();
                String horaPedido =
                    '${dataPedido.hour}:${dataPedido.minute}:${dataPedido.second}';
                return Card(
                  child: ListTile(
                    title: Text(
                      '#${widget.user.idSessao} ${widget.user.nomeSessao}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      children: [
                        Text('Hora do pedido: $horaPedido'),
                        Text(
                            'Total: R\$ ${pedido['total'].toStringAsFixed(2)}'),
                        Text('Status: $statusFilter'),
                        ExpansionTile(title: Text('Itens'), children: [
                          ListView.builder(
                              itemCount: pedido['itens'].length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final item = pedido['itens'][index];
                                return ListTile(
                                  title: Text(item['nome']),
                                  subtitle: Text(
                                      'Quantidade: ${item['quantidade']}\nPreco: R\$ ${item['preco'].toStringAsFixed(2)}'),
                                );
                              }),
                        ])
                      ],
                    ),
                    trailing: statusFilter == 'pendente'
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            onPressed: () async {
                              await cancelarPedido(
                                  widget.user.idMaster!, idPedido);
                            },
                            child: Text('Cancelar Pedido'),
                          )
                        : null,
                  ),
                );
              });
        },
      );
    } catch (e) {
      print(e);
      return Center(child: Text('Erro ao carregar pedidos: $e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Meus Pedidos'),
          actions: [
            ElevatedButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FecharConta(
                        user: widget.user,
                      ),
                    )),
                label: Text('Fechar Conta'),
                icon: FaIcon(FontAwesomeIcons.cashRegister))
          ],
        ),
        body: Row(
          children: [
            Expanded(child: buildPedidoColumn('pendente')),
            Expanded(child: buildPedidoColumn('em andamento')),
            Expanded(child: buildPedidoColumn('finalizado')),
          ],
        ));
  }

  Future<void> cancelarPedido(String userId, String pedidoId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('pedidos')
          .doc(pedidoId)
          .update({'status': 'cancelado'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido cancelado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cancelar pedido: $e')),
      );
    }
  }
}

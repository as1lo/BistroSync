import 'package:bistro/classes/conta.dart';
import 'package:bistro/classes/user.dart';
import 'package:bistro/inutilizados/exibirLink.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class FecharConta extends StatefulWidget {
  final BistroUser user;

  FecharConta({required this.user});

  @override
  _FecharContaState createState() => _FecharContaState();
}

class _FecharContaState extends State<FecharConta> {
  String? formaDePagamento;
  List itensConta = [];
  List detalhesConta = [];
  bool _taxa = false;
  double _notaAvaliacao = 3.0;

  Future<void> finalizarConta(total, subtotal) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.id)
        .collection('contas')
        .add({
      'itens': itensConta,
      'total': total,
      'subtotal': subtotal,
      'formaDePagamento': formaDePagamento,
      'taxa': _taxa,
      'notaAvaliacao': _notaAvaliacao,
      'data': DateTime.now(),
      'email_user': widget.user.email
    });
  }

  void _showRatingModal(BuildContext context, Size size) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
            top: 16.0,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min, // Adapta o tamanho ao conteúdo
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Avalie o nosso restaurante!',
                    style: TextStyle(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  RatingBar.builder(
                    initialRating: _notaAvaliacao,
                    itemSize: size.width * 0.09,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.02),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setModalState(() {
                        _notaAvaliacao = rating;
                      });
                    },
                  ),
                  SizedBox(height: size.height * 0.02),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Fecha o modal
                    },
                    child: Text('Enviar Avaliação'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final contaProvider = Provider.of<ContaProvider>(context);
    Size size = MediaQuery.of(context).size;

    detalhesConta = contaProvider.pedidos;
    itensConta = detalhesConta
        .map((pedido) => pedido['itens'] as List)
        .expand((itens) => itens)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Conta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Coluna com os itens da conta
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile<bool>(
                    title: const Text('Tax. de Serviço (10%)'),
                    value: _taxa,
                    groupValue: _taxa,
                    onChanged: (value) {
                      setState(() {
                        _taxa = !value!;
                      });
                    },
                  ),
                  Text(
                    'Subtotal: R\$ ${contaProvider.totalConta.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total: R\$ ${_taxa ? (contaProvider.totalConta * 0.1 + contaProvider.totalConta).toStringAsFixed(2) : contaProvider.totalConta.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ExpansionTile(title: Text('Itens'), children: [
                    ListView.builder(
                        itemCount: itensConta.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final item =
                              itensConta[index] as Map<String, dynamic>;

                          print('item: $itensConta');
                          print('item: $item');

                          return ListTile(
                            title: Text(item['nome'].toString()),
                            subtitle: Text(
                                'Quantidade: ${item['quantidade'].toString()}\nPreco: R\$ ${item['preco']}'),
                          );
                        }),
                  ]),
                  /*Expanded(
                    
                    child: ListView.builder(
                      itemCount: widget.user.itens.length,
                      itemBuilder: (context, index) {
                        final item = widget.user.itens[index];
                        return ListTile(
                          title: Text(item['nome']),
                          trailing: Text('R\$ ${item['preco'].toStringAsFixed(2)}'),
                        );
                      },
                    ),
                    
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Subtotal'),
                    trailing: Text('R\$ ${widget.user.subtotal.toStringAsFixed(2)}'),
                  ),
                  ListTile(
                    title: Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      'R\$ ${widget.user.total.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  */
                ],
              ),
            ),

            // Coluna com as formas de pagamento
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Formas de Pagamento',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  RadioListTile<String>(
                    title: Text('Cartão'),
                    value: 'cartao',
                    groupValue: formaDePagamento,
                    onChanged: (value) {
                      setState(() {
                        formaDePagamento = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Pix'),
                    value: 'pix',
                    groupValue: formaDePagamento,
                    onChanged: (value) {
                      setState(() {
                        formaDePagamento = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Dinheiro'),
                    value: 'dinheiro',
                    groupValue: formaDePagamento,
                    onChanged: (value) {
                      setState(() {
                        formaDePagamento = value;
                      });
                    },
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: formaDePagamento == null
                        ? null
                        : () async {
                            // Lógica ao finalizar o pagamento
                            _showRatingModal(context, size);

                            if (formaDePagamento == 'cartao' ||
                                formaDePagamento == 'dinheiro') {
                              await finalizarConta(
                                  contaProvider.totalConta,
                                  contaProvider.totalConta * 0.1 +
                                      contaProvider.totalConta);
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            } else {
                              await finalizarConta(
                                  contaProvider.totalConta,
                                  contaProvider.totalConta * 0.1 +
                                      contaProvider.totalConta);
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              widget.user.idSessao = '';
                              widget.user.idSessao = '';
                            }
                          },
                    child: Text('Finalizar Pagamento'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

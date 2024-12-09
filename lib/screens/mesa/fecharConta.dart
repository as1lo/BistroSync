import 'package:bistro/classes/user.dart';
import 'package:flutter/material.dart';

class FecharConta extends StatefulWidget {
  final BistroUser user;

  FecharConta({required this.user});

  @override
  _FecharContaState createState() => _FecharContaState();
}

class _FecharContaState extends State<FecharConta> {
  String? formaDePagamento; // Variável para armazenar a forma de pagamento selecionada

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fechar Conta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Coluna com os itens, subtotal e total
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Itens da Conta',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
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
                        : () {
                            // Lógica ao finalizar o pagamento
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Forma de pagamento selecionada: $formaDePagamento'),
                              ),
                            );
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

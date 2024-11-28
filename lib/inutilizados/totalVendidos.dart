import 'package:bistro/screens/widgets/cores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TotalVendidos extends StatefulWidget {
  final String email;
  final String tipoUser;
  final String? emailFiliado;
  const TotalVendidos(this.email, this.tipoUser, this.emailFiliado);

  @override
  State<StatefulWidget> createState() => TotalVendidosState();
}

class TotalVendidosState extends State<TotalVendidos> {
  Stream<QuerySnapshot> _getVendasStream() {
    if (widget.tipoUser == 'master') {
      if (widget.emailFiliado == null) {
        return FirebaseFirestore.instance.collection('vendas').snapshots();
      } else {
        return FirebaseFirestore.instance
            .collection('vendas')
            .where('email_user', isEqualTo: widget.emailFiliado)
            .snapshots();
      }
    } else {
      return FirebaseFirestore.instance
          .collection('vendas')
          .where('email_user', isEqualTo: widget.email)
          .snapshots();
    }
  }

  Stream<QuerySnapshot> _getProdutosStream() {
    if (widget.tipoUser == 'master') {
      if (widget.emailFiliado == null) {
        return FirebaseFirestore.instance.collection('products').snapshots();
      } else {
        return FirebaseFirestore.instance
            .collection('products')
            .where('email_user', isEqualTo: widget.emailFiliado)
            .snapshots();
      }
    } else {
      return FirebaseFirestore.instance
          .collection('products')
          .where('email_user', isEqualTo: widget.email)
          .snapshots();
    }
  }

  Stream<QuerySnapshot> _getItensVendasStream() {
    if (widget.tipoUser == 'master') {
      if (widget.emailFiliado == null) {
        return FirebaseFirestore.instance
            .collection('itens_vendas')
            .snapshots();
      } else {
        return FirebaseFirestore.instance
            .collection('itens_vendas')
            .where('email_user', isEqualTo: widget.emailFiliado)
            .snapshots();
      }
    } else {
      return FirebaseFirestore.instance
          .collection('itens_vendas')
          .where('email_user', isEqualTo: widget.email)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getVendasStream(),
      builder: (context, vendasSnapshot) {
        if (vendasSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (vendasSnapshot.hasError) {
          return Text('Erro ao carregar dados de vendas.');
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _getProdutosStream(),
          builder: (context, produtosSnapshot) {
            if (produtosSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (produtosSnapshot.hasError) {
              return Text('Erro ao carregar dados de produtos.');
            }

            return StreamBuilder<QuerySnapshot>(
              stream: _getItensVendasStream(),
              builder: (context, itensVendasSnapshot) {
                if (itensVendasSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (itensVendasSnapshot.hasError) {
                  return Text('Erro ao carregar dados de itens de vendas.');
                }

                int cont = 0;

                for (var docvenda in vendasSnapshot.data!.docs) {
                  for (var docprod in produtosSnapshot.data!.docs) {
                    for (var dociven in itensVendasSnapshot.data!.docs) {
                      if (dociven['idproduto'] == docprod.id &&
                          docvenda.id == dociven['idvenda']) {
                        cont += int.parse(dociven['quantidade'].toString());
                      }
                    }
                  }
                }

                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: gradientBtn(),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$cont',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Produtos',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Total Vendidos'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

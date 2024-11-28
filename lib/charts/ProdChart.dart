import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '/presentation/resources/app_resources.dart';
import '/presentation/widgets/indicator.dart';

class Prodchart extends StatefulWidget {
  final String email;
  final String tipoUser;
  final String idUser;
  final String? emailFiliado;
  final String? idFiliado;

  const Prodchart(this.email, this.tipoUser, this.idUser, this.emailFiliado,
      this.idFiliado);

  @override
  State<StatefulWidget> createState() => PieChartProdState();
}

class PieChartProdState extends State<Prodchart> {
  int touchedIndex = -1;
  int _quantidadeTotal = 0;
  List<DadosProduto> _listProdutosEscolhidos = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DadosProduto>>(
      future: getDataProductsPie(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        _listProdutosEscolhidos = snapshot.data!;
        _quantidadeTotal = _listProdutosEscolhidos.fold(
            0, (sum, item) => sum + (item.quantidade ?? 0));

        return showPieProdutosVendidos();
      },
    );
  }

  Widget showPieProdutosVendidos() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Quantidade Total de produtos mais vendidos',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Container(
            //color: Colors.amber,
            height: 200,
            width: 430,
            child: Row(
              children: <Widget>[
                const SizedBox(height: 18),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: showingSections(),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Indicator(
                      color: AppColors.contentColorBlue,
                      text: _listProdutosEscolhidos.isNotEmpty
                          ? _listProdutosEscolhidos[0].nome ?? ''
                          : '',
                      isSquare: true,
                    ),
                    const SizedBox(height: 4),
                    _listProdutosEscolhidos.length > 1
                        ? Indicator(
                            color: AppColors.contentColorYellow,
                            text: _listProdutosEscolhidos[1].nome ?? '',
                            isSquare: true,
                          )
                        : const SizedBox(),
                    const SizedBox(height: 4),
                    _listProdutosEscolhidos.length > 2
                        ? Indicator(
                            color: AppColors.contentColorPurple,
                            text: _listProdutosEscolhidos[2].nome ?? '',
                            isSquare: true,
                          )
                        : const SizedBox(),
                    const SizedBox(height: 4),
                    _listProdutosEscolhidos.length > 3
                        ? Indicator(
                            color: AppColors.contentColorGreen,
                            text: _listProdutosEscolhidos[3].nome ?? '',
                            isSquare: true,
                          )
                        : const SizedBox(),
                    const SizedBox(height: 18),
                  ],
                ),
                const SizedBox(width: 28),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<List<DadosProduto>> getDataProductsPie() async {
    Map<String, DadosProduto> produtosEscolhidosMap = {};
    _quantidadeTotal = 0;

    var vendas = widget.tipoUser == 'master'
        ? (widget.idFiliado == null
            ? await FirebaseFirestore.instance.collection('vendas').get()
            : await FirebaseFirestore.instance
                .collection('vendas')
                .where('id_user', isEqualTo: widget.idFiliado)
                .get())
        : await FirebaseFirestore.instance
            .collection('vendas')
            .where('id_user', isEqualTo: widget.idUser)
            .get();

    /*
    var itensVendas = widget.tipoUser == 'master'
        ? (widget.emailFiliado == null
            ? await FirebaseFirestore.instance.collection('itens_vendas').get()
            : await FirebaseFirestore.instance
                .collection('itens_vendas')
                .where('email_user', isEqualTo: widget.emailFiliado)
                .get())
        : await FirebaseFirestore.instance
            .collection('itens_vendas')
            .where('email_user', isEqualTo: widget.email)
            .get();
    */

    var produtos = widget.tipoUser == 'master'
        ? (widget.emailFiliado == null
            ? await FirebaseFirestore.instance.collection('products').get()
            : await FirebaseFirestore.instance
                .collection('products')
                .where('email_user', isEqualTo: widget.emailFiliado)
                .get())
        : await FirebaseFirestore.instance
            .collection('products')
            .where('email_user', isEqualTo: widget.email)
            .get();

    // Processamento das vendas, produtos
    for (var docvenda in vendas.docs) {
      for (var docprod in produtos.docs) {
        int quantidade = 0;

        if (docvenda['plan_id'] == docprod['plan_id']) {
          quantidade++;
        }

        if (quantidade > 0) {
          _quantidadeTotal += quantidade;
          if (produtosEscolhidosMap.containsKey(docprod.id)) {
            produtosEscolhidosMap[docprod.id]!.quantidade =
                (produtosEscolhidosMap[docprod.id]!.quantidade ?? 0) +
                    quantidade;
          } else {
            produtosEscolhidosMap[docprod.id] = DadosProduto(
              nome: docprod['name'],
              quantidade: quantidade,
              id: docprod.id,
            );
          }
        }
      }
    }

    return produtosEscolhidosMap.values.toList();
  }

  List<PieChartSectionData> showingSections() {
    if (_listProdutosEscolhidos.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 100,
          title: 'No Data',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ];
    }

    return List.generate(
      _listProdutosEscolhidos.length > 4 ? 4 : _listProdutosEscolhidos.length,
      (i) {
        final isTouched = i == touchedIndex;
        final fontSize = isTouched ? 25.0 : 16.0;
        final radius = isTouched ? 60.0 : 50.0;
        const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

        return PieChartSectionData(
          color: _getColor(i),
          value: ((_listProdutosEscolhidos[i].quantidade ?? 0) * 100) /
              _quantidadeTotal,
          title: _listProdutosEscolhidos[i].quantidade.toString(),
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.mainTextColor1,
            shadows: shadows,
          ),
        );
      },
    );
  }

  Color _getColor(int index) {
    switch (index) {
      case 0:
        return AppColors.contentColorBlue;
      case 1:
        return AppColors.contentColorYellow;
      case 2:
        return AppColors.contentColorPurple;
      case 3:
        return AppColors.contentColorGreen;
      default:
        return Colors.grey;
    }
  }
}

class DadosProduto {
  String? nome;
  int? quantidade;
  String? id;

  DadosProduto({this.nome, this.quantidade, this.id});
}

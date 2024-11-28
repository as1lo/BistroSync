import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '/presentation/resources/app_resources.dart';
import '/presentation/widgets/indicator.dart';

class LineChartSample1 extends StatefulWidget {
  final String email;
  final String tipoUser;
  final String idUser;
  final String? emailFiliado;
  final String? idFiliado;
  const LineChartSample1(this.email, this.tipoUser, this.idUser, this.emailFiliado, this.idFiliado);

  @override
  State<StatefulWidget> createState() => LineChartSample1State();
}

class LineChartSample1State extends State<LineChartSample1> {
  List<List<FlSpot>> _listAllData = [[], [], []];

  @override
  void initState() {
    super.initState();

    try {
      getDataVendas();
    } catch (e) {
      print(e);
    }

    try {
      getDataClientes();
    } catch (e) {
      print(e);
    }

    //getDataProducts();
  }

  //0 - vendasEfetuadas
  void getDataVendas() {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth =
        DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));

    List<FlSpot> vendasEfetuadas = List.generate(
        lastDayOfMonth.day, (index) => FlSpot((index + 1).toDouble(), 0));

    print('VENDAS EFETUADAS ANTES DO LISTEN: $vendasEfetuadas ');

    var query = widget.tipoUser == 'master'
        ? (widget.idFiliado == null
            ? FirebaseFirestore.instance.collection('vendas').where('data',
                isGreaterThanOrEqualTo: firstDayOfMonth,
                isLessThanOrEqualTo: lastDayOfMonth)
            : FirebaseFirestore.instance
                .collection('vendas')
                .where('data',
                    isGreaterThanOrEqualTo: firstDayOfMonth,
                    isLessThanOrEqualTo: lastDayOfMonth)
                .where('id_user', isEqualTo: widget.idFiliado))
        : FirebaseFirestore.instance
            .collection('vendas')
            .where('data',
                isGreaterThanOrEqualTo: firstDayOfMonth,
                isLessThanOrEqualTo: lastDayOfMonth)
            .where('id_user', isEqualTo: widget.idUser);

    query.snapshots().listen((vendasSnapshot) async {
      print('INICIO DO LISTEN');

      // VENDAS EFETUADAS
      for (var docvenda in vendasSnapshot.docs) {
        if (docvenda.data().containsKey('data')) {
          DateTime dataVenda = (docvenda['data'] as Timestamp).toDate();
          int dia = dataVenda.day;
          print(dia);
          vendasEfetuadas[dia - 1] =
              FlSpot(dia.toDouble(), vendasEfetuadas[dia - 1].y + 1);
        }
      }

      print('VENDAS EFETUADAS DEPOIS DO LISTEN: $vendasEfetuadas ');
      try {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _listAllData[0] = vendasEfetuadas;
          print('VENDAS EFETUADAS NO SET STATE: ${_listAllData[0]}');
        });
      } catch (e) {
        print(e);
      }
    }, onError: (error) {
      print('VENDAS EFETUADAS ERRO: $error');
    });
  }

  /*
  //1 - produtosVendidos
  void getDataProducts() {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth =
        DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));

    FirebaseFirestore.instance
        .collection('itens_vendas')
        .snapshots()
        .listen((itensVendasSnapshot) async {
      var vendasSnapshot = widget.tipoUser == 'master'
          ? (widget.emailFiliado == null
              ? await FirebaseFirestore.instance
                  .collection('vendas')
                  .where('data',
                      isGreaterThanOrEqualTo: firstDayOfMonth,
                      isLessThanOrEqualTo: lastDayOfMonth)
                  .get()
              : await FirebaseFirestore.instance
                  .collection('vendas')
                  .where('email_user', isEqualTo: widget.emailFiliado)
                  .where('data',
                      isGreaterThanOrEqualTo: firstDayOfMonth,
                      isLessThanOrEqualTo: lastDayOfMonth)
                  .get())
          : await FirebaseFirestore.instance
              .collection('vendas')
              .where('email_user', isEqualTo: widget.email)
              .where('data',
                  isGreaterThanOrEqualTo: firstDayOfMonth,
                  isLessThanOrEqualTo: lastDayOfMonth)
              .get();

      var produtosSnapshot = widget.tipoUser == 'master'
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

      List<FlSpot> produtosVendidos = List.generate(
          lastDayOfMonth.day, (index) => FlSpot((index + 1).toDouble(), 0));

      // PRODUTOS VENDIDOS
      for (var docvenda in vendasSnapshot.docs) {
        for (var docprod in produtosSnapshot.docs) {
          for (var dociven in itensVendasSnapshot.docs) {
            if (dociven['idproduto'] == docprod.id &&
                docvenda.id == dociven['idvenda']) {
              DateTime dataVenda = (docvenda['data'] as Timestamp).toDate();
              int dia = dataVenda.day;
              produtosVendidos[dia - 1] = FlSpot(
                  dia.toDouble(),
                  produtosVendidos[dia - 1].y +
                      int.parse(dociven['quantidade'].toString()));
            }
          }
        }
      }

      setState(() {
        _listAllData[1] = produtosVendidos;
      });
    });
  }
  */

  //2 - clientesRegistrados
  void getDataClientes() {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    var query = widget.tipoUser == 'master'
        ? (widget.emailFiliado == null
            ? FirebaseFirestore.instance.collection('clientes').where(
                'data_registro',
                isGreaterThanOrEqualTo: firstDayOfMonth,
                isLessThanOrEqualTo: lastDayOfMonth)
            : FirebaseFirestore.instance
                .collection('clientes')
                .where('data_registro',
                    isGreaterThanOrEqualTo: firstDayOfMonth,
                    isLessThanOrEqualTo: lastDayOfMonth)
                .where('id_user', isEqualTo: widget.idFiliado))
        : FirebaseFirestore.instance
            .collection('clientes')
            .where('data_registro',
                isGreaterThanOrEqualTo: firstDayOfMonth,
                isLessThanOrEqualTo: lastDayOfMonth)
            .where('id_user', isEqualTo: widget.idUser);

    query.snapshots().listen((clientesSnapshot) {
      List<FlSpot> clientesRegistrados = List.generate(
          lastDayOfMonth.day, (index) => FlSpot((index + 1).toDouble(), 0));

      // CLIENTES REGISTRADOS
      for (var doccliente in clientesSnapshot.docs) {
        if (doccliente.data().containsKey('data_registro')) {
          DateTime dataRegistro =
              (doccliente['data_registro'] as Timestamp).toDate();
          int dia = dataRegistro.day;
          clientesRegistrados[dia - 1] =
              FlSpot(dia.toDouble(), clientesRegistrados[dia - 1].y + 1);
        }
      }

      setState(() {
        _listAllData[2] = clientesRegistrados;
        print('CLIENTES REGISTRADOS SET STATE: ${_listAllData[2]}');
      });
    }, onError: (error) {
      print('CLIENTES REGISTRADOS ERRO: $error');
    });
  }


  Widget showLineChart(Size size) {
    DateTime now = DateTime.now();
    DateTime data = DateTime(now.year, now.month + 1, 0);

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
      //color: Color.fromRGBO(232, 222, 243, 1),
      height: 500,
      width: 900,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              Text(
                'Quantidade por Dia (${data.month}/${data.year})',
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 10, 12),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              size.width <= 720
                  ? const Column(
                      children: [
                        Indicator(
                          color: AppColors.contentColorGreen,
                          text: 'Vendas Efetuadas',
                          isSquare: true,
                        ),
                        SizedBox(
                          width: 24,
                        ),
                        Indicator(
                          color: AppColors.contentColorPink,
                          text: 'Produtos Vendidos',
                          isSquare: true,
                        ),
                        SizedBox(
                          width: 24,
                        ),
                        Indicator(
                          color: AppColors.contentColorCyan,
                          text: 'Clientes Registrados',
                          isSquare: true,
                        ),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Indicator(
                          color: AppColors.contentColorGreen,
                          text: 'Vendas Efetuadas',
                          isSquare: true,
                        ),
                        SizedBox(
                          width: 24,
                        ),
                        Indicator(
                          color: AppColors.contentColorPink,
                          text: 'Produtos Vendidos',
                          isSquare: true,
                        ),
                        SizedBox(
                          width: 24,
                        ),
                        Indicator(
                          color: AppColors.contentColorCyan,
                          text: 'Clientes Registrados',
                          isSquare: true,
                        ),
                      ],
                    ),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 6),
                  child: LineChart(
                    sampleData1,
                    duration: const Duration(milliseconds: 250),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(LineChartSample1 oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Se o emailFiliado mudar, buscar os dados novamente
    if (oldWidget.emailFiliado != widget.emailFiliado) {
      _listAllData = [[], [], []]; // Limpa os dados antigos
      getDataVendas();
      //getDataProducts();
      getDataClientes();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return _listAllData.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : showLineChart(size);
  }

  double getMaxValueFromList(List<FlSpot> spots) {
    if (spots.isEmpty) return 0;
    return spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
  }

  double getMaxValue() {
    double maxVendasEfetuadas = getMaxValueFromList(_listAllData[0]);
    double maxProdutosVendidos = getMaxValueFromList(_listAllData[1]);
    double maxClientesRegistrados = getMaxValueFromList(_listAllData[2]);

    return [maxVendasEfetuadas, maxProdutosVendidos, maxClientesRegistrados]
        .reduce((a, b) => a > b ? a : b);
  }

  // WIDGET PARA RENDERIZAR TODAS AS CONFIGURAÇÕES DO CHART
  LineChartData get sampleData1 => LineChartData(
        lineTouchData: lineTouchData1,
        gridData: gridData,
        titlesData: titlesData1,
        borderData: borderData,
        lineBarsData: lineBarsData1,
        minX: 0,
        maxX: 31, // tamanho máximo do mês atual
        // maior valor de todos os dados exibidos até o momento
        minY: 0,
      );

  // COMPORTAMENTO DE QUANDO A LINHA FOR TOCADA
  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.8),
        ),
      );

  // RECEBENDO TODOS OS TÍTULOS DOS LADOS
  FlTitlesData get titlesData1 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  // LISTA DE TODOS OS 3 (TRÊS) CONJUNTOS DE DADOS
  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        lineChartBarData1_2,
        lineChartBarData1_3,
      ];

  // DADOS DO TÍTULO DA ESQUERDA
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String? text;

    text = '${value.toInt()}';

    if (getMaxValue() <= 10) {
      //se par
      if (getMaxValue() % 2 == 0) {
        return value % 5 != 0
            ? Text(text.toString(), style: style, textAlign: TextAlign.center)
            : const Text('');
      }

      //se impar
      return value % 5 == 0
          ? Text(text.toString(), style: style, textAlign: TextAlign.center)
          : const Text('');
    } else if (getMaxValue() <= 50) {
      //se par
      if (getMaxValue() % 2 == 0) {
        return value % 10 == 0
            ? Text(text.toString(), style: style, textAlign: TextAlign.center)
            : const Text('');
      }

      //se impar
      return value % 10 != 0
          ? Text(text.toString(), style: style, textAlign: TextAlign.center)
          : const Text('');
    } else if (getMaxValue() <= 200) {
      //se par
      if (getMaxValue() % 2 == 0) {
        return value % 50 == 0
            ? Text(text.toString(), style: style, textAlign: TextAlign.center)
            : const Text('');
      }

      //se impar
      return value % 50 != 0
          ? Text(text.toString(), style: style, textAlign: TextAlign.center)
          : const Text('');
    } else if (getMaxValue() > 200) {
      //se par
      if (getMaxValue() % 2 == 0) {
        return value % getMaxValue() == 0 || value == getMaxValue() / 2
            ? Text(text.toString(), style: style, textAlign: TextAlign.center)
            : const Text('');
      }

      //se impar
      return value % getMaxValue() == 0 || value == (getMaxValue() / 2).toInt()
          ? Text(text.toString(), style: style, textAlign: TextAlign.center)
          : const Text('');
    }
    return Text(text.toString(), style: style, textAlign: TextAlign.center);
  }

  // CONFIGURAÇÃO DOS TAMANHOS DO TÍTULO DO LADO ESQUERDO
  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 1,
        reservedSize: 40,
      );

  // DADOS DO TÍTULO DE BAIXO
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    dynamic text;
    int lastDayOfMonth =
        DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;

    if (value.toInt() != 0) {
      if ((value.toInt() % 5 == 0 || value.toInt() == 1) &&
          value.toInt() != 30 &&
          value.toInt() != 31) {
        return Text(
          '${value.toInt()}',
          style: style,
        );
      } else if (value.toInt() == lastDayOfMonth) {
        return Text(
          '$lastDayOfMonth',
          style: style,
        );
      } else {
        return const Text('');
      }
    } else {
      return const Text('');
    }
  }

  // CONFIGURAÇÃO TÍTULO DE BAIXO
  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  // GRID DO GRÁFICO
  FlGridData get gridData => const FlGridData(show: false);

  // COR DA BORDA
  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom:
              BorderSide(color: AppColors.primary.withOpacity(0.2), width: 4),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );

  // quantidade de vendas efetuadas no mês
  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: false,
        color: AppColors.contentColorGreen,
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
        spots: _listAllData.isNotEmpty ? _listAllData[0] : [],
      );

  // quantidade de produtos vendidos no mês
  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
        isCurved: false,
        color: AppColors.contentColorPink,
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(
          show: false,
          color: AppColors.contentColorPink.withOpacity(0),
        ),
        spots: _listAllData.isNotEmpty ? _listAllData[1] : [],
      );

  // quantidade de clientes registrados no mês
  LineChartBarData get lineChartBarData1_3 => LineChartBarData(
        isCurved: false,
        color: AppColors.contentColorCyan,
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
        spots: _listAllData.isNotEmpty ? _listAllData[2] : [],
      );
}

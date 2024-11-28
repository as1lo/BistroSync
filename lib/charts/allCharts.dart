import 'package:bistro/screens/widgets/cores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../totalizadores/totalClientes.dart';
import '../totalizadores/totalProdutos.dart';
import '../totalizadores/totalVendas.dart';
//import '../inutilizados/totalVendidos.dart';
import 'ProdChart.dart';
import 'ProdVendChart.dart';
import 'lineChart.dart';

class AllCharts extends StatefulWidget {
  final String email;
  final String tipoUser;
  final String idUser;
  AllCharts(this.email, this.tipoUser, this.idUser);

  @override
  State<StatefulWidget> createState() => AllChartsState();
}

class AllChartsState extends State<AllCharts> {
  int touchedIndex = -1;
  String? _dadosFiliado;
  String? _filiadoEmail;
  String? _filiadoId;
  List<String> _listFiliadoDrop = [];

  // Função para buscar os dados dos filiados
  Future<void> _fetchFiliadoData() async {
    List<String> filiados = await _setListFiliado();
    setState(() {
      _listFiliadoDrop = filiados;
    });
  }

  // Função para obter a lista de filiados
  Future<List<String>> _setListFiliado() async {
    var filiados = await FirebaseFirestore.instance
        .collection('users')
        .where('tipo_user', isEqualTo: 'filiado')
        .get();

    return filiados.docs.map((doc) {
      return '${doc['name']} | ${doc['email']}';
    }).toList();
  }

  Future<String?> fetchAndSetFiliadoEmail(String? filiSelecionado) async {
    String? filiadoEmail;
    var filiados = await FirebaseFirestore.instance
        .collection('users')
        .where('tipo_user', isEqualTo: 'filiado')
        .get();

    for (var filiado in filiados.docs) {
      if (filiSelecionado == '${filiado['name']} | ${filiado['email']}') {
        filiadoEmail = filiado['email'];

        break;
      }
    }
    return filiadoEmail;
  }

  Future<String?> fetchAndSetFiliadoId(String? filiSelecionado) async {
    String? filiadoId;

    var filiados = await FirebaseFirestore.instance
        .collection('users')
        .where('tipo_user', isEqualTo: 'filiado')
        .get();

    for (var filiado in filiados.docs) {
      if (filiSelecionado == '${filiado['name']} | ${filiado['email']}') {
        filiadoId = filiado.id;

        break;
      }
    }
    return filiadoId;
  }

  @override
  void initState() {
    super.initState();
    _fetchFiliadoData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      //color: Colors.amber,
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(
        left: size.width * 0.07,
        right: size.width * 0.07,
      ),
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: size.height * 0.02,
              ),
              widget.tipoUser == 'master'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: DropdownSearch<String>(
                            popupProps: const PopupProps.menu(
                              showSelectedItems: true,
                              showSearchBox: true,
                            ),
                            items: _listFiliadoDrop,
                            dropdownDecoratorProps:
                                const DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText:
                                    "Selecione um filiado para filtrar os dados",
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                ),
                              ),
                            ),
                            onChanged: (String? cliSelecionado) async {
                              setState(() {
                                _dadosFiliado = cliSelecionado;
                              });
                              _filiadoEmail =
                                  await fetchAndSetFiliadoEmail(cliSelecionado);
                              _filiadoId =
                                  await fetchAndSetFiliadoId(cliSelecionado);
                              setState(() {});
                            },
                            selectedItem: _dadosFiliado,
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.045,
                        ),
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientBtn(),
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _filiadoEmail = null;
                                _filiadoId = null;
                                _dadosFiliado = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              minimumSize: Size(40,
                                  40), // Garantir que o botão ocupe o tamanho do Container
                              padding: EdgeInsets
                                  .zero, // Remover padding para centralizar o ícone
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Icon(
                              Icons.clear_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              const SizedBox(height: 20),
              size.width <= 720
                  ? Column(
                      children: [
                        PieChartProd(
                            widget.email, widget.tipoUser, widget.idUser, _filiadoEmail, _filiadoId),
                        const SizedBox(height: 20),
                        Prodchart(widget.email, widget.tipoUser, widget.idUser, _filiadoEmail, _filiadoId),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PieChartProd(
                            widget.email, widget.tipoUser, widget.idUser, _filiadoEmail, _filiadoId),
                        const SizedBox(width: 20),
                        Prodchart(widget.email, widget.tipoUser, widget.idUser, _filiadoEmail, _filiadoId),
                      ],
                    ),
              const SizedBox(height: 20), // Espaçamento entre os gráficos
              LineChartSample1(widget.email, widget.tipoUser, widget.idUser,
                  _filiadoEmail, _filiadoId),
              const SizedBox(height: 20),
              size.width <= 720
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TotalClientes(widget.email, widget.tipoUser,
                            widget.idUser, _filiadoEmail, _filiadoId),
                        const SizedBox(height: 15),
                        TotalProdutos(widget.email, widget.tipoUser,
                            widget.idUser, _filiadoEmail, _filiadoId),
                        const SizedBox(height: 15),
                        TotalVendas(widget.email, widget.tipoUser,
                            widget.idUser, _filiadoEmail, _filiadoId),
                        const SizedBox(height: 15),
                        //TotalVendidos( widget.email, widget.tipoUser, widget.idUser, _filiadoEmail, _filiadoId),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TotalClientes(widget.email, widget.tipoUser,
                            widget.idUser, _filiadoEmail, _filiadoId),
                        const SizedBox(width: 15),
                        TotalProdutos(widget.email, widget.tipoUser,
                            widget.idUser, _filiadoEmail, _filiadoId),
                        const SizedBox(width: 15),
                        TotalVendas(widget.email, widget.tipoUser,
                            widget.idUser, _filiadoEmail, _filiadoId),
                        const SizedBox(width: 15),
                        //TotalVendidos(widget.email, widget.tipoUser, widget.idUser, _filiadoEmail, _filiadoId),
                      ],
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

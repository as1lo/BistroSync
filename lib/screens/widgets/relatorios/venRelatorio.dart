import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
//import 'package:http/http.dart' as http;

class VenRelatorio extends StatelessWidget {
  final String? clienteid;
  final String? emailFiliado;
  String dadosCliente = '';
  String mesInicial = '';
  String mesFinal = '';
  String anoInicial = '';
  final String? email;
  final String tipoUser;

  VenRelatorio({this.clienteid, this.email, required this.tipoUser, required this.emailFiliado});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        onPressed: () async {
          showDialogCliente(context, dadosCliente, mesInicial, mesFinal,
              anoInicial, email ?? '', tipoUser, emailFiliado);
        },
        icon: const Icon(Icons.picture_as_pdf_rounded),
        tooltip: 'Gerar $email',
      ),
    );
  }
}

//TODAS AS VENDAS
Future<void> generateAndPrintPdf(BuildContext context, String email,
    String tipoUser, String? emailFiliado) async {
  DateTime datahora = DateTime.now();
  DateFormat formatoData = DateFormat('dd/MM/yyyy | HH:mm');

  List<Map<String, dynamic>> listVendas = [];

  final pdf = pw.Document();

  // Buscar clientes do Firestore
  final collection = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('clientes')
          : FirebaseFirestore.instance
              .collection('clientes')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('clientes')
          .where('email_user', isEqualTo: email);

  final querySnapshot = await collection.get();

  // Buscar vendas do Firestore
  final vendas = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('vendas')
          : FirebaseFirestore.instance
              .collection('vendas')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('vendas')
          .where('email_user', isEqualTo: email);

  final queryVendas = await vendas.get();

  // Buscar itens_vendas do Firestore
  final iven = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('itens_vendas')
          : FirebaseFirestore.instance
              .collection('itens_vendas')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('itens_vendas')
          .where('email_user', isEqualTo: email);

  final queryIven = await iven.get();

  // Processar dados de vendas e clientes
  for (var datavendas in queryVendas.docs) {
    String data_hora = '';
    String name = '';
    String clienteEmail = '';
    num total_bruto = 0;
    num total_liq = 0;
    num quantiven = 0;

    for (var datacliente in querySnapshot.docs) {
      if (datavendas['idcliente'] == datacliente.id) {
        data_hora = datavendas['data_hora'];
        total_bruto = datavendas['total_bruto'];
        total_liq = datavendas['total_liq'];
        name = datacliente['name'];
        clienteEmail = datacliente['email'];

        for (var dataiven in queryIven.docs) {
          if (dataiven['idvenda'] == datavendas.id) {
            var aux = dataiven['quantidade'];
            quantiven += aux;
          }
        }
      }
    }

    Map<String, dynamic> novaVenda = {
      'name': name,
      'email': clienteEmail,
      'data_hora': data_hora,
      'total_bruto': total_bruto,
      'total_liq': total_liq,
      'quantiven': quantiven
    };

    // Adicionando a nova venda à lista
    listVendas.add(novaVenda);
  }

  // Estilos
  final pw.TextStyle titleStyle = pw.TextStyle(
    fontSize: 24,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue,
  );

  final pw.TextStyle headerStyle = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  final pw.TextStyle contentStyle = pw.TextStyle(
    fontSize: 12,
    color: PdfColors.black,
  );

  final pw.TextStyle subtitleStyle = pw.TextStyle(
    fontSize: 12,
    color: PdfColors.black,
  );

  // Função para gerar uma página
  pw.Widget buildPage(List<Map<String, dynamic>> vendas, bool showH) {
    pw.Column showHeader() {
      return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Relatório de Vendas', style: titleStyle),
            pw.SizedBox(height: 5),
            pw.Text('Quantidade Total de Vendas: ${listVendas.length}',
                style: titleStyle),
            pw.SizedBox(height: 5),

            // Linha horizontal
            pw.Container(
              height: 2,
              color: PdfColors.grey,
              width: double.infinity,
            ),
            pw.SizedBox(height: 20),
          ]);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        showH ? showHeader() : pw.SizedBox(),
        pw.TableHelper.fromTextArray(
          headers: [
            'Cliente',
            'Email Cliente',
            'Data',
            'Total Bruto',
            'Total Liq.',
            'Quant. Vendidos'
          ],
          data: vendas.map((item) {
            return [
              item['name'],
              item['email'],
              item['data_hora'],
              item['total_bruto'],
              item['total_liq'],
              item['quantiven']
            ];
          }).toList(),
          headerStyle: headerStyle,
          cellStyle: contentStyle,
          cellAlignment: pw.Alignment.centerLeft,
        ),
        pw.SizedBox(height: 10),

        // Linha horizontal
        pw.Container(
          height: 2,
          color: PdfColors.grey,
          width: double.infinity,
        ),

        pw.SizedBox(height: 10),

        // Rodapé
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Desenvolvido por BIG4TECH', style: subtitleStyle),
            pw.Text(formatoData.format(datahora), style: subtitleStyle),
          ],
        ),
      ],
    );
  }

  int itemsPerPage = 15;
  for (int i = 0; i < listVendas.length; i += itemsPerPage) {
    bool showH = i < itemsPerPage;
    var vendasPage = listVendas.sublist(
        i,
        i + itemsPerPage > listVendas.length
            ? listVendas.length
            : i + itemsPerPage);
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => buildPage(vendasPage, showH),
      ),
    );
  }

  // Exibir e imprimir o PDF na web
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

//FILTRAR POR CLIENTE
Future<void> generateAndPrintPdfCliente(BuildContext context, String clienteid,
    String email, String tipoUser, String? emailFiliado) async {
  DateTime datahora = DateTime.now();
  DateFormat formatoData = DateFormat('dd/MM/yyyy | HH:mm');

  List<Map<String, dynamic>> listVendas = [];
  String nomeCliente = '';
  num cont = 0;
  num totalBrutoGeral = 0;
  num totalLiqGeral = 0;

  final pdf = pw.Document();

  // Buscar clientes do Firestore
  final collection = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('clientes')
          : FirebaseFirestore.instance
              .collection('clientes')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('clientes')
          .where('email_user', isEqualTo: email);
  final querySnapshot = await collection.get();

  // Buscar vendas do Firestore
  final vendas = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('vendas')
          : FirebaseFirestore.instance
              .collection('vendas')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('vendas')
          .where('email_user', isEqualTo: email);

  final queryVendas = await vendas.get();

  // Buscar itens_vendas do Firestore
  final iven = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('itens_vendas')
          : FirebaseFirestore.instance
              .collection('itens_vendas')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('itens_vendas')
          .where('email_user', isEqualTo: email);

  final queryIven = await iven.get();

  // Processar dados de vendas e clientes
  for (var datavendas in queryVendas.docs) {
    String data_hora = '';
    String name = '';
    String clienteEmail = '';
    num total_bruto = 0;
    num total_liq = 0;
    num quantiven = 0;

    for (var datacliente in querySnapshot.docs) {
      if (datavendas['idcliente'] == datacliente.id &&
          clienteid == datacliente.id) {
        data_hora = datavendas['data_hora'];
        total_bruto = datavendas['total_bruto'];
        total_liq = datavendas['total_liq'];
        name = datacliente['name'];
        clienteEmail = datacliente['email'];

        totalBrutoGeral += total_bruto;
        totalLiqGeral += total_liq;

        for (var dataiven in queryIven.docs) {
          if (dataiven['idvenda'] == datavendas.id) {
            var aux = dataiven['quantidade'];
            quantiven += aux;
            cont += aux;
          }
        }

        Map<String, dynamic> novaVenda = {
          'name': name,
          'email': clienteEmail,
          'data_hora': data_hora,
          'total_bruto': total_bruto,
          'total_liq': total_liq,
          'quantiven': quantiven
        };

        nomeCliente = name;
        // Adicionando a nova venda à lista
        listVendas.add(novaVenda);
      }
    }
  }

  // Estilos
  final pw.TextStyle titleStyle = pw.TextStyle(
    fontSize: 24,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue,
  );

  final pw.TextStyle nameCliente = pw.TextStyle(
    fontSize: 18,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  final pw.TextStyle headerStyle = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  final pw.TextStyle contentStyle = pw.TextStyle(
    fontSize: 12,
    color: PdfColors.black,
  );

  final pw.TextStyle subtitleStyle = pw.TextStyle(
    fontSize: 12,
    color: PdfColors.black,
  );

  // Função para gerar uma página
  pw.Widget buildPage(List<Map<String, dynamic>> vendas, bool showH) {
    pw.Column showHeader() {
      return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Relatório de Vendas', style: titleStyle),
            pw.SizedBox(height: 5),
            pw.Container(
              height: 2,
              color: PdfColors.grey,
              width: double.infinity,
            ),
            pw.SizedBox(height: 5),
            pw.Text('Informações Gerais', style: nameCliente),
            pw.SizedBox(height: 5),
            pw.Text('Cliente: $nomeCliente', style: subtitleStyle),
            pw.SizedBox(height: 2),
            pw.Text('Quant. Total Itens Vendidos: $cont', style: subtitleStyle),
            pw.SizedBox(height: 2),
            pw.Text('Quant. Total Vendas: ${vendas.length}', style: subtitleStyle),
            pw.SizedBox(height: 2),
            pw.Text('Total Bruto: R\$$totalBrutoGeral', style: subtitleStyle),
            pw.SizedBox(height: 2),
            pw.Text('Total Liq.: R\$$totalLiqGeral', style: subtitleStyle),
            pw.SizedBox(height: 5),
            // Linha horizontal
            pw.Container(
              height: 2,
              color: PdfColors.grey,
              width: double.infinity,
            ),
            pw.SizedBox(height: 20),
          ]);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        showH ? showHeader() : pw.SizedBox(),
        pw.TableHelper.fromTextArray(
          headers: [
            'Cliente',
            'Email Cliente',
            'Data',
            'Total Bruto',
            'Total Liq.',
            'Quant. Vendidos'
          ],
          data: vendas.map((item) {
            return [
              item['name'],
              item['email'],
              item['data_hora'],
              item['total_bruto'],
              item['total_liq'],
              item['quantiven']
            ];
          }).toList(),
          headerStyle: headerStyle,
          cellStyle: contentStyle,
          cellAlignment: pw.Alignment.centerLeft,
        ),
        pw.SizedBox(height: 10),

        // Linha horizontal
        pw.Container(
          height: 2,
          color: PdfColors.grey,
          width: double.infinity,
        ),

        pw.SizedBox(height: 10),

        // Rodapé
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Desenvolvido por BIG4TECH', style: subtitleStyle),
            pw.Text(formatoData.format(datahora), style: subtitleStyle),
          ],
        ),
      ],
    );
  }

  int itemsPerPage = 10;
  for (int i = 0; i < listVendas.length; i += itemsPerPage) {
    bool showH = i < itemsPerPage;
    var vendasPage = listVendas.sublist(
        i,
        i + itemsPerPage > listVendas.length ? listVendas.length : i + itemsPerPage);
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => buildPage(vendasPage, showH),
      ),
    );
  }

  // Exibir e imprimir o PDF na web
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

//FILTRAR POR ANO
Future<void> generateAndPrintPdfAno(BuildContext context, String anoEscolhido,
    String email, String tipoUser, String? emailFiliado) async {
  DateTime firstDayOfYear = DateTime(int.parse(anoEscolhido), 1, 1);
  DateTime lastDayOfYear = DateTime(int.parse(anoEscolhido), 12, 31);
  DateTime datahora = DateTime.now();
  DateFormat formatoData = DateFormat('dd/MM/yyyy | HH:mm');

  List<Map<String, dynamic>> listVendas = [];
  num cont = 0;
  num totalBrutoGeral = 0;
  num totalLiqGeral = 0;

  final pdf = pw.Document();

  // Buscar clientes do Firestore
  final collection = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('clientes')
          : FirebaseFirestore.instance
              .collection('clientes')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('clientes')
          .where('email_user', isEqualTo: email);

  final querySnapshot = await collection.get();

  // Buscar vendas do Firestore
  final vendas = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('vendas')
          : FirebaseFirestore.instance
              .collection('vendas')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('vendas')
          .where('email_user', isEqualTo: email);

  final queryVendas = await vendas
      .where('data',
          isGreaterThanOrEqualTo: firstDayOfYear,
          isLessThanOrEqualTo: lastDayOfYear)
      .get();

  // Buscar itens_vendas do Firestore
  final iven = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('itens_vendas')
          : FirebaseFirestore.instance
              .collection('itens_vendas')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('itens_vendas')
          .where('email_user', isEqualTo: email);

  final queryIven = await iven.get();

  // Processar dados de vendas e clientes
  for (var datavendas in queryVendas.docs) {
    String data_hora = '';
    String name = '';
    String clienteEmail = '';
    num total_bruto = 0;
    num total_liq = 0;
    num quantiven = 0;

    for (var datacliente in querySnapshot.docs) {
      if (datavendas['idcliente'] == datacliente.id) {
        data_hora = datavendas['data_hora'];
        total_bruto = datavendas['total_bruto'];
        total_liq = datavendas['total_liq'];
        name = datacliente['name'];
        clienteEmail = datacliente['email'];

        totalBrutoGeral += total_bruto;
        totalLiqGeral += total_liq;

        for (var dataiven in queryIven.docs) {
          if (dataiven['idvenda'] == datavendas.id) {
            var aux = dataiven['quantidade'];
            quantiven += aux;
            cont += aux;
          }
        }

        Map<String, dynamic> novaVenda = {
          'name': name,
          'email': clienteEmail,
          'data_hora': data_hora,
          'total_bruto': total_bruto,
          'total_liq': total_liq,
          'quantiven': quantiven
        };

        // Adicionando a nova venda à lista
        listVendas.add(novaVenda);
        print('${listVendas.length}');
      }
    }
  }

  // Estilos
  final pw.TextStyle titleStyle = pw.TextStyle(
    fontSize: 24,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue,
  );

  final pw.TextStyle nameCliente = pw.TextStyle(
    fontSize: 18,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  final pw.TextStyle headerStyle = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  final pw.TextStyle contentStyle = pw.TextStyle(
    fontSize: 12,
    color: PdfColors.black,
  );

  final pw.TextStyle subtitleStyle = pw.TextStyle(
    fontSize: 12,
    color: PdfColors.black,
  );

  // Função para gerar uma página
  pw.Widget buildPage(List<Map<String, dynamic>> vendas, bool showH) {
    pw.Column showHeader() {
      return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Relatório de Vendas', style: titleStyle),
            pw.SizedBox(height: 5),
            pw.Container(
              height: 2,
              color: PdfColors.grey,
              width: double.infinity,
            ),
            pw.SizedBox(height: 5),
            pw.Text('Informações Gerais', style: nameCliente),
            pw.SizedBox(height: 2),
            pw.Text('Período: $anoEscolhido', style: subtitleStyle),
            pw.SizedBox(height: 2),
            pw.Text('Quant. Total Itens Vendidos: $cont', style: subtitleStyle),
            pw.SizedBox(height: 2),
            pw.Text('Quant. Total Vendas: ${vendas.length}', style: subtitleStyle),
            pw.SizedBox(height: 2),
            pw.Text('Total Bruto: R\$$totalBrutoGeral', style: subtitleStyle),
            pw.SizedBox(height: 2),
            pw.Text('Total Liq.: R\$$totalLiqGeral', style: subtitleStyle),
            pw.SizedBox(height: 5),
            // Linha horizontal
            pw.Container(
              height: 2,
              color: PdfColors.grey,
              width: double.infinity,
            ),
            pw.SizedBox(height: 20),
          ]);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        showH ? showHeader() : pw.SizedBox(),
        pw.TableHelper.fromTextArray(
          headers: [
            'Cliente',
            'Email Cliente',
            'Data',
            'Total Bruto',
            'Total Liq.',
            'Quant. Vendidos'
          ],
          data: vendas.map((item) {
            return [
              item['name'],
              item['email'],
              item['data_hora'],
              item['total_bruto'],
              item['total_liq'],
              item['quantiven']
            ];
          }).toList(),
          headerStyle: headerStyle,
          cellStyle: contentStyle,
          cellAlignment: pw.Alignment.centerLeft,
        ),
        pw.SizedBox(height: 10),

        // Linha horizontal
        pw.Container(
          height: 2,
          color: PdfColors.grey,
          width: double.infinity,
        ),

        pw.SizedBox(height: 10),

        // Rodapé
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Desenvolvido por BIG4TECH', style: subtitleStyle),
            pw.Text(formatoData.format(datahora), style: subtitleStyle),
          ],
        ),
      ],
    );
  }

  int itemsPerPage = 11;
  for (int i = 0; i < listVendas.length; i += itemsPerPage) {
    bool showH = i < itemsPerPage;
    var vendasPage = listVendas.sublist(
        i,
        i + itemsPerPage > listVendas.length ? listVendas.length : i + itemsPerPage);
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => buildPage(vendasPage, showH),
      ),
    );
  }

  // Exibir e imprimir o PDF na web
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

//FILTRAR POR UNICO MES NO ANO
Future<void> generateAndPrintPdfMesAno(
    BuildContext context,
    String mesEscolhido,
    String anoEscolhido,
    String email,
    String tipoUser,
    String? emailFiliado) async {
  String mes;
  switch (mesEscolhido) {
    case 'Janeiro':
      mes = '1';
      break;
    case 'Fevereiro':
      mes = '2';
      break;
    case 'Março':
      mes = '3';
      break;
    case 'Abril':
      mes = '4';
      break;
    case 'Maio':
      mes = '5';
      break;
    case 'Junho':
      mes = '6';
      break;
    case 'Julho':
      mes = '7';
      break;
    case 'Agosto':
      mes = '8';
      break;
    case 'Setembro':
      mes = '9';
      break;
    case 'Outubro':
      mes = '10';
      break;
    case 'Novembro':
      mes = '11';
      break;
    case 'Dezembro':
      mes = '12';
      break;
    default:
      mes = '0';
  }

  DateTime datahora = DateTime.now();
  DateTime firstDayOfMonth =
      DateTime(int.parse(anoEscolhido), int.parse(mes), 1);
  DateTime lastDayOfMonth =
      DateTime(int.parse(anoEscolhido), int.parse(mes) + 1, 1)
          .subtract(const Duration(days: 1));

  DateFormat formatoData = DateFormat('dd/MM/yyyy | HH:mm');

  List<Map<String, dynamic>> listVendas = [];

  num cont = 0;
  num totalBrutoGeral = 0;
  num totalLiqGeral = 0;

  final pdf = pw.Document();

  // Buscar clientes do Firestore
  final collection = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('clientes')
          : FirebaseFirestore.instance
              .collection('clientes')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('clientes')
          .where('email_user', isEqualTo: email);

  final querySnapshot = await collection.get();

  // Buscar vendas do Firestore
  final vendas = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('vendas')
          : FirebaseFirestore.instance
              .collection('vendas')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('vendas')
          .where('email_user', isEqualTo: email);

  final queryVendas = await vendas
      .where('data',
          isGreaterThanOrEqualTo: firstDayOfMonth,
          isLessThanOrEqualTo: lastDayOfMonth)
      .get();

  // Buscar itens_vendas do Firestore
  final iven = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('itens_vendas')
          : FirebaseFirestore.instance
              .collection('itens_vendas')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('itens_vendas')
          .where('email_user', isEqualTo: email);

  final queryIven = await iven.get();

  for (var datavendas in queryVendas.docs) {
    String data_hora = '';
    String name = '';
    String clienteEmail = '';
    num total_bruto = 0;
    num total_liq = 0;
    num quantiven = 0;

    for (var datacliente in querySnapshot.docs) {
      if (datavendas['idcliente'] == datacliente.id) {
        data_hora = datavendas['data_hora'];
        total_bruto = datavendas['total_bruto'];
        total_liq = datavendas['total_liq'];
        name = datacliente['name'];
        clienteEmail = datacliente['email'];

        totalBrutoGeral += total_bruto;
        totalLiqGeral += total_liq;

        for (var dataiven in queryIven.docs) {
          if (dataiven['idvenda'] == datavendas.id) {
            var aux = dataiven['quantidade'];
            quantiven += aux;
            cont += aux;
          }
        }

        Map<String, dynamic> novaVenda = {
          'name': name,
          'email': clienteEmail,
          'data_hora': data_hora,
          'total_bruto': total_bruto,
          'total_liq': total_liq,
          'quantiven': quantiven
        };

        // Adicionando a nova venda à lista
        listVendas.add(novaVenda);
        print('${listVendas.length}');
      }
    }
  }

  // Estilos
  final pw.TextStyle titleStyle = pw.TextStyle(
    fontSize: 24,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue,
  );

  final pw.TextStyle nameCliente = pw.TextStyle(
    fontSize: 18,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  final pw.TextStyle headerStyle = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  final pw.TextStyle contentStyle = pw.TextStyle(
    fontSize: 12,
    color: PdfColors.black,
  );

  final pw.TextStyle subtitleStyle = pw.TextStyle(
    fontSize: 12,
    color: PdfColors.black,
  );

  // Função para gerar uma página
  pw.Widget buildPage(List<Map<String, dynamic>> vendas, bool showH) {
    pw.Column showHeader() {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Relatório de Vendas', style: titleStyle),
          pw.SizedBox(height: 5),
          pw.Container(
            height: 2,
            color: PdfColors.grey,
            width: double.infinity,
          ),
          pw.SizedBox(height: 5),
          pw.Text('Informações Gerais', style: nameCliente),
          pw.SizedBox(height: 2),
          pw.Text('Período: $mesEscolhido - $anoEscolhido', style: subtitleStyle),
          pw.SizedBox(height: 2),
          pw.Text('Quant. Total Itens Vendidos: $cont', style: subtitleStyle),
          pw.SizedBox(height: 2),
          pw.Text('Quant. Total Vendas: ${vendas.length}', style: subtitleStyle),
          pw.SizedBox(height: 2),
          pw.Text('Total Bruto: R\$$totalBrutoGeral', style: subtitleStyle),
          pw.SizedBox(height: 2),
          pw.Text('Total Liq.: R\$$totalLiqGeral', style: subtitleStyle),
          pw.SizedBox(height: 5),
          // Linha horizontal
          pw.Container(
            height: 2,
            color: PdfColors.grey,
            width: double.infinity,
          ),
          pw.SizedBox(height: 20),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        showH ? showHeader() : pw.SizedBox(),
        pw.TableHelper.fromTextArray(
          headers: [
            'Cliente',
            'Email Cliente',
            'Data',
            'Total Bruto',
            'Total Liq.',
            'Quant. Vendidos'
          ],
          data: vendas.map((item) {
            return [
              item['name'],
              item['email'],
              item['data_hora'],
              item['total_bruto'],
              item['total_liq'],
              item['quantiven']
            ];
          }).toList(),
          headerStyle: headerStyle,
          cellStyle: contentStyle,
          cellAlignment: pw.Alignment.centerLeft,
        ),
        pw.SizedBox(height: 10),

        // Linha horizontal
        pw.Container(
          height: 2,
          color: PdfColors.grey,
          width: double.infinity,
        ),

        pw.SizedBox(height: 10),

        // Rodapé
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Desenvolvido por BIG4TECH', style: subtitleStyle),
            pw.Text(formatoData.format(datahora), style: subtitleStyle),
          ],
        ),
      ],
    );
  }

  // Dividir a lista em páginas
  int itemsPerPage = 11; // Defina quantos itens deseja por página
  for (int i = 0; i < listVendas.length; i += itemsPerPage) {
    bool showH = i < itemsPerPage;
    var vendasPage = listVendas.sublist(
        i,
        i + itemsPerPage > listVendas.length ? listVendas.length : i + itemsPerPage);
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => buildPage(vendasPage, showH),
      ),
    );
  }

  // Exibir e imprimir o PDF na web
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

//FILTRAR POR MES, ANO E CLIENTE
Future<void> generateAndPrintPdfMesAnoCliente(
    BuildContext context,
    String mesEscolhido,
    String clienteid,
    String anoEscolhido,
    String email,
    String tipoUser,
    String? emailFiliado) async {
  String mes;

  switch (mesEscolhido) {
    case 'Janeiro':
      mes = '1';
      break;
    case 'Fevereiro':
      mes = '2';
      break;
    case 'Março':
      mes = '3';
      break;
    case 'Abril':
      mes = '4';
      break;
    case 'Maio':
      mes = '5';
      break;
    case 'Junho':
      mes = '6';
      break;
    case 'Julho':
      mes = '7';
      break;
    case 'Agosto':
      mes = '8';
      break;
    case 'Setembro':
      mes = '9';
      break;
    case 'Outubro':
      mes = '10';
      break;
    case 'Novembro':
      mes = '11';
      break;
    case 'Dezembro':
      mes = '12';
      break;
    default:
      mes = '0';
  }

  DateTime datahora = DateTime.now();
  DateTime firstDayOfMonth =
      DateTime(int.parse(anoEscolhido), int.parse(mes), 1);
  DateTime lastDayOfMonth =
      DateTime(int.parse(anoEscolhido), int.parse(mes) + 1, 1)
          .subtract(const Duration(days: 1));

  DateFormat formatoData = DateFormat('dd/MM/yyyy | HH:mm');

  List<Map<String, dynamic>> listVendas = [];
  num cont = 0;
  num totalBrutoGeral = 0;
  num totalLiqGeral = 0;
  String nomeCliente = '';

  final pdf = pw.Document();

  // Buscar clientes do Firestore
  final collection = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('clientes')
          : FirebaseFirestore.instance
              .collection('clientes')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('clientes')
          .where('email_user', isEqualTo: email);

  final querySnapshot = await collection.get();

  // Buscar vendas do Firestore
  final vendas = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('vendas')
          : FirebaseFirestore.instance
              .collection('vendas')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('vendas')
          .where('email_user', isEqualTo: email);

  final queryVendas = await vendas
      .where('data',
          isGreaterThanOrEqualTo: firstDayOfMonth,
          isLessThanOrEqualTo: lastDayOfMonth)
      .get();

  // Buscar itens_vendas do Firestore
  final iven = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('itens_vendas')
          : FirebaseFirestore.instance
              .collection('itens_vendas')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('itens_vendas')
          .where('email_user', isEqualTo: email);

  final queryIven = await iven.get();

  for (var datavendas in queryVendas.docs) {
    String data_hora = '';
    String name = '';
    String clienteEmail = '';
    num total_bruto = 0;
    num total_liq = 0;
    num quantiven = 0;

    for (var datacliente in querySnapshot.docs) {
      if (datavendas['idcliente'] == datacliente.id &&
          clienteid == datacliente.id) {
        data_hora = datavendas['data_hora'];
        total_bruto = datavendas['total_bruto'];
        total_liq = datavendas['total_liq'];
        name = datacliente['name'];
        clienteEmail = datacliente['email'];

        totalBrutoGeral += total_bruto;
        totalLiqGeral += total_liq;

        for (var dataiven in queryIven.docs) {
          if (dataiven['idvenda'] == datavendas.id) {
            var aux = dataiven['quantidade'];
            quantiven += aux;
            cont += aux;
          }
        }

        nomeCliente = name;

        Map<String, dynamic> novaVenda = {
          'name': name,
          'email': clienteEmail,
          'data_hora': data_hora,
          'total_bruto': total_bruto,
          'total_liq': total_liq,
          'quantiven': quantiven
        };

        // Adicionando a nova venda à lista
        listVendas.add(novaVenda);
        print('${listVendas.length}');
      }
    }
  }

  // Estilos
  final pw.TextStyle titleStyle = pw.TextStyle(
    fontSize: 24,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue,
  );

  final pw.TextStyle nameClienteStyle = pw.TextStyle(
    fontSize: 18,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  final pw.TextStyle headerStyle = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  final pw.TextStyle contentStyle = pw.TextStyle(
    fontSize: 12,
    color: PdfColors.black,
  );

  final pw.TextStyle subtitleStyle = pw.TextStyle(
    fontSize: 12,
    color: PdfColors.black,
  );

  // Função para gerar uma página
  pw.Widget buildPage(List<Map<String, dynamic>> vendas, bool showH) {
    pw.Column showHeader() {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Relatório de Vendas', style: titleStyle),
          pw.SizedBox(height: 5),
          pw.Container(
            height: 2,
            color: PdfColors.grey,
            width: double.infinity,
          ),
          pw.SizedBox(height: 5),
          pw.Text('Informações Gerais', style: nameClienteStyle),
          pw.SizedBox(height: 2),
          pw.Text('Cliente: $nomeCliente', style: subtitleStyle),
          pw.SizedBox(height: 2),
          pw.Text('Período: $mesEscolhido - $anoEscolhido', style: subtitleStyle),
          pw.SizedBox(height: 2),
          pw.Text('Quant. Total Itens Vendidos: $cont', style: subtitleStyle),
          pw.SizedBox(height: 2),
          pw.Text('Quant. Total Vendas: ${vendas.length}', style: subtitleStyle),
          pw.SizedBox(height: 2),
          pw.Text('Total Bruto: R\$$totalBrutoGeral', style: subtitleStyle),
          pw.SizedBox(height: 2),
          pw.Text('Total Liq.: R\$$totalLiqGeral', style: subtitleStyle),
          pw.SizedBox(height: 5),
          // Linha horizontal
          pw.Container(
            height: 2,
            color: PdfColors.grey,
            width: double.infinity,
          ),
          pw.SizedBox(height: 20),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        showH ? showHeader() : pw.SizedBox(),
        pw.TableHelper.fromTextArray(
          headers: [
            'Cliente',
            'Email Cliente',
            'Data',
            'Total Bruto',
            'Total Liq.',
            'Quant. Vendidos'
          ],
          data: vendas.map((item) {
            return [
              item['name'],
              item['email'],
              item['data_hora'],
              item['total_bruto'],
              item['total_liq'],
              item['quantiven']
            ];
          }).toList(),
          headerStyle: headerStyle,
          cellStyle: contentStyle,
          cellAlignment: pw.Alignment.centerLeft,
        ),
        pw.SizedBox(height: 10),

        // Linha horizontal
        pw.Container(
          height: 2,
          color: PdfColors.grey,
          width: double.infinity,
        ),

        pw.SizedBox(height: 10),

        // Rodapé
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Desenvolvido por BIG4TECH', style: subtitleStyle),
            pw.Text(formatoData.format(datahora), style: subtitleStyle),
          ],
        ),
      ],
    );
  }

  int itemsPerPage = 11;
  for (int i = 0; i < listVendas.length; i += itemsPerPage) {
    bool showH = i < itemsPerPage;
    var vendasPage = listVendas.sublist(
        i,
        i + itemsPerPage > listVendas.length ? listVendas.length : i + itemsPerPage);
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => buildPage(vendasPage, showH),
      ),
    );
  }

  // Exibir e imprimir o PDF na web
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

//FILTRAR POR ANO E CLIENTE
Future<void> generateAndPrintPdfAnoCliente(
    BuildContext context,
    String clienteid,
    String anoEscolhido,
    String email,
    String tipoUser,
    String? emailFiliado) async {
  DateTime datahora = DateTime.now();
  DateTime firstDayOfMonth = DateTime(int.parse(anoEscolhido), 1, 1);
  DateTime lastDayOfMonth = DateTime(int.parse(anoEscolhido), 12, 31);

  DateFormat formatoData = DateFormat('dd/MM/yyyy | HH:mm');

  List<Map<String, dynamic>> listVendas = [];
  num cont = 0;
  num totalBrutoGeral = 0;
  num totalLiqGeral = 0;
  String nomeCliente = '';

  final pdf = pw.Document();

  // Buscar clientes do Firestore
  final collection = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('clientes')
          : FirebaseFirestore.instance
              .collection('clientes')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('clientes')
          .where('email_user', isEqualTo: email);
  final querySnapshot = await collection.get();

  // Buscar vendas do Firestore
  final vendas = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('vendas')
          : FirebaseFirestore.instance
              .collection('vendas')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('vendas')
          .where('email_user', isEqualTo: email);

  final queryVendas = await vendas
      .where('data',
          isGreaterThanOrEqualTo: firstDayOfMonth,
          isLessThanOrEqualTo: lastDayOfMonth)
      .get();

  // Buscar itens_vendas do Firestore
  final iven = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('itens_vendas')
          : FirebaseFirestore.instance
              .collection('itens_vendas')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('itens_vendas')
          .where('email_user', isEqualTo: email);
  final queryIven = await iven.get();

  for (var datavendas in queryVendas.docs) {
    String data_hora = '';
    String name = '';
    String clienteEmail = '';
    num total_bruto = 0;
    num total_liq = 0;
    num quantiven = 0;

    for (var datacliente in querySnapshot.docs) {
      if (datavendas['idcliente'] == datacliente.id &&
          clienteid == datacliente.id) {
        data_hora = datavendas['data_hora'];
        total_bruto = datavendas['total_bruto'];
        total_liq = datavendas['total_liq'];
        name = datacliente['name'];
        clienteEmail = datacliente['email'];

        totalBrutoGeral += total_bruto;
        totalLiqGeral += total_liq;

        for (var dataiven in queryIven.docs) {
          if (dataiven['idvenda'] == datavendas.id) {
            var aux = dataiven['quantidade'];
            quantiven += aux;
            cont += aux;
          }
        }

        nomeCliente = name;

        Map<String, dynamic> novaVenda = {
          'name': name,
          'email': clienteEmail,
          'data_hora': data_hora,
          'total_bruto': total_bruto,
          'total_liq': total_liq,
          'quantiven': quantiven
        };

        // Adicionando a nova venda à lista
        listVendas.add(novaVenda);
        print('${listVendas.length}');
      }
    }
  }

  // Estilos
  final pw.TextStyle titleStyle = pw.TextStyle(
    fontSize: 24,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue,
  );

  final pw.TextStyle nameClienteStyle = pw.TextStyle(
    fontSize: 18,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  final pw.TextStyle headerStyle = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  final pw.TextStyle contentStyle = pw.TextStyle(
    fontSize: 12,
    color: PdfColors.black,
  );

  final pw.TextStyle subtitleStyle = pw.TextStyle(
    fontSize: 12,
    color: PdfColors.black,
  );

  // Função para gerar uma página
  pw.Widget buildPage(List<Map<String, dynamic>> vendas, bool showH) {
    pw.Column showHeader() {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Relatório de Vendas', style: titleStyle),
          pw.SizedBox(height: 5),
          pw.Container(
            height: 2,
            color: PdfColors.grey,
            width: double.infinity,
          ),
          pw.SizedBox(height: 5),
          pw.Text('Informações Gerais', style: nameClienteStyle),
          pw.SizedBox(height: 2),
          pw.Text('Cliente: $nomeCliente', style: subtitleStyle),
          pw.SizedBox(height: 2),
          pw.Text('Período: $anoEscolhido', style: subtitleStyle),
          pw.SizedBox(height: 2),
          pw.Text('Quant. Total Itens Vendidos: $cont', style: subtitleStyle),
          pw.SizedBox(height: 2),
          pw.Text('Quant. Total Vendas: ${vendas.length}', style: subtitleStyle),
          pw.SizedBox(height: 2),
          pw.Text('Total Bruto: R\$$totalBrutoGeral', style: subtitleStyle),
          pw.SizedBox(height: 2),
          pw.Text('Total Liq.: R\$$totalLiqGeral', style: subtitleStyle),
          pw.SizedBox(height: 5),
          // Linha horizontal
          pw.Container(
            height: 2,
            color: PdfColors.grey,
            width: double.infinity,
          ),
          pw.SizedBox(height: 20),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        showH ? showHeader() : pw.SizedBox(),
        pw.TableHelper.fromTextArray(
          headers: [
            'Cliente',
            'Email Cliente',
            'Data',
            'Total Bruto',
            'Total Liq.',
            'Quant. Vendidos'
          ],
          data: vendas.map((item) {
            return [
              item['name'],
              item['email'],
              item['data_hora'],
              item['total_bruto'],
              item['total_liq'],
              item['quantiven']
            ];
          }).toList(),
          headerStyle: headerStyle,
          cellStyle: contentStyle,
          cellAlignment: pw.Alignment.centerLeft,
        ),
        pw.SizedBox(height: 10),

        // Linha horizontal
        pw.Container(
          height: 2,
          color: PdfColors.grey,
          width: double.infinity,
        ),

        pw.SizedBox(height: 10),

        // Rodapé
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Desenvolvido por BIG4TECH', style: subtitleStyle),
            pw.Text(formatoData.format(datahora), style: subtitleStyle),
          ],
        ),
      ],
    );
  }

  int itemsPerPage = 11;
  for (int i = 0; i < listVendas.length; i += itemsPerPage) {
    bool showH = i < itemsPerPage;
    var vendasPage = listVendas.sublist(
        i,
        i + itemsPerPage > listVendas.length ? listVendas.length : i + itemsPerPage);
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => buildPage(vendasPage, showH),
      ),
    );
  }

  // Exibir e imprimir o PDF na web
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

//fazer a lista de clistes pro dropdown
Future<List<String>> _setListCliente(String email, String tipoUser, String? emailFiliado) async {
  List<String> listClienteDrop = [];

  var query = tipoUser == 'master'
      ? (emailFiliado == null
          ? await FirebaseFirestore.instance.collection('clientes').get()
          : await FirebaseFirestore.instance
              .collection('clientes')
              .where('email_user', isEqualTo: emailFiliado)
              .get())
      : await FirebaseFirestore.instance
          .collection('clientes')
          .where('email_user', isEqualTo: email)
          .get();

  for (var doc in query.docs) {
    listClienteDrop.add(
        '${doc['name']} | Email: ${doc['email']} | Whatsapp: ${doc['whatsapp']}');
  }

  return listClienteDrop;
}

//fazer a lista de ano pro dropdown
Future<List<String>> _setListAno(String email, String tipoUser, String? emailFiliado) async {
  List<String> listAnoDrop = [];

  var query = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('vendas')
          : FirebaseFirestore.instance
              .collection('vendas')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('vendas')
          .where('email_user', isEqualTo: email);

  query.snapshots().listen((querySnapshot) {
    for (var doc in querySnapshot.docs) {
      DateTime dataHora = (doc['data'] as Timestamp).toDate();
      String year = dataHora.year.toString();

      if (!listAnoDrop.contains(year)) {
        listAnoDrop.add(year);
      }
    }
  });

  return listAnoDrop;
}

Future<String?> fetchAndSetIdCliente(
    String? cliSelecionado, String email, String tipoUser, String? emailFiliado) async {
  var query = tipoUser == 'master'
      ? (emailFiliado == null
          ? await FirebaseFirestore.instance.collection('clientes').get()
          : await FirebaseFirestore.instance
              .collection('clientes')
              .where('email_user', isEqualTo: emailFiliado)
              .get())
      : await FirebaseFirestore.instance
          .collection('clientes')
          .where('email_user', isEqualTo: email)
          .get();

  for (var doc in query.docs) {
    if (cliSelecionado ==
        '${doc['name']} | Email: ${doc['email']} | Whatsapp: ${doc['whatsapp']}') {
      return doc.id;
    }
  }
  return null;
}

void showDialogCliente(
    BuildContext context,
    String dadosCliente,
    String mesInicial,
    String mesFinal,
    String anoInicial,
    String email,
    String tipoUser,
    String? emailFiliado) async {
  dadosCliente = '';
  mesInicial = '';
  mesFinal = '';
  anoInicial = '';
  String? cliid = '';

  List<String> listCliente = [];
  List<String> listAno = [];

  listCliente = await _setListCliente(email, tipoUser, emailFiliado);
  listAno = await _setListAno(email, tipoUser, emailFiliado);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return AlertDialog(
          title: const Text(
            "Filtro",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          scrollable: true,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //CLIENTES
              DropdownSearch<String>(
                popupProps: const PopupProps.menu(
                    showSelectedItems: true,
                    //disabledItemFn: (String s) => s.startsWith('I'),
                    showSearchBox: true),
                items: listCliente,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    labelText: "Cliente",
                    hintText: "Selecione um dos clientes.",
                  ),
                ),
                onChanged: (String? cliSelecionado) {
                  setState(() async {
                    dadosCliente = cliSelecionado.toString();
                    cliid = await fetchAndSetIdCliente(
                        cliSelecionado, email, tipoUser, emailFiliado);
                  });
                },
                selectedItem: dadosCliente,
              ),

              const SizedBox(height: 20),

              //MÊS
              DropdownSearch<String>(
                popupProps: const PopupProps.menu(
                    showSelectedItems: true,
                    //disabledItemFn: (String s) => s.startsWith('I'),
                    showSearchBox: true),
                items: const [
                  'Janeiro',
                  'Fevereiro',
                  'Março',
                  'Abril',
                  'Maio',
                  'Junho',
                  'Julho',
                  'Agosto',
                  'Setembro',
                  'Outubro',
                  'Novembro',
                  'Dezembro'
                ],
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    labelText: "Mês Inicial",
                    hintText: "Selecione um mês.",
                  ),
                ),
                onChanged: (String? mesSelecionado) {
                  setState(() {
                    mesInicial = mesSelecionado.toString();
                  });
                },
                selectedItem: mesInicial,
              ),

              const SizedBox(height: 20),

              //ANO
              DropdownSearch<String>(
                popupProps: const PopupProps.menu(
                    showSelectedItems: true,
                    //disabledItemFn: (String s) => s.startsWith('I'),
                    showSearchBox: true),
                items: listAno,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    labelText: "Ano Inicial",
                    hintText: "Selecione um Ano.",
                  ),
                ),
                onChanged: (String? anoSelecionado) {
                  setState(() async {
                    anoInicial = anoSelecionado.toString();
                  });
                },
                selectedItem: anoInicial,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(20, 42),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              child: const Text(
                "Gerar",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              onPressed: () async {
                if (mesInicial != '' && cliid != '' && anoInicial != '') {
                  //cliente baseado no mês (precisa do ano)
                  await generateAndPrintPdfMesAnoCliente(context, mesInicial,
                      cliid.toString(), anoInicial, email, tipoUser, emailFiliado);
                } else if (mesInicial != '' && anoInicial != '') {
                  //mês (precisa do ano)
                  await generateAndPrintPdfMesAno(
                      context, mesInicial, anoInicial, email, tipoUser, emailFiliado);
                } else if (cliid != '' && anoInicial != '') {
                  //cliente baseado no ano
                  await generateAndPrintPdfAnoCliente(
                      context, cliid.toString(), anoInicial, email, tipoUser, emailFiliado);
                } else if (cliid != '') {
                  //só o cliente
                  await generateAndPrintPdfCliente(
                      context, cliid.toString(), email, tipoUser, emailFiliado);
                } else if (anoInicial != '') {
                  //só o ano
                  await generateAndPrintPdfAno(
                      context, anoInicial, email, tipoUser, emailFiliado);
                } else {
                  //geral
                  await generateAndPrintPdf(context, email, tipoUser, emailFiliado);
                }

                //Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
    },
  );
}

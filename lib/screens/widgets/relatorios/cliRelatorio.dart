import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CliRelatorio extends StatelessWidget {
  final String email;
  final String tipoUser;
  final String? emailFiliado;
  CliRelatorio(this.email, this.tipoUser, this.emailFiliado);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        onPressed: () async {
          await generateAndPrintPdf(context);
        },
        icon: const Icon(Icons.picture_as_pdf_rounded),
        tooltip: 'Gerar Relatório',
      ),
    );
  }

  Future<void> generateAndPrintPdf(BuildContext context) async {
    DateTime datahora = DateTime.now();
    DateFormat formatoData = DateFormat('dd/MM/yyyy | HH:mm');

    List<Map<String, dynamic>> clientes = [];

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

    for (var datacliente in querySnapshot.docs) {
      int quantvendas = 0;
      num quantiven = 0;

      for (var datavendas in queryVendas.docs) {
        if (datavendas['idcliente'] == datacliente.id) {
          quantvendas++;

          for (var dataiven in queryIven.docs) {
            if (dataiven['idvenda'] == datavendas.id) {
              var aux = dataiven['quantidade'];
              quantiven += aux;
            }
          }
        }
      }

      Map<String, dynamic> novoCliente = {
        'name': datacliente['name'],
        'whatsapp': datacliente['whatsapp'],
        'email': datacliente['email'],
        'quantvendas': quantvendas,
        'quantiven': quantiven
      };

      // Adicionando o novo cliente à lista
      clientes.add(novoCliente);
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

    // Adicionar dados ao PDF
    pw.Widget buildPage(List<Map<String, dynamic>> clientesPage, bool showH) {
      pw.Column showHeader() {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Relatório de Clientes', style: titleStyle),
            pw.SizedBox(height: 5),
            pw.Text('Quantidade Total de Clientes: ${clientes.length}',
                style: subtitleStyle),
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
              'Nome',
              'Whatsapp',
              'Email',
              'Quant. Compras',
              'Quant. Produtos'
            ],
            data: clientesPage.map((cliente) {
              return [
                cliente['name'],
                cliente['whatsapp'].toString(),
                cliente['email'],
                cliente['quantvendas'].toString(),
                cliente['quantiven'].toString()
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

    for (int i = 0; i < clientes.length; i += itemsPerPage) {
      bool showH = i < itemsPerPage ? true : false;
      var vendasPage = clientes.sublist(
          i,
          i + itemsPerPage > clientes.length
              ? clientes.length
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
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RecebimentosRelatorio extends StatefulWidget {
  final String email;
  final String idUser;
  const RecebimentosRelatorio(this.email, this.idUser);

  @override
  State<StatefulWidget> createState() => _RecebimentosRelatorioState();
}

class _RecebimentosRelatorioState extends State<RecebimentosRelatorio> {
  DateTimeRange? selectedDateRange;
  List<Map<String, dynamic>> recebimentos = [];
  double totalValor = 0.0;

  Future<void> _pickDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      _fetchRecebimentos();
    }
  }

  Future<void> _fetchRecebimentos() async {
    DateTime start = selectedDateRange!.start;
    DateTime end = selectedDateRange!.end
        .add(Duration(hours: 23, minutes: 59, seconds: 59));

    final query = FirebaseFirestore.instance
        .collection('recebimentos')
        .where('id_user', isEqualTo: widget.idUser)
        .where('status', isEqualTo: 'ativo')
        .where('data_recebimento', isGreaterThanOrEqualTo: start)
        .where('data_recebimento', isLessThanOrEqualTo: end);

    final snapshot = await query.get();
    setState(() {
      recebimentos = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      totalValor = recebimentos.fold(
          0.0, (sum, item) => sum + (item['valor'] as double));
    });
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text("Relatório de Próximos Recebimentos"),
            pw.SizedBox(height: 10),
            pw.Text(
                "Período: ${DateFormat('dd/MM/yyyy').format(selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(selectedDateRange!.end)}"),
            pw.Text("Soma Total: R\$ ${totalValor.toStringAsFixed(2)}"),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Valor', 'Cliente', 'Produto', 'Tipo de Pagamento'],
              data: recebimentos.map((recebimento) {
                return [
                  recebimento['valor'].toString(),
                  recebimento['name'],
                  recebimento['nome_produto'],
                  recebimento['tipo_pagamento'],
                ];
              }).toList(),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Relatório de Recebimentos"),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: recebimentos.isNotEmpty ? _generatePDF : null,
          ),
        ],
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () => _pickDateRange(context),
            child: Text(
              selectedDateRange == null
                  ? 'Selecione o Período'
                  : 'Período: ${DateFormat('dd/MM/yyyy').format(selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(selectedDateRange!.end)}',
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: recebimentos.length,
              itemBuilder: (context, index) {
                final recebimento = recebimentos[index];
                return ListTile(
                  title: Text("Valor: ${recebimento['valor']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Cliente: ${recebimento['email_cliente']}"),
                      Text("Produto: ${recebimento['nome_produto']}"),
                      Text("Pagamento: ${recebimento['tipo_pagamento']}"),
                    ],
                  ),
                );
              },
            ),
          ),
          if (totalValor > 0)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Soma Total dos Valores: R\$ ${totalValor.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

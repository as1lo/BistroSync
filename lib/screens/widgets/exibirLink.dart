import 'package:flutter/material.dart';

Future<bool?> showModal(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // Impede que feche ao clicar fora
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmação'),
        content: Text('Você deseja continuar?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Retorna false
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Retorna true
            },
            child: Text('Confirmar'),
          ),
        ],
      );
    },
  );
}

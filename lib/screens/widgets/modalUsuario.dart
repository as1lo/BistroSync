import 'package:flutter/material.dart';

Future<void> exibirModalUsuario(
    BuildContext context, Function(String codigoSessao, String nome) onConfirm) async {
  final TextEditingController nomeController = TextEditingController();
  ValueNotifier<bool> isNomeInvalido = ValueNotifier<bool>(false);

  await showDialog(
    context: context,
    barrierDismissible: false, // Impede que o modal seja fechado ao clicar fora
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Digite seu nome'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: isNomeInvalido,
                  builder: (context, invalid, child) {
                    return TextField(
                      controller: nomeController,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                        errorText: invalid ? 'O nome não pode ser vazio' : null,
                      ),
                    );
                  },
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (nomeController.text.isNotEmpty) {
                    final codigoSessao =
                        DateTime.now().millisecondsSinceEpoch.toString();
                    final nome = nomeController.text;

                    // Chama o callback com os valores gerados
                    onConfirm(codigoSessao, nome);

                    Navigator.of(context).pop(); // Fecha o modal
                  } else {
                    // Atualiza o estado para exibir o erro
                    isNomeInvalido.value = true;
                  }
                },
                child: Text('Confirmar'),
              ),
            ],
          );
        },
      );
    },
  );
}

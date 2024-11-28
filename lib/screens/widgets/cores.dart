import 'package:flutter/material.dart';

Color corPadrao() {
  return const Color.fromRGBO(0, 0, 128, 1); // Azul marinho
}

List<Color> gradientBtn() {
  return const [
    Color.fromRGBO(0, 0, 139, 1),    // Azul escuro
    Color.fromRGBO(25, 25, 112, 1),  // Azul marinho mais profundo
  ];
}



final List<Color> allColors = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey,
  Colors.black,
  Colors.white,

  // Variantes de cinza
  Colors.grey.shade50,
  Colors.grey.shade100,
  Colors.grey.shade200,
  Colors.grey.shade300,
  Colors.grey.shade400,
  Colors.grey.shade500,
  Colors.grey.shade600,
  Colors.grey.shade700,
  Colors.grey.shade800,
  Colors.grey.shade900,

  // Variantes de azul
  Colors.blue.shade50,
  Colors.blue.shade100,
  Colors.blue.shade200,
  Colors.blue.shade300,
  Colors.blue.shade400,
  Colors.blue.shade500,
  Colors.blue.shade600,
  Colors.blue.shade700,
  Colors.blue.shade800,
  Colors.blue.shade900,

  // Variantes de vermelho
  Colors.red.shade50,
  Colors.red.shade100,
  Colors.red.shade200,
  Colors.red.shade300,
  Colors.red.shade400,
  Colors.red.shade500,
  Colors.red.shade600,
  Colors.red.shade700,
  Colors.red.shade800,
  Colors.red.shade900,

  // Variantes de verde
  Colors.green.shade50,
  Colors.green.shade100,
  Colors.green.shade200,
  Colors.green.shade300,
  Colors.green.shade400,
  Colors.green.shade500,
  Colors.green.shade600,
  Colors.green.shade700,
  Colors.green.shade800,
  Colors.green.shade900,

  // Variantes de amarelo
  Colors.yellow.shade50,
  Colors.yellow.shade100,
  Colors.yellow.shade200,
  Colors.yellow.shade300,
  Colors.yellow.shade400,
  Colors.yellow.shade500,
  Colors.yellow.shade600,
  Colors.yellow.shade700,
  Colors.yellow.shade800,
  Colors.yellow.shade900,

  // Variantes de marrom
  Colors.brown.shade50,
  Colors.brown.shade100,
  Colors.brown.shade200,
  Colors.brown.shade300,
  Colors.brown.shade400,
  Colors.brown.shade500,
  Colors.brown.shade600,
  Colors.brown.shade700,
  Colors.brown.shade800,
  Colors.brown.shade900,

  Color.fromARGB(255, 252, 202, 116),

];

  Color hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
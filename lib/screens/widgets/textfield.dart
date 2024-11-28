import 'package:bistro/screens/widgets/cores.dart';
import 'package:flutter/material.dart';

Widget textFormField(controller, label, keyboardType, validator) {
  return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
      keyboardType: keyboardType,
      validator: validator);
}

Widget loginTextFormField(
    controller, label, keyboardType, validator, onChanged) {
  return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: label,
      ),
      onChanged: onChanged,
      keyboardType: keyboardType,
      validator: validator);
}

InputDecoration inputDec(String label) {
  return InputDecoration(
    //prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
    labelText: label,
    labelStyle: TextStyle(color: Colors.grey.shade400),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide(
        color: Colors.grey.shade400, // Cor da borda
        width: 2.0, // Espessura da borda
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide(
        color: Colors.grey.shade400, // Cor da borda
        width: 2.0, // Espessura da borda
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide(
        color: corPadrao(), // Cor da borda quando o campo está focado
        width: 3.0, // Espessura da borda quando o campo está focado
      ),
    ),
  );
}

InputDecoration inputDecMob(String label) {
  return InputDecoration(
    //prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
    labelText: label,
    labelStyle: TextStyle(color: Colors.grey.shade600),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide(
        color: Colors.grey.shade600, // Cor da borda
        width: 2.0, // Espessura da borda
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide(
        color: Colors.grey.shade600, // Cor da borda
        width: 2.0, // Espessura da borda
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide(
        color: corPadrao(), // Cor da borda quando o campo está focado
        width: 3.0, // Espessura da borda quando o campo está focado
      ),
    ),
  );
}

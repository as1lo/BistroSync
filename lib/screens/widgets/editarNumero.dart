String formatarNumero(double numero) {
  if (numero.toString().contains('.')) {

    return numero.toString().replaceAll('.', '');
  } else {

    return '${numero}00';
  }
}
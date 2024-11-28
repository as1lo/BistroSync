import 'package:intl/intl.dart';

String formatedDouble(dynamic valor){
  NumberFormat formatoDouble = NumberFormat("#,##0.00", "pt_BR");

  return formatoDouble.format(valor);
}
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://localhost:3000";

  Future<String?> iniciarSessaoWhatsapp() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/whatsapp'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['qr'] != null) {
          String base64QR = data['qr'];
          print('QR Code base64: $base64QR');
          // Use essa base64 para exibir no app, se necessário
        } else {
          print('QR Code não retornado');
        }
      } else {
        print('Erro na requisição: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro ao criar sessão: $error');
    }
    return null;
  }

   Future<Map<String, dynamic>> cancelarAssinatura(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cancelar-assinatura'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao cancelar a assinatura: ${response.body}');
      }
    } catch (e) {
      print('Erro ao fazer requisição: $e');
      return {"error": e.toString()};
    }
  }


  Future<Map<String, dynamic>> verificarEstadoWhatsapp() async {
    final response = await http.get(Uri.parse('$baseUrl/whatsapp-status'));
    return _handleResponse(response);
  }


  Future<Map<String, dynamic>> criarPlano(
      String name, int repeats, int interval) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/criar-plano'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'name': name, 'repeats': null, 'interval': interval}),
      );
      return _handleResponse(response);
    } catch (e) {
      print('Erro ao criar o plano: $e');
      return {'error': 'Erro ao criar o plano'};
    }
  }

  
  Future<Map<String, dynamic>> deletarPlano(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/deletar-plano'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao deletar o plano: ${response.body}');
      }
    } catch (e) {
      print('Erro ao fazer requisição: $e');
      return {"error": e.toString()};
    }
  }

  
  Future<Map<String, dynamic>> listarPlanos({String? name}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/listar-planos'),
      body: name != null ? {'name': name} : {},
    );
    return _handleResponse(response);
  }

 
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Erro: ${json.decode(response.body)["error"] ?? "Falha desconhecida"}');
    }
  }
}

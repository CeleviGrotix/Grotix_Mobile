import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../common/config/api_config.dart';

class AiRemoteDatasource {
  Future<Map<String, dynamic>> analyzeCropImage(String filePath) async {
    final uri = Uri.parse('${pythonApiBase()}/api/analyze');
    final request = http.MultipartRequest('POST', uri);

    // Adjuntamos la imagen tomada por la cámara
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(responseBody);
      if (jsonResponse.containsKey('error')) {
        throw Exception(jsonResponse['error']);
      }
      return jsonResponse;
    } else {
      throw Exception('Fallo al conectar con el servidor IA. Código: ${response.statusCode}');
    }
  }
}
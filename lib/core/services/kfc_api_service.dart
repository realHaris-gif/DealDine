import 'dart:convert';
import 'package:http/http.dart' as http;

class KfcApiService {
  static const String _baseUrl =
      'http://192.168.18.25:3000/api/restaurants/kfc/menu';

  Future<List<dynamic>> fetchMenu() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to load KFC menu');
    }

    final data = jsonDecode(response.body);

    print('Status: ${response.statusCode}');
    print('Items: ${data.length}');
    print('First item: ${data.first}');

    return data;
  }
}
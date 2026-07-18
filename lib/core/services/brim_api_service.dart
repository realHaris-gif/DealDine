import 'dart:convert';
import 'package:http/http.dart' as http;

class BrimApiService {

  Future<List<dynamic>> fetchMenu() async {

    final response = await http.get(
      Uri.parse('http://192.168.18.25:3000/api/restaurants/brim/menu'),
    );

   

    final data = jsonDecode(response.body);

    return data;
  }
}
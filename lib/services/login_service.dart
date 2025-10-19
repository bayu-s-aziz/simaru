import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' show Client;

class LoginService extends GetxService {
  Client client = Client();

  Future<dynamic> login(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('http://127.0.0.1:8001/api/login'),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return throw Exception(e);
    }
  }
}

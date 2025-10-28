import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' show Client;

class LoginService extends GetxService {
  Client client = Client();

  Future<dynamic> login(String email, String password) async {
    try {
      final response = await client.post(
        // Pastikan URL API sudah benar
        Uri.parse('http://127.0.0.1:8001/api/login'),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Kembalikan body jika sukses
      } else {
        // Log error dan kembalikan null atau data error jika ada
        print('Login failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        // Coba decode body jika mungkin berisi pesan error
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return null; // Kembalikan null jika gagal decode atau tidak ada body
        }
      }
    } catch (e) {
      print('Error during login: $e');
      // Lemparkan exception untuk ditangani controller
      throw Exception('Tidak dapat terhubung ke server.');
    }
  }
}

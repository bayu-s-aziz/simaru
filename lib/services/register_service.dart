import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' show Client;

class RegisterService extends GetxService {
  Client client = Client();

  Future<dynamic> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await client.post(
        // Pastikan URL API sudah benar
        Uri.parse('http://127.0.0.1:8001/api/register'),
        body: {
          'name': name,
          'email': email,
          'password': password,
          // Pastikan nama field ini sesuai dengan yang diharapkan API
          'password_confirmation': passwordConfirmation,
        },
      );

      // Status code 201 (Created) juga umum untuk registrasi yang sukses
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body); // Kembalikan body jika sukses
      } else {
        // Log error untuk debugging
        print('Registration failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        // Coba decode body jika mungkin berisi pesan error
        try {
          return jsonDecode(response.body);
        } catch (_) {
          // Kembalikan null jika gagal decode atau tidak ada body
          return null;
        }
      }
    } catch (e) {
      // Log error atau tampilkan pesan yang lebih spesifik
      print('Error during registration: $e');
      // Lemparkan exception agar controller bisa menangani error koneksi/lainnya
      throw Exception('Tidak dapat terhubung ke server.');
    }
  }
}

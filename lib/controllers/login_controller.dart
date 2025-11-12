import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simaru/services/login_service.dart';

class LoginController extends GetxController {
  // Gunakan Get.find() karena service didaftarkan di LoginBinding
  final LoginService _service = Get.find<LoginService>();

  var isLoading = false.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Email dan Password harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Error',
        'Format email tidak valid',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final Map<String, dynamic>? response = await _service.login(
        email,
        password,
      );

      // Pastikan response tidak null DAN ada access token
      if (response != null && response['accessToken'] != null) {
        debugPrint('LoginController raw response: $response');
        final userName = _extractUserName(response) ?? 'Pengguna';
        final userProfile = _extractUserProfile(response);

        debugPrint('LoginController resolved userName: $userName');

        Get.snackbar(
          'Sukses',
          'Login berhasil!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        final navigationPayload = Map<String, dynamic>.from(response);
        navigationPayload['name'] = userName;
        if (userProfile != null && userProfile.isNotEmpty) {
          navigationPayload['user'] = userProfile;
        }

        Get.offAllNamed('/home', arguments: navigationPayload);
      } else {
        // Ambil pesan error dari API jika ada, atau gunakan pesan default
        String errorMessage =
            response?['message'] ?? 'Email atau password salah.';
        Get.snackbar(
          'Gagal',
          errorMessage,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e is Exception
            ? e.toString().replaceFirst('Exception: ', '')
            : 'Terjadi kesalahan tidak diketahui',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  String? _extractUserName(dynamic payload) {
    if (payload == null) {
      return null;
    }

    if (payload is String) {
      final trimmed = payload.trim();
      return trimmed.isNotEmpty ? trimmed : null;
    }

    if (payload is Iterable) {
      for (final element in payload) {
        final candidate = _extractUserName(element);
        if (candidate != null && candidate.isNotEmpty) {
          return candidate;
        }
      }
      return null;
    }

    if (payload is Map) {
      for (final entry in payload.entries) {
        final keyString = entry.key.toString().toLowerCase();
        final value = entry.value;

        if (value is String) {
          if ((keyString.contains('name') || keyString.contains('nama')) &&
              value.trim().isNotEmpty) {
            return value.trim();
          }
        }
      }

      for (final value in payload.values) {
        if (value is Map || value is Iterable) {
          final nestedResult = _extractUserName(value);
          if (nestedResult != null && nestedResult.isNotEmpty) {
            return nestedResult;
          }
        }
      }
    }

    return null;
  }

  Map<String, dynamic>? _extractUserProfile(Map<String, dynamic> payload) {
    final dynamic direct =
        payload['user'] ??
        payload['profile'] ??
        payload['data'] ??
        payload['account'];
    if (direct is Map<String, dynamic>) {
      return direct;
    }
    if (direct is Map) {
      return Map<String, dynamic>.from(direct);
    }

    final collected = <String, dynamic>{};
    for (final entry in payload.entries) {
      final keyString = entry.key.toString().toLowerCase();
      if (entry.value is String &&
          (keyString.contains('name') ||
              keyString.contains('nama') ||
              keyString.contains('email'))) {
        collected[entry.key.toString()] = entry.value;
      }
    }

    if (collected.isNotEmpty) {
      return collected;
    }

    for (final value in payload.values) {
      if (value is Map<String, dynamic>) {
        final nested = _extractUserProfile(value);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      } else if (value is Map) {
        final nested = _extractUserProfile(Map<String, dynamic>.from(value));
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }

    return null;
  }
}

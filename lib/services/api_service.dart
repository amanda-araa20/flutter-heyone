import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:9000/api";

  // ==============================
  // AUTHENTICATED GET REQUEST
  // ==============================
  static Future<http.Response> authGet(String endpoint) async {
    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: await authHeader(),
    );

    if (response.statusCode == 401) {
      await clearToken();
      throw Exception("Session expired. Silakan login kembali.");
    }

    return response;
  }

  // ==============================
  // GET TRANSAKSI BOOKED HARI INI
  // ==============================
  static Future<List<dynamic>> getTodayBookedTransactions() async {
    final today = DateTime.now().toIso8601String().split('T').first;

    final response = await http.get(
      Uri.parse(
        "$baseUrl/mobile/medical-transactions?status=BOOKED&date=$today",
      ),
      headers: await authHeader(),
    );

    if (response.statusCode == 401) {
      await clearToken();
      throw Exception("Session expired. Silakan login kembali.");
    }
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? [];
    } else {
      throw Exception("Failed to load transactions: ${response.body}");
    }
  }

  // ==============================
  // UPDATE TRANSAKSI → UNPAID
  // ==============================
  static Future<void> updateTransaction(
    int id,
    String tindakan,
    String harga,
  ) async {
    final response = await http.put(
      Uri.parse("$baseUrl/mobile/medical-transactions/$id"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "treatment": tindakan,
        "price":
            double.tryParse(harga.replaceAll(".", "").replaceAll(",", "")) ?? 0,
        "status": "UNPAID",
        "doctor_completed_at": DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 401) {
      await clearToken();
      throw Exception("Session expired. Silakan login kembali.");
    }
    if (response.statusCode != 200) {
      throw Exception("Failed to update transaction: ${response.body}");
    }
  }

  // ==============================
  // TOKEN HANDLING
  // ==============================
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('doctor_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('doctor_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('doctor_token');
  }

  // ==============================
  // LOGIN DOCTOR
  // ==============================
  static Future<Map<String, dynamic>> loginDoctor(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/doctor/login"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"email": email, "password": password}),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await saveToken(decoded['token']);
      return decoded;
    } else {
      throw Exception(decoded['message'] ?? "Login gagal");
    }
  }

  // ==============================
  // REGISTER DOCTOR
  // ==============================
  static Future<Map<String, dynamic>> registerDoctor(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/doctor/register"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 201) {
      await saveToken(decoded['token']);
      return decoded;
    } else {
      throw Exception(decoded['errors']?.toString() ?? "Register gagal");
    }
  }

  static Future<Map<String, String>> authHeader() async {
    String? token = await getToken();

    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // ==============================
  // GET DOCTOR PROFILE
  // ==============================
  static Future<Map<String, dynamic>> getDoctorProfile() async {
    final response = await authGet("/doctor/me");

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['doctor'];
    } else {
      throw Exception("Failed to load doctor profile");
    }
  }

  // ==============================
  // UPDATE DOCTOR PROFILE
  // ==============================
  // static Future<void> updateDoctorProfile(Map<String, dynamic> data) async {
  //   final response = await http.post(
  //     Uri.parse("$baseUrl/doctor/profile"),
  //     headers: await authHeader(),
  //     body: jsonEncode(data),
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception("Gagal update profil");
  //   }
  // }

  // ==============================
  // UPDATE DOCTOR PHOTO & PROFILE
  // ==============================
  static Future<void> updateDoctorProfileWithImage(
    Map<String, String> data,
    File? image,
  ) async {
    final token = await getToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/doctor/profile"),
    );

    request.headers['Authorization'] = "Bearer $token";

    request.fields.addAll(data);

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', image.path));
    }

    var response = await request.send();

    if (response.statusCode == 401) {
      await clearToken();
      throw Exception("Session expired. Silakan login kembali.");
    }
    if (response.statusCode != 200) {
      throw Exception("Gagal update profile");
    }
  }
}

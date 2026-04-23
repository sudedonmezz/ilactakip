import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5182/api';

static Future<void> registerUser({
  required String fullName,
  required String email,
  required String password,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/users'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "fullName": fullName,
      "email": email,
      "password": password
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    return;
  } else {
    final data = jsonDecode(response.body);
    throw Exception(data["message"] ?? "Kayıt başarısız");
  }
}

  static Future<Map<String, dynamic>> loginUser({
  required String email,
  required String password,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/users/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "email": email,
      "password": password,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Email veya şifre hatalı');
  }
}


static Future<Map<String, dynamic>> updateProfile({
  required int userId,
  int? age,
  String? gender,
  double? weight,
  double? height,
  String? chronicDisease,
}) async {
  final response = await http.patch(
    Uri.parse('$baseUrl/users/$userId/profile'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "age": age,
      "gender": gender,
      "weight": weight,
      "height": height,
      "chronicDisease": chronicDisease,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    final data = jsonDecode(response.body);
    throw data["message"] ?? "Profil güncellenemedi";
  }
}
}
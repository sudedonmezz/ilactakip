import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://172.20.10.3:5142/api';

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
static Future<Map<String, dynamic>> getUser(int userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/users/$userId'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Kullanıcı bilgileri alınamadı");
  }
}

static Future<Map<String, dynamic>> updateUser({
  required int userId,
  required String fullName,
  required int age,
  required String gender,
  required double weight,
  required double height,
  required String chronicDisease,
  required String email,
  required String password,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/users/$userId'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "fullName": fullName,
      "age": age,
      "gender": gender,
      "weight": weight,
      "height": height,
      "chronicDisease": chronicDisease,
      "email": email,
      "password": password,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  final data = jsonDecode(response.body);
  throw data["message"] ?? "Profil güncellenemedi";
}

static Future<List<dynamic>> getMedications(int userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/medications/user/$userId'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw "İlaçlar alınamadı";
}

static Future<void> addMedication({
  required int userId,
  required String name,
  required String dosage,
  required String type,
  required String notes,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/medications'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "userId": userId,
      "name": name,
      "dosage": dosage,
      "type": type,
      "notes": notes,
    }),
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    final data = jsonDecode(response.body);
    throw data["message"] ?? "İlaç eklenemedi";
  }
}

static Future<void> deleteMedication(int medicationId) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/medications/$medicationId'),
  );

  if (response.statusCode != 200) {
    throw "İlaç silinemedi";
  }
}

static Future<List<dynamic>> getReminders(int userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/reminders/user/$userId'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw "Hatırlatmalar alınamadı\nStatus: ${response.statusCode}\nBody: ${response.body}";
}

static Future<void> addReminder({
  required int medicationId,
  required int hour,
  required int minute,
  required String frequencyType,
  required String startDate,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/reminders'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "medicationId": medicationId,
      "hour": hour,
      "minute": minute,
      "frequencyType": frequencyType,
      "startDate": startDate,
    }),
  );

  if (response.statusCode != 200) {
    final data = jsonDecode(response.body);
    throw data["message"] ?? "Hatırlatma eklenemedi";
  }
}

static Future<void> deleteReminder(int id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/reminders/$id'),
  );

  if (response.statusCode != 200) {
    throw "Hatırlatma silinemedi";
  }
}
}
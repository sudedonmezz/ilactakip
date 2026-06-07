import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class ApiService {
  //static const String baseUrl = 'http://localhost:5142/api';
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

static Future<void> markMedicationAsTaken({
  required int medicationId,
  required DateTime scheduledDateTime,
  String? note,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/medicationlogs/taken'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "medicationId": medicationId,
      "scheduledDateTime": scheduledDateTime.toIso8601String(),
      "note": note,
    }),
  );

  if (response.statusCode != 200) {
    final data = jsonDecode(response.body);
    throw Exception(data["message"] ?? "İlaç alındı olarak işaretlenemedi");
  }
}

static Future<List<dynamic>> getMedicationLogs(int userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/medicationlogs/user/$userId'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception("İlaç geçmişi alınamadı");
}

static Future<List<dynamic>> getGlucoseMeasurements(int userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/glucosemeasurements/user/$userId'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception("Kan şekeri ölçümleri alınamadı");
}

static Future<void> addGlucoseMeasurement({
  required int userId,
  required double value,
  required String measurementType,
  required DateTime measurementTime,
  String? note,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/glucosemeasurements'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "userId": userId,
      "value": value,
      "measurementType": measurementType,
      "measurementTime": measurementTime.toIso8601String(),
      "note": note,
    }),
  );

  if (response.statusCode != 200) {
    final data = jsonDecode(response.body);
    throw Exception(data["message"] ?? "Kan şekeri ölçümü eklenemedi");
  }
}

static Future<void> deleteGlucoseMeasurement(int id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/glucosemeasurements/$id'),
  );

  if (response.statusCode != 200) {
    throw Exception("Kan şekeri ölçümü silinemedi");
  }
}

static Future<List<dynamic>> getTreatments(int userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/treatments/user/$userId'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception("Tedavi kayıtları alınamadı");
}

static Future<void> addTreatment({
  required int userId,
  required String treatmentType,
  required String name,
  double? dose,
  String? unit,
  required DateTime takenTime,
  String? note,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/treatments'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "userId": userId,
      "treatmentType": treatmentType,
      "name": name,
      "dose": dose,
      "unit": unit,
      "takenTime": takenTime.toIso8601String(),
      "note": note,
    }),
  );

  if (response.statusCode != 200) {
    final data = jsonDecode(response.body);
    throw Exception(data["message"] ?? "Tedavi kaydı eklenemedi");
  }
}

static Future<void> deleteTreatment(int id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/treatments/$id'),
  );

  if (response.statusCode != 200) {
    throw Exception("Tedavi kaydı silinemedi");
  }
}

static Future<List<dynamic>> getBloodPressureMeasurements(int userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/bloodpressuremeasurements/user/$userId'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception("Tansiyon ölçümleri alınamadı");
}

static Future<void> addBloodPressureMeasurement({
  required int userId,
  required int systolic,
  required int diastolic,
  int? pulse,
  required DateTime measurementTime,
  String? note,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/bloodpressuremeasurements'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "userid": userId,
      "systolic": systolic,
      "diastolic": diastolic,
      "pulse": pulse,
      "measurementtime": measurementTime.toIso8601String(),
      "note": note,
    }),
  );

  if (response.statusCode != 200) {
    final data = jsonDecode(response.body);
    throw Exception(data["message"] ?? "Tansiyon ölçümü eklenemedi");
  }
}

static Future<void> deleteBloodPressureMeasurement(int id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/bloodpressuremeasurements/$id'),
  );

  if (response.statusCode != 200) {
    throw Exception("Tansiyon ölçümü silinemedi");
  }
}

static Future<void> sendVerificationCode({
  required String fullName,
  required String email,
  required String password,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/emailverification/send-code'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "fullname": fullName,
      "email": email,
      "password": password,
    }),
  );

  if (response.statusCode != 200) {
    final data = jsonDecode(response.body);
    throw Exception(data["message"] ?? "Doğrulama kodu gönderilemedi");
  }
}

static Future<Map<String, dynamic>> verifyEmailCode({
  required String email,
  required String code,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/emailverification/verify-code'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "email": email,
      "code": code,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  final data = jsonDecode(response.body);
  throw Exception(data["message"] ?? "Doğrulama başarısız");
}

static Future<Map<String, dynamic>> googleLogin() async {
  await GoogleSignIn.instance.initialize(
    clientId:
        "364205146103-206mismcq5lhrgfu3sl7qbsq2olasls4.apps.googleusercontent.com",
  );

  final GoogleSignInAccount account =
      await GoogleSignIn.instance.authenticate();

  final GoogleSignInAuthentication auth =
      account.authentication;

  final String? idToken = auth.idToken;

  if (idToken == null) {
    throw Exception("Google token alınamadı.");
  }

  final response = await http.post(
    Uri.parse('$baseUrl/auth/google'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "idToken": idToken,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception(
    "Google ile giriş başarısız. ${response.body}",
  );
}

static Future<void> sendPasswordResetCode({
  required String email,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/passwordreset/send-code'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "email": email,
    }),
  );

  if (response.statusCode != 200) {
    final data = jsonDecode(response.body);
    throw Exception(data["message"] ?? "Kod gönderilemedi");
  }
}

static Future<void> verifyPasswordResetCode({
  required String email,
  required String code,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/passwordreset/verify-code'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "email": email,
      "code": code,
    }),
  );

  if (response.statusCode != 200) {
    final data = jsonDecode(response.body);
    throw Exception(data["message"] ?? "Kod doğrulanamadı");
  }
}

static Future<void> changePasswordWithCode({
  required String email,
  required String code,
  required String newPassword,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/passwordreset/change-password'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "email": email,
      "code": code,
      "newPassword": newPassword,
    }),
  );

  if (response.statusCode != 200) {
    final data = jsonDecode(response.body);
    throw Exception(data["message"] ?? "Şifre güncellenemedi");
  }
}


}
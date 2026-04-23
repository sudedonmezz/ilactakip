import 'package:flutter/material.dart';
import '../services/api_services.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController fullNameController;
  late TextEditingController ageController;
  late TextEditingController weightController;
  late TextEditingController heightController;
  late TextEditingController chronicDiseaseController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  String selectedGender = "Kadın";

  dynamic getField(String lower, String upper) {
    return widget.user[lower] ?? widget.user[upper];
  }

  @override
  void initState() {
    super.initState();

    fullNameController = TextEditingController(
      text: getField("fullname", "Fullname")?.toString() ?? "",
    );
    ageController = TextEditingController(
      text: getField("age", "Age")?.toString() ?? "",
    );
    weightController = TextEditingController(
      text: getField("weight", "Weight")?.toString() ?? "",
    );
    heightController = TextEditingController(
      text: getField("height", "Height")?.toString() ?? "",
    );
    chronicDiseaseController = TextEditingController(
      text: getField("chronicDisease", "ChronicDisease")?.toString() ?? "",
    );
    emailController = TextEditingController(
      text: getField("email", "Email")?.toString() ?? "",
    );
    passwordController = TextEditingController(
      text: getField("password", "Password")?.toString() ?? "",
    );

    final gender = getField("gender", "Gender")?.toString();
    if (gender == "Kadın" || gender == "Erkek" || gender == "Diğer") {
      selectedGender = gender!;
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    chronicDiseaseController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    if (fullNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        ageController.text.trim().isEmpty ||
        weightController.text.trim().isEmpty ||
        heightController.text.trim().isEmpty) {
      showMessage("Hata", "Lütfen zorunlu alanları doldurun.");
      return;
    }

    try {
      final updatedUser = await ApiService.updateUser(
        userId: getField("id", "Id"),
        fullName: fullNameController.text.trim(),
        age: int.parse(ageController.text.trim()),
        gender: selectedGender,
        weight: double.parse(weightController.text.trim()),
        height: double.parse(heightController.text.trim()),
        chronicDisease: chronicDiseaseController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context, updatedUser);
    } catch (e) {
      var message = e.toString();
      if (message.startsWith("Exception: ")) {
        message = message.replaceFirst("Exception: ", "");
      }
      showMessage("Hata", message);
    }
  }

  void showMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.teal),
      prefixIcon: Icon(icon, color: Colors.teal),
      filled: true,
      fillColor: Colors.teal.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Profili Düzenle"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: fullNameController,
              decoration: inputDecoration("Ad Soyad", Icons.person),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailController,
              decoration: inputDecoration("Email", Icons.email),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: inputDecoration("Şifre", Icons.lock),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: inputDecoration("Yaş", Icons.cake),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: inputDecoration("Cinsiyet", Icons.person_outline),
              items: const [
                DropdownMenuItem(value: "Kadın", child: Text("Kadın")),
                DropdownMenuItem(value: "Erkek", child: Text("Erkek")),
                DropdownMenuItem(value: "Diğer", child: Text("Diğer")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedGender = value!;
                });
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: inputDecoration("Kilo", Icons.monitor_weight),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: inputDecoration("Boy", Icons.height),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: chronicDiseaseController,
              decoration: inputDecoration(
                "Kronik Hastalık",
                Icons.medical_information,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Kaydet",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
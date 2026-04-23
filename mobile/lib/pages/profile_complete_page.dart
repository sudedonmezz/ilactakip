import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'home_page.dart';

class ProfileCompletePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ProfileCompletePage({
    super.key,
    required this.user,
  });

  @override
  State<ProfileCompletePage> createState() => _ProfileCompletePageState();
}

class _ProfileCompletePageState extends State<ProfileCompletePage> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController chronicDiseaseController =
      TextEditingController();

  String selectedGender = "Kadın";

  @override
  void dispose() {
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    chronicDiseaseController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    if (ageController.text.isEmpty ||
        weightController.text.isEmpty ||
        heightController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Eksik Bilgi"),
          content: Text("Lütfen yaş, kilo ve boy bilgilerini doldurun."),
        ),
      );
      return;
    }

    try {
      final updatedUser = await ApiService.updateProfile(
        userId: widget.user["id"],
        age: int.parse(ageController.text),
        gender: selectedGender,
        weight: double.parse(weightController.text),
        height: double.parse(heightController.text),
        chronicDisease: chronicDiseaseController.text.trim().isEmpty
            ? null
            : chronicDiseaseController.text.trim(),
      );

      if (!mounted) return;

    Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => HomePage(
      userId: updatedUser["id"] ?? updatedUser["Id"],
    ),
  ),
);
    } catch (e) {
      String message = e.toString();
      if (message.startsWith("Exception: ")) {
        message = message.replaceFirst("Exception: ", "");
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Hata"),
          content: Text(message),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.health_and_safety,
                      size: 46,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Profil Bilgileri",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Sağlık takibi için bilgilerinizi tamamlayın",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 28),

                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    cursorColor: Colors.teal,
                    decoration: _inputDecoration(
                      label: "Yaş",
                      icon: Icons.cake,
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: selectedGender,
                    decoration: _inputDecoration(
                      label: "Cinsiyet",
                      icon: Icons.person,
                    ),
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
                  const SizedBox(height: 16),

                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    cursorColor: Colors.teal,
                    decoration: _inputDecoration(
                      label: "Kilo",
                      icon: Icons.monitor_weight,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    cursorColor: Colors.teal,
                    decoration: _inputDecoration(
                      label: "Boy",
                      icon: Icons.height,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: chronicDiseaseController,
                    cursorColor: Colors.teal,
                    decoration: _inputDecoration(
                      label: "Kronik Hastalık",
                      icon: Icons.medical_information,
                    ),
                  ),
                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Kaydet ve Devam Et",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
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
        borderSide: const BorderSide(
          color: Colors.teal,
          width: 2,
        ),
      ),
    );
  }
}
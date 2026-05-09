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
  bool isSaving = false;

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

    final age = int.tryParse(ageController.text.trim());
    final weight = double.tryParse(weightController.text.trim());
    final height = double.tryParse(heightController.text.trim());

    if (age == null || weight == null || height == null) {
      showMessage("Hata", "Yaş, kilo ve boy alanları sayısal olmalıdır.");
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final updatedUser = await ApiService.updateUser(
        userId: getField("id", "Id"),
        fullName: fullNameController.text.trim(),
        age: age,
        gender: selectedGender,
        weight: weight,
        height: height,
        chronicDisease: chronicDiseaseController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      Navigator.pop(context, updatedUser);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
    );
  }

  Widget headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.teal, Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.manage_accounts,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Profili Düzenle",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Hesap ve sağlık bilgilerinizi güncelleyin",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget accountInfoCard() {
    return whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle("Hesap Bilgileri", Icons.person),
          TextField(
            controller: fullNameController,
            textInputAction: TextInputAction.next,
            decoration: inputDecoration("Ad Soyad", Icons.person),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: inputDecoration("Email", Icons.email),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: inputDecoration("Şifre", Icons.lock),
          ),
        ],
      ),
    );
  }

  Widget healthInfoCard() {
    return whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle("Sağlık Bilgileri", Icons.health_and_safety),
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
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
            textInputAction: TextInputAction.next,
            decoration: inputDecoration("Kilo", Icons.monitor_weight),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: heightController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: inputDecoration("Boy", Icons.height),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: chronicDiseaseController,
            maxLines: 2,
            decoration: inputDecoration(
              "Kronik Hastalık",
              Icons.medical_information,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.teal),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Ad soyad, email, şifre, yaş, kilo ve boy alanları zorunludur.",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: isSaving ? null : saveChanges,
        icon: isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle_outline),
        label: Text(
          isSaving ? "Kaydediliyor..." : "Değişiklikleri Kaydet",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          disabledBackgroundColor: Colors.teal.shade200,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
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
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            headerCard(),
            const SizedBox(height: 20),
            accountInfoCard(),
            const SizedBox(height: 16),
            healthInfoCard(),
            const SizedBox(height: 16),
            infoBox(),
            const SizedBox(height: 24),
            saveButton(),
          ],
        ),
      ),
    );
  }
}
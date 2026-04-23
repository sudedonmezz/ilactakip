import 'package:flutter/material.dart';
import '../services/api_services.dart';

class AddMedicationPage extends StatefulWidget {
  final int userId;

  const AddMedicationPage({super.key, required this.userId});
  
  

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();


  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    typeController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> saveMedication() async {
  
    if (nameController.text.trim().isEmpty) {
      showMessage("Hata", "İlaç adı boş olamaz.");
      return;
    }

    try {
      await ApiService.addMedication(
        userId: widget.userId,
        name: nameController.text.trim(),
        dosage: dosageController.text.trim(),
        type: typeController.text.trim(),
        notes: notesController.text.trim(),
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Başarılı"),
          content: const Text("İlaç başarıyla eklendi."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text("Tamam"),
            ),
          ],
        ),
      );
    } catch (e) {
      showMessage("Hata", e.toString());
    }
  }

  void showMessage(String title, String message) {
    if (message.startsWith("Exception: ")) {
      message = message.replaceFirst("Exception: ", "");
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
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
        title: const Text("İlaç Ekle"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: inputDecoration("İlaç Adı", Icons.medication),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: dosageController,
              decoration: inputDecoration("Doz", Icons.science),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: typeController,
              decoration: inputDecoration("Tür", Icons.category),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: inputDecoration("Not", Icons.note),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: saveMedication,
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
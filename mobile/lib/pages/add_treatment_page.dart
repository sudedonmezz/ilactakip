import 'package:flutter/material.dart';
import '../services/api_services.dart';

class AddTreatmentPage extends StatefulWidget {
  final int userId;

  const AddTreatmentPage({super.key, required this.userId});

  @override
  State<AddTreatmentPage> createState() => _AddTreatmentPageState();
}

class _AddTreatmentPageState extends State<AddTreatmentPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController doseController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String treatmentType = "İnsülin";
  DateTime takenTime = DateTime.now();
  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    doseController.dispose();
    unitController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> saveTreatment() async {
    if (nameController.text.trim().isEmpty) {
      showMessage("Hata", "Ad alanı boş olamaz.");
      return;
    }

    final doseText = doseController.text.trim().replaceAll(",", ".");
    final dose = doseText.isEmpty ? null : double.tryParse(doseText);

    if (doseText.isNotEmpty && dose == null) {
      showMessage("Hata", "Geçerli bir doz girin.");
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await ApiService.addTreatment(
        userId: widget.userId,
        treatmentType: treatmentType,
        name: nameController.text.trim(),
        dose: dose,
        unit: unitController.text.trim().isEmpty
            ? null
            : unitController.text.trim(),
        takenTime: takenTime,
        note: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  Future<void> pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: takenTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;
    if (!mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(takenTime),
    );

    if (pickedTime == null) return;

    setState(() {
      takenTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  String formatDateTime(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  IconData treatmentIcon(String type) {
    if (type == "İnsülin") return Icons.vaccines;
    if (type == "İlaç") return Icons.medication;
    if (type == "Besin") return Icons.restaurant;
    if (type == "Egzersiz") return Icons.directions_walk;
    return Icons.healing;
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
            child: Icon(
              treatmentIcon(treatmentType),
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
                  "Tedavi / Müdahale",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "İnsülin, ilaç, besin veya egzersiz kaydı ekleyin",
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

  Widget dateTimeSelector() {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: pickDateTime,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.teal.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.event,
                color: Colors.teal,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Zaman",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatDateTime(takenTime),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, color: Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget formCard() {
    return whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle("Kayıt Bilgileri", Icons.healing),
          DropdownButtonFormField<String>(
            value: treatmentType,
            decoration: inputDecoration("Tür", Icons.category),
            items: const [
              DropdownMenuItem(value: "İnsülin", child: Text("İnsülin")),
              DropdownMenuItem(value: "İlaç", child: Text("İlaç")),
              DropdownMenuItem(value: "Besin", child: Text("Besin")),
              DropdownMenuItem(value: "Egzersiz", child: Text("Egzersiz")),
            ],
            onChanged: (value) {
              setState(() {
                treatmentType = value!;
              });
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            decoration: inputDecoration(
              "Ad",
              treatmentIcon(treatmentType),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: doseController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: inputDecoration("Doz", Icons.numbers),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: unitController,
                  textInputAction: TextInputAction.next,
                  decoration: inputDecoration("Birim", Icons.straighten),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          dateTimeSelector(),
          const SizedBox(height: 14),
          TextField(
            controller: noteController,
            maxLines: 3,
            decoration: inputDecoration("Not", Icons.note_alt_outlined),
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
        onPressed: isSaving ? null : saveTreatment,
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
          isSaving ? "Kaydediliyor..." : "Kaydı Kaydet",
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
        title: const Text("Tedavi Ekle"),
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
            formCard(),
            const SizedBox(height: 24),
            saveButton(),
          ],
        ),
      ),
    );
  }
}
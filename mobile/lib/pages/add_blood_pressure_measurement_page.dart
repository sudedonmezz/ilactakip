import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../services/notification_service.dart';

class AddBloodPressureMeasurementPage extends StatefulWidget {
  final int userId;

  const AddBloodPressureMeasurementPage({
    super.key,
    required this.userId,
  });

  @override
  State<AddBloodPressureMeasurementPage> createState() =>
      _AddBloodPressureMeasurementPageState();
}

class _AddBloodPressureMeasurementPageState
    extends State<AddBloodPressureMeasurementPage> {
  final TextEditingController systolicController = TextEditingController();
  final TextEditingController diastolicController = TextEditingController();
  final TextEditingController pulseController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  DateTime measurementTime = DateTime.now();
  bool isSaving = false;

  @override
  void dispose() {
    systolicController.dispose();
    diastolicController.dispose();
    pulseController.dispose();
    noteController.dispose();
    super.dispose();
  }

 String bloodPressureStatus(int systolic, int diastolic) {
  if (systolic >= 180 || diastolic >= 120) {
    return "Emergency";
  }

  if (systolic >= 140 || diastolic >= 90) {
    return "High";
  }

  if (systolic >= 130 || diastolic >= 80) {
    return "Risk";
  }

  if (systolic >= 120 && diastolic < 80) {
    return "Elevated";
  }

  if (systolic < 90 || diastolic < 60) {
    return "Low";
  }

  return "Normal";
}

  Future<void> handleBloodPressureAlert(int systolic, int diastolic) async {
    final status = bloodPressureStatus(systolic, diastolic);

    if (status == "Normal") {
      await NotificationService.cancelNotification(900002);
      return;
    }

    final reminderTime = DateTime.now().add(
      const Duration(minutes: 1),
    );

    const notificationId = 900002;

    await NotificationService.cancelNotification(notificationId);
if (status == "Emergency") {
  await NotificationService.scheduleGlucoseWarningNotification(
    id: notificationId,
    title: "Acil tansiyon uyarısı",
    body:
        "Tansiyonunuz çok yüksek görünüyor. Dinlenin, tekrar ölçün ve gerekirse acil sağlık desteği alın.",
    dateTime: reminderTime,
  ); }
   else if (status == "Risk" || status == "Elevated") {
  await NotificationService.scheduleGlucoseWarningNotification(
    id: notificationId,
    title: "Tansiyonunuzu tekrar ölçün",
    body:
        "Tansiyonunuz riskli aralıkta görünüyor. Dinlenin ve tekrar ölçüm yapın.",
    dateTime: reminderTime,
  );
  }
    else if (status == "High") {
      await NotificationService.scheduleGlucoseWarningNotification(
        id: notificationId,
        title: "Tansiyonunuzu tekrar ölçün",
        body:
            "Tansiyonunuz yüksek görünüyordu. Dinlenin ve tekrar ölçüm yapın.",
        dateTime: reminderTime,
      );
    } else if (status == "Low") {
      await NotificationService.scheduleGlucoseWarningNotification(
        id: notificationId,
        title: "Tansiyonunuzu tekrar ölçün",
        body:
            "Tansiyonunuz düşük görünüyordu. Sıvı alın ve tekrar ölçüm yapın.",
        dateTime: reminderTime,
      );
    }
  }

  Future<void> saveMeasurement() async {
    final systolic = int.tryParse(systolicController.text.trim());
    final diastolic = int.tryParse(diastolicController.text.trim());
    final pulse = pulseController.text.trim().isEmpty
        ? null
        : int.tryParse(pulseController.text.trim());

    if (systolic == null || systolic <= 0) {
      showMessage("Hata", "Geçerli bir büyük tansiyon değeri girin.");
      return;
    }

    if (diastolic == null || diastolic <= 0) {
      showMessage("Hata", "Geçerli bir küçük tansiyon değeri girin.");
      return;
    }

    if (pulseController.text.trim().isNotEmpty && pulse == null) {
      showMessage("Hata", "Geçerli bir nabız değeri girin.");
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await ApiService.addBloodPressureMeasurement(
        userId: widget.userId,
        systolic: systolic,
        diastolic: diastolic,
        pulse: pulse,
        measurementTime: measurementTime,
        note: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
      );

      await handleBloodPressureAlert(systolic, diastolic);

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
      initialDate: measurementTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;
    if (!mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(measurementTime),
    );

    if (pickedTime == null) return;

    setState(() {
      measurementTime = DateTime(
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
              Icons.favorite,
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
                  "Tansiyon Ölçümü",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Büyük, küçük tansiyon ve nabız değerlerinizi kaydedin",
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
                    "Ölçüm zamanı",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatDateTime(measurementTime),
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
          sectionTitle("Ölçüm Bilgileri", Icons.favorite),
          TextField(
            controller: systolicController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: inputDecoration(
              "Büyük Tansiyon",
              Icons.arrow_upward,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: diastolicController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: inputDecoration(
              "Küçük Tansiyon",
              Icons.arrow_downward,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: pulseController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: inputDecoration(
              "Nabız",
              Icons.monitor_heart,
            ),
          ),
          const SizedBox(height: 14),
          dateTimeSelector(),
          const SizedBox(height: 14),
          TextField(
            controller: noteController,
            maxLines: 3,
            decoration: inputDecoration(
              "Not",
              Icons.note_alt_outlined,
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
        onPressed: isSaving ? null : saveMeasurement,
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
          isSaving ? "Kaydediliyor..." : "Ölçümü Kaydet",
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
        title: const Text("Tansiyon Ekle"),
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
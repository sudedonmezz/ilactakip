import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../services/notification_service.dart';

class AddReminderPage extends StatefulWidget {
  final int userId;

  const AddReminderPage({super.key, required this.userId});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  List medications = [];
  bool isLoading = true;

  int? selectedMedicationId;
  String selectedMedicationName = "";
  String selectedMedicationNote = "";

  TimeOfDay selectedTime = TimeOfDay.now();
  List<TimeOfDay> selectedTimes = [];

  String frequency = "Daily";

  @override
  void initState() {
    super.initState();
    fetchMedications();
  }

  Future<void> fetchMedications() async {
    try {
      final data = await ApiService.getMedications(widget.userId);

      if (!mounted) return;

      setState(() {
        medications = data;
        isLoading = false;

        if (medications.isNotEmpty) {
          final first = medications.first;
          selectedMedicationId = first["id"] ?? first["Id"];
          selectedMedicationName = first["name"] ?? first["Name"] ?? "";
          selectedMedicationNote = first["notes"] ?? first["Notes"] ?? "";
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage("Hata", e.toString());
    }
  }

Future<void> save() async {
  if (selectedMedicationId == null) {
    showMessage("Hata", "Lütfen bir ilaç seçin.");
    return;
  }

  final List<TimeOfDay> timesToSave =
      frequency == "Multiple" ? selectedTimes : [selectedTime];

  if (timesToSave.isEmpty) {
    showMessage("Hata", "Lütfen en az bir saat seçin.");
    return;
  }

  try {
    for (final time in timesToSave) {
      final String frequencyToSave =
          frequency == "Multiple" ? "Daily" : frequency;

      final String note = selectedMedicationNote.trim();

      final String notificationBody = note.isEmpty
          ? "$selectedMedicationName alma zamanı"
          : "$selectedMedicationName alma zamanı\nNot: $note";

      await ApiService.addReminder(
        medicationId: selectedMedicationId!,
        hour: time.hour,
        minute: time.minute,
        frequencyType: frequencyToSave,
        startDate: DateTime.now().toIso8601String().split("T").first,
      );

      final notificationId =
          selectedMedicationId! * 10000 + time.hour * 100 + time.minute;

      if (frequencyToSave == "Daily") {
        await NotificationService.scheduleDailyNotification(
          id: notificationId,
          title: "İlaç zamanı",
          body: notificationBody,
          hour: time.hour,
          minute: time.minute,
          userId: widget.userId,
        );
      } else if (frequencyToSave == "Weekly") {
        await NotificationService.scheduleWeeklyNotification(
          id: notificationId,
          title: "İlaç zamanı",
          body: notificationBody,
          hour: time.hour,
          minute: time.minute,
          userId: widget.userId,
        );
      } else if (frequencyToSave == "Once") {
        await NotificationService.scheduleOnceNotification(
          id: notificationId,
          title: "İlaç zamanı",
          body: notificationBody,
          hour: time.hour,
          minute: time.minute,
          userId: widget.userId,
        );
      }
    }

    if (!mounted) return;
    Navigator.pop(context, true);
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  String getMedicationName(dynamic med) {
    return med["name"] ?? med["Name"] ?? "İsimsiz ilaç";
  }

  int getMedicationId(dynamic med) {
    return med["id"] ?? med["Id"];
  }

  String frequencyText(String value) {
    if (value == "Daily") return "Her gün";
    if (value == "Weekly") return "Haftalık";
    if (value == "Once") return "Tek seferlik";
    if (value == "Multiple") return "Günde birkaç kez";
    return value;
  }

  String helperText() {
    if (frequency == "Daily") {
      return "Bu hatırlatma her gün seçtiğiniz saatte bildirim gönderir.";
    }
    if (frequency == "Weekly") {
      return "Bu hatırlatma her hafta bugün, seçtiğiniz saatte bildirim gönderir.";
    }
    if (frequency == "Once") {
      return "Bu hatırlatma yalnızca bir kez bildirim gönderir.";
    }
    if (frequency == "Multiple") {
      return "Birden fazla saat ekleyerek gün içinde birkaç kez bildirim alabilirsiniz.";
    }
    return "";
  }

  IconData frequencyIcon(String value) {
    if (value == "Daily") return Icons.today;
    if (value == "Weekly") return Icons.calendar_month;
    if (value == "Once") return Icons.event_available;
    if (value == "Multiple") return Icons.add_alarm;
    return Icons.notifications_active;
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

  Future<void> pickSingleTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> addMultipleTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final alreadyExists = selectedTimes.any(
        (time) => time.hour == picked.hour && time.minute == picked.minute,
      );

      if (!alreadyExists) {
        setState(() {
          selectedTimes.add(picked);
          selectedTimes.sort(
            (a, b) => (a.hour * 60 + a.minute).compareTo(
              b.hour * 60 + b.minute,
            ),
          );
        });
      }
    }
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

  Widget buildHeaderCard() {
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
              Icons.notifications_active,
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
                  "Yeni Hatırlatma",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "İlaç saatlerinizi düzenli takip edin",
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

  Widget buildFrequencyInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            frequencyIcon(frequency),
            color: Colors.teal,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              helperText(),
              style: const TextStyle(
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

  Widget buildSingleTimeSelector() {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: pickSingleTime,
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
                Icons.access_time,
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
                    "Seçilen saat",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    selectedTime.format(context),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.edit,
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMultipleTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: addMultipleTime,
            icon: const Icon(Icons.add_alarm),
            label: const Text("Saat Ekle"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (selectedTimes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              "Henüz saat eklenmedi.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: selectedTimes.map((time) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.teal.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.teal,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      time.format(context),
                      style: const TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTimes.remove(time);
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget buildEmptyMedicationState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_liquid,
                size: 46,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Önce bir ilaç eklemelisiniz",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Hatırlatma oluşturmak için en az bir ilacınız olmalı.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMultiple = frequency == "Multiple";

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Hatırlatma Ekle"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : medications.isEmpty
              ? buildEmptyMedicationState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      buildHeaderCard(),
                      const SizedBox(height: 20),

                      whiteCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("İlaç Seç", Icons.medication),
                            DropdownButtonFormField<int>(
                              value: selectedMedicationId,
                              
                              items:
                                  medications.map<DropdownMenuItem<int>>((med) {
                                final id = getMedicationId(med);
                                final name = getMedicationName(med);

                                return DropdownMenuItem<int>(
                                  value: id,
                                  child: Text(name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                final selected = medications.firstWhere(
                                  (med) => getMedicationId(med) == value,
                                );

                                setState(() {
                                  selectedMedicationId = value;
                                  selectedMedicationName =
                                      getMedicationName(selected);
                                  selectedMedicationNote =
    selected["notes"] ?? selected["Notes"] ?? "";
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      whiteCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("Hatırlatma Sıklığı", Icons.repeat),
                            DropdownButtonFormField<String>(
                              value: frequency,
                              decoration: inputDecoration(
                                "Sıklık",
                                Icons.repeat,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: "Daily",
                                  child: Text("Her gün"),
                                ),
                                DropdownMenuItem(
                                  value: "Weekly",
                                  child: Text("Haftalık"),
                                ),
                                DropdownMenuItem(
                                  value: "Once",
                                  child: Text("Tek seferlik"),
                                ),
                                DropdownMenuItem(
                                  value: "Multiple",
                                  child: Text("Günde birkaç kez"),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  frequency = value!;

                                  if (frequency != "Multiple") {
                                    selectedTimes.clear();
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            buildFrequencyInfo(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      whiteCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle(
                              isMultiple ? "Saatler" : "Saat",
                              Icons.access_time,
                            ),
                            if (!isMultiple) buildSingleTimeSelector(),
                            if (isMultiple) buildMultipleTimeSelector(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: save,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text(
                            "Hatırlatmayı Kaydet",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
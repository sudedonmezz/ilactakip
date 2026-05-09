import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'add_reminder_page.dart';
import '../services/notification_service.dart';

class ReminderListPage extends StatefulWidget {
  final int userId;

  const ReminderListPage({super.key, required this.userId});

  @override
  State<ReminderListPage> createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage> {
  List reminders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReminders();
  }

  Future<void> fetchReminders() async {
    try {
      final data = await ApiService.getReminders(widget.userId);

      if (!mounted) return;

      setState(() {
        reminders = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Hata"),
          content: Text(e.toString()),
        ),
      );
    }
  }

  String formatTime(int h, int m) {
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
  }

  String freqText(String f) {
    if (f == "Daily") return "Her gün";
    if (f == "Weekly") return "Haftalık";
    if (f == "Once") return "Tek seferlik";
    return f;
  }

  IconData freqIcon(String f) {
    if (f == "Daily") return Icons.today;
    if (f == "Weekly") return Icons.calendar_month;
    if (f == "Once") return Icons.event_available;
    return Icons.notifications_active;
  }

  Color freqColor(String f) {
    if (f == "Daily") return Colors.teal;
    if (f == "Weekly") return Colors.deepPurple;
    if (f == "Once") return Colors.orange;
    return Colors.teal;
  }

  Future<void> deleteReminder(dynamic r) async {
    final notificationId =
        r["medicationId"] * 10000 + r["hour"] * 100 + r["minute"];

    await ApiService.deleteReminder(r["id"]);
    await NotificationService.cancelNotification(notificationId);

    fetchReminders();
  }

  void confirmDelete(dynamic r) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hatırlatmayı Sil"),
        content: const Text("Bu hatırlatmayı silmek istiyor musunuz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await deleteReminder(r);
            },
            child: const Text(
              "Sil",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyState() {
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
                Icons.notifications_none,
                size: 46,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Henüz hatırlatma yok",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "İlaç saatlerinizi ekleyerek düzenli bildirim alabilirsiniz.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: openAddReminderPage,
              icon: const Icon(Icons.add),
              label: const Text("Hatırlatma Ekle"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openAddReminderPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReminderPage(userId: widget.userId),
      ),
    );

    if (result == true) {
      fetchReminders();
    }
  }

  Widget reminderCard(dynamic r) {
    final medicationName = r["medicationName"] ?? "İlaç";
    final frequency = r["frequencyType"] ?? "";
    final hour = r["hour"] ?? 0;
    final minute = r["minute"] ?? 0;

    final color = freqColor(frequency);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              freqIcon(frequency),
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicationName.toString(),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 17,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      formatTime(hour, minute),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        freqText(frequency),
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () => confirmDelete(r),
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            tooltip: "Sil",
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminderCount = reminders.length;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Hatırlatmalar"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddReminderPage,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Ekle"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reminders.isEmpty
              ? emptyState()
              : RefreshIndicator(
                  color: Colors.teal,
                  onRefresh: fetchReminders,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 20),
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
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_active,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Aktif Hatırlatmalar",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "$reminderCount hatırlatma",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    "İlaç saatlerinizi düzenli takip edin",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      ...reminders.map((r) => reminderCard(r)).toList(),
                    ],
                  ),
                ),
    );
  }
}
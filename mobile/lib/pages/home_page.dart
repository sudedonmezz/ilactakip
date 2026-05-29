import 'package:flutter/material.dart';
import 'login_page.dart';
import 'profile_page.dart';
import '../services/api_services.dart';
import 'medication_list_page.dart';
import 'add_medication_page.dart';
import 'reminder_list_page.dart';
import 'medication_log_stats_page.dart';
import 'glucose_tracking_page.dart';
import 'treatment_history_page.dart';
import 'blood_pressure_tracking_page.dart';


class HomePage extends StatefulWidget {
  final int userId;

  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String fullname = "Kullanıcı";
  int medicationCount = 0;
  int reminderCount = 0;
  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    try {
      final user = await ApiService.getUser(widget.userId);
      final meds = await ApiService.getMedications(widget.userId);
      final reminders = await ApiService.getReminders(widget.userId);

      if (!mounted) return;

      setState(() {
        fullname = user["fullname"] ?? user["Fullname"] ?? "Kullanıcı";
        medicationCount = meds.length;
        reminderCount = reminders.length;
        isLoadingStats = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingStats = false;
      });
    }
  }

  void confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Çıkış Yap"),
        content: const Text("Hesabınızdan çıkmak istiyor musunuz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text("Çıkış Yap", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> openAddMedicationPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicationPage(userId: widget.userId),
      ),
    );

    if (result == true) {
      loadHomeData();
    }
  }

  Future<void> openMedicationListPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationListPage(userId: widget.userId),
      ),
    );

    loadHomeData();
  }

  Future<void> openReminderListPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReminderListPage(userId: widget.userId),
      ),
    );

    loadHomeData();
  }

  Future<void> openProfilePage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userId: widget.userId),
      ),
    );

    loadHomeData();
  }

  Widget headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.teal, Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 18,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hoş geldin",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  fullname,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  "İlaçlarını ve hatırlatmalarını kolayca takip et",
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

  Widget statCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
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
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.teal, size: 27),
          ),
          const SizedBox(height: 10),
          isLoadingStats
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black45, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget quickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.teal, size: 29),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.teal, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget healthTrackingCard() {
  return Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    elevation: 3,
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GlucoseTrackingPage(userId: widget.userId),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.monitor_heart_outlined,
                color: Colors.orange,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Kan Şekeri Takibi",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Ölçümlerinizi kaydedin ve takip edin",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.orange,
              size: 18,
            ),
          ],
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
        title: const Text("Ana Sayfa"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Çıkış Yap",
            onPressed: confirmLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.teal,
        onRefresh: loadHomeData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              headerCard(),
              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: statCard(
                      icon: Icons.medication,
                      title: "İlaçlarım",
                      value: medicationCount.toString(),
                      subtitle: "kayıtlı ilaç",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: statCard(
                      icon: Icons.notifications_active,
                      title: "Hatırlatma",
                      value: reminderCount.toString(),
                      subtitle: "aktif bildirim",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              sectionTitle("Hızlı İşlemler"),

              quickActionCard(
                icon: Icons.add_circle_outline,
                title: "İlaç Ekle",
                subtitle: "Yeni ilaç bilgisi oluştur",
                onTap: openAddMedicationPage,
              ),
              const SizedBox(height: 14),

              quickActionCard(
                icon: Icons.medication_rounded,
                title: "İlaçlarım",
                subtitle: "Eklediğiniz ilaçları görüntüleyin",
                onTap: openMedicationListPage,
              ),
              const SizedBox(height: 14),

              quickActionCard(
                icon: Icons.notifications_none,
                title: "Hatırlatmalar",
                subtitle: "İlaç saatlerinizi yönetin",
                onTap: openReminderListPage,
              ),
              const SizedBox(height: 14),

              quickActionCard(
                icon: Icons.analytics_outlined,
                title: "İlaç Analizi",
                subtitle: "Zamanında alma oranlarını görüntüleyin",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MedicationLogStatsPage(userId: widget.userId),
                    ),
                  );
                },
              ),

               const SizedBox(height: 14),

              quickActionCard(
                icon: Icons.person_outline,
                title: "Profil",
                subtitle: "Hesap bilgilerinizi görüntüleyin",
                onTap: openProfilePage,
              ),

              const SizedBox(height: 26),

             sectionTitle("Sağlık Takibi"),

quickActionCard(
  icon: Icons.bloodtype,
  title: "Kan Şekeri Takibi",
  subtitle: "Kan şekeri ölçümlerinizi kaydedin",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            GlucoseTrackingPage(userId: widget.userId),
      ),
    );
  },
),



const SizedBox(height: 14),

quickActionCard(
  icon: Icons.healing,
  title: "Tedavi Geçmişi",
  subtitle:
      "İnsülin, ilaç, besin ve egzersiz kayıtlarını görüntüleyin",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TreatmentHistoryPage(userId: widget.userId),
      ),
    );
  },
),

const SizedBox(height: 14),

quickActionCard(
  icon: Icons.favorite,
  title: "Tansiyon Takibi",
  subtitle: "Tansiyon ve nabız ölçümlerinizi kaydedin",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BloodPressureTrackingPage(userId: widget.userId),
      ),
    );
  },
),

            ],
          ),
        ),
      ),
    );
  }
}

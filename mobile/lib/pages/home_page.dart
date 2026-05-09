import 'package:flutter/material.dart';
import 'login_page.dart';
import 'profile_page.dart';
import '../services/api_services.dart';
import 'medication_list_page.dart';
import 'add_medication_page.dart';
import 'reminder_list_page.dart';

class HomePage extends StatefulWidget {
  final int userId;


  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String fullname = "x";
  int medicationCount = 0;

  @override
void initState() {
  super.initState();
  getUserInfo();
  getMedicationCount();
}
Future<void> getMedicationCount() async {
  final meds = await ApiService.getMedications(widget.userId);

  print("İLAÇ SAYISI: ${meds.length}");

  if (!mounted) return;

  setState(() {
    medicationCount = meds.length;
  });
}

  Future<void> getUserInfo() async {
    final user = await ApiService.getUser(widget.userId);

    if (!mounted) return;

    setState(() {
      fullname = user["fullname"] ?? user["Fullname"] ?? "Kullanıcı";
    });
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
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Çıkış Yap"),
            content: const Text("Hesabınızdan çıkmak istiyor musunuz?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("İptal"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  "Çıkış Yap",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    ),
  ],
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
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
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 34,
      ),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hoş geldin !",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            "$fullname",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Sağlığını düzenli takip et",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    ),
  ],
),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildMiniInfoCard(
                    icon: Icons.medication,
                    title: "İlaçlarım",
                    value: medicationCount.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMiniInfoCard(
                    icon: Icons.notifications_active,
                    title: "Hatırlatma",
                    value: "0",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          _buildMenuCard(
  icon: Icons.add_circle_outline,
  title: "İlaç Ekle",
  subtitle: "Yeni ilaç ve saat bilgisi ekleyin",
  onTap: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddMedicationPage(userId: widget.userId),
    ),
  );

  if (result == true) {
    getMedicationCount();
  }
},
),
            const SizedBox(height: 14),
_buildMenuCard(
  icon: Icons.medication_rounded,
  title: "İlaçlarım",
  subtitle: "Eklediğiniz ilaçları görüntüleyin",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationListPage(userId: widget.userId),
      ),
    );
  },
),
            const SizedBox(height: 14),
            _buildMenuCard(
              icon: Icons.monitor_heart_outlined,
              title: "Kan Şekeri Takibi",
              subtitle: "Ölçümlerinizi kaydedin ve inceleyin",
              onTap: () {},
            ),
            const SizedBox(height: 14),
           _buildMenuCard(
              icon: Icons.notifications_none,
              title: "Hatırlatmalar",
              subtitle: "İlaç saatlerinizi yönetin",
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReminderListPage(userId: widget.userId),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
           _buildMenuCard(
  icon: Icons.person_outline,
  title: "Profil",
  subtitle: "Hesap bilgilerinizi görüntüleyin",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userId: widget.userId),
      ),
    );
  },
),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.teal, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.teal, size: 28),
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
}

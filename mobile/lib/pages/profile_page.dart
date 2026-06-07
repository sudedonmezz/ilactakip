import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';
import '../services/notification_service.dart';

class ProfilePage extends StatefulWidget {
  final int userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      final data = await ApiService.getUser(widget.userId);

      if (!mounted) return;

      setState(() {
        user = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage("Hata", e.toString());
    }
  }

  String getValue(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return "Bilgi yok";
    }
    return value.toString();
  }

  dynamic getField(String lower, String upper) {
    return user?[lower] ?? user?[upper];
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

  Future<void> openEditProfilePage() async {
    if (user == null) return;

    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: user!),
      ),
    );

    if (updatedUser != null) {
      setState(() {
        user = updatedUser;
      });
    }
  }

  Future<void> requestDeleteAccount() async {
  try {
    await ApiService.requestDeleteAccount(widget.userId);

    await NotificationService.cancelAllNotifications();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hesap Silme Başlatıldı"),
        content: const Text(
          "Hesabınız silme işlemine alındı. 30 gün içinde giriş yaparak hesabınızı geri açabilirsiniz. "
          "30 gün sonunda hesabınız ve verileriniz kalıcı olarak silinecektir.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tamam"),
          ),
        ],
      ),
    );

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  } catch (e) {
    if (!mounted) return;
    showMessage("Hata", e.toString());
  }
}

void confirmDeleteAccount() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Hesabımı Sil"),
      content: const Text(
        "Hesabınız hemen silinmez. Hesabınız 30 gün boyunca pasif tutulur. "
        "Bu süre içinde tekrar giriş yaparak hesabınızı geri açabilirsiniz. "
        "30 gün sonunda tüm verileriniz kalıcı olarak silinir.\n\n"
        "Devam etmek istiyor musunuz?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("İptal"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            requestDeleteAccount();
          },
          child: const Text(
            "Silme İşlemini Başlat",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

  Widget headerCard() {
    final fullname = getValue(getField("fullname", "Fullname"));
    final email = getValue(getField("email", "Email"));

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
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 44,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            fullname,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: openEditProfilePage,
              icon: const Icon(Icons.edit),
              label: const Text(
                "Profili Düzenle",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.teal,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 21),
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

  Widget infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final bool isEmpty = value == "Bilgi yok";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: Colors.teal,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: isEmpty ? Colors.black38 : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget deleteAccountCard() {
  return Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    elevation: 3,
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: confirmDeleteAccount,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.delete_forever,
                color: Colors.red,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hesabımı Sil",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Hesabınız 30 gün sonra kalıcı olarak silinir",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.red,
              size: 18,
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget profileContent() {
    return RefreshIndicator(
      color: Colors.teal,
      onRefresh: fetchUser,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            headerCard(),
            const SizedBox(height: 24),

            sectionTitle("Kişisel Bilgiler", Icons.person_outline),

            infoCard(
              icon: Icons.person,
              title: "Ad Soyad",
              value: getValue(getField("fullname", "Fullname")),
            ),
            infoCard(
              icon: Icons.email,
              title: "Email",
              value: getValue(getField("email", "Email")),
            ),
            infoCard(
              icon: Icons.cake,
              title: "Yaş",
              value: getValue(getField("age", "Age")),
            ),
            infoCard(
              icon: Icons.person_outline,
              title: "Cinsiyet",
              value: getValue(getField("gender", "Gender")),
            ),

            const SizedBox(height: 16),

            sectionTitle("Sağlık Bilgileri", Icons.health_and_safety),

            infoCard(
              icon: Icons.monitor_weight,
              title: "Kilo",
              value: "${getValue(getField("weight", "Weight"))} kg",
            ),
            infoCard(
              icon: Icons.height,
              title: "Boy",
              value: "${getValue(getField("height", "Height"))} cm",
            ),
            infoCard(
              icon: Icons.medical_information,
              title: "Kronik Hastalık",
              value: getValue(
                getField("chronicDisease", "ChronicDisease"),
              ),
            ),
            const SizedBox(height: 16),

sectionTitle("Hesap İşlemleri", Icons.settings),

deleteAccountCard(),
          ],
        ),
      ),
    );
  }

  Widget errorState() {
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
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 46,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Kullanıcı bulunamadı",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Profil bilgileri alınamadı. Tekrar deneyebilirsiniz.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: fetchUser,
              icon: const Icon(Icons.refresh),
              label: const Text("Tekrar Dene"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: user == null ? null : openEditProfilePage,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? errorState()
              : profileContent(),
    );
  }
}
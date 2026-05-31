import 'package:flutter/material.dart';
import 'register_page.dart';
import '../services/api_services.dart';
import 'home_page.dart';
import 'profile_complete_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController sifreController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    sifreController.dispose();
    super.dispose();
  }

void girisYap() async {
  String email = emailController.text.trim();
  String sifre = sifreController.text.trim();

  if (email.isEmpty || sifre.isEmpty) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text("Hata"),
        content: Text("Email ve şifre boş olamaz"),
      ),
    );
    return;
  }

  try {
    final user = await ApiService.loginUser(
  email: email,
  password: sifre,
);

if (!mounted) return;

final bool profileIncomplete =
    user["age"] == null ||
    user["gender"] == null ||
    user["weight"] == null ||
    user["height"] == null;

if (profileIncomplete) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => ProfileCompletePage(user: user),
    ),
  );
} else {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
     builder: (context) => HomePage(
  userId: user["id"] ?? user["Id"],
),
    ),
  );
}
  } catch (e) {

    String message = e.toString();

  // "Exception: " kısmını kaldır
  if (message.startsWith("Exception: ")) {
    message = message.replaceFirst("Exception: ", "");
  }

    if (!mounted) return;

     showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Giriş Başarısız"),
      content: Text(message),
    ),
  );
  }
}

void googleIleGirisYap() async {
  try {
    final user = await ApiService.googleLogin();

    if (!mounted) return;

    final bool profileIncomplete =
        user["age"] == null ||
        user["gender"] == null ||
        user["weight"] == null ||
        user["height"] == null;

    if (profileIncomplete) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileCompletePage(user: user),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userId: user["id"] ?? user["Id"],
          ),
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;

    var message = e.toString();
    if (message.startsWith("Exception: ")) {
      message = message.replaceFirst("Exception: ", "");
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Google Giriş Başarısız"),
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
}

  void registerSayfasinaGit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
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
                      Icons.medication_rounded,
                      size: 48,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Hoş Geldiniz",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "İlaç takip uygulamasına giriş yapın",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: emailController,
                    cursorColor: Colors.teal,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(color: Colors.teal),
                      prefixIcon: const Icon(Icons.email, color: Colors.teal),
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: sifreController,
                    obscureText: true,
                    cursorColor: Colors.teal,
                    decoration: InputDecoration(
                      labelText: "Şifre",
                      labelStyle: const TextStyle(color: Colors.teal),
                      prefixIcon: const Icon(Icons.lock, color: Colors.teal),
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
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: girisYap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Giriş Yap",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

OutlinedButton.icon(
  onPressed: googleIleGirisYap,
  icon: const Icon(Icons.g_mobiledata, color: Colors.teal, size: 30),
  label: const Text(
    "Google ile devam et",
    style: TextStyle(
      color: Colors.teal,
      fontWeight: FontWeight.bold,
      fontSize: 15,
    ),
  ),
  style: OutlinedButton.styleFrom(
    minimumSize: const Size(double.infinity, 52),
    side: const BorderSide(color: Colors.teal),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: registerSayfasinaGit,
                    child: const Text(
                      "Hesabın yok mu? Kayıt ol",
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.w600,
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
}

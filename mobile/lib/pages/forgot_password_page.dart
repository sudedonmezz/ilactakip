import 'package:flutter/material.dart';
import '../services/api_services.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  int step = 1;

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    passwordController.dispose();
    super.dispose();
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

  Future<void> sendCode() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showMessage("Hata", "Lütfen email adresinizi girin.");
      return;
    }

    setState(() => isLoading = true);

    try {
      await ApiService.sendPasswordResetCode(email: email);

      if (!mounted) return;

      setState(() {
        isLoading = false;
        step = 2;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      showMessage("Hata", e.toString());
    }
  }

  Future<void> verifyCode() async {
    final email = emailController.text.trim();
    final code = codeController.text.trim();

    if (code.length != 6) {
      showMessage("Hata", "Lütfen 6 haneli kodu girin.");
      return;
    }

    setState(() => isLoading = true);

    try {
      await ApiService.verifyPasswordResetCode(
        email: email,
        code: code,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
        step = 3;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      showMessage("Hata", e.toString());
    }
  }

  Future<void> changePassword() async {
    final email = emailController.text.trim();
    final code = codeController.text.trim();
    final password = passwordController.text.trim();

    if (password.length < 6) {
      showMessage("Hata", "Şifre en az 6 karakter olmalı.");
      return;
    }

    setState(() => isLoading = true);

    try {
      await ApiService.changePasswordWithCode(
        email: email,
        code: code,
        newPassword: password,
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Başarılı"),
          content: const Text("Şifreniz başarıyla güncellendi."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tamam"),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      showMessage("Hata", e.toString());
    }
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

  Widget currentStepContent() {
    if (step == 1) {
      return Column(
        children: [
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Colors.teal,
            decoration: inputDecoration("Email", Icons.email),
          ),
          const SizedBox(height: 22),
          actionButton("Kod Gönder", sendCode),
        ],
      );
    }

    if (step == 2) {
      return Column(
        children: [
          Text(
            "${emailController.text.trim()} adresine gönderilen kodu girin.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, height: 1.35),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            cursorColor: Colors.teal,
            decoration: inputDecoration("Doğrulama Kodu", Icons.verified),
          ),
          const SizedBox(height: 12),
          actionButton("Kodu Doğrula", verifyCode),
        ],
      );
    }

    return Column(
      children: [
        TextField(
          controller: passwordController,
          obscureText: true,
          cursorColor: Colors.teal,
          decoration: inputDecoration("Yeni Şifre", Icons.lock),
        ),
        const SizedBox(height: 22),
        actionButton("Şifreyi Güncelle", changePassword),
      ],
    );
  }

  Widget actionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          disabledBackgroundColor: Colors.teal.shade200,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  String stepTitle() {
    if (step == 1) return "Şifremi Unuttum";
    if (step == 2) return "Kodu Doğrula";
    return "Yeni Şifre";
  }

  String stepSubtitle() {
    if (step == 1) {
      return "Email adresinizi girin, size doğrulama kodu gönderelim.";
    }
    if (step == 2) {
      return "Email adresinize gelen 6 haneli kodu yazın.";
    }
    return "Hesabınız için yeni şifrenizi belirleyin.";
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
                      Icons.lock_reset,
                      size: 46,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    stepTitle(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stepSubtitle(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 28),
                  currentStepContent(),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Giriş ekranına dön",
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
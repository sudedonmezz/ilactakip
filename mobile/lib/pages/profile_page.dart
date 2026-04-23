import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'edit_profile_page.dart';

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

      setState(() {
        user = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String getValue(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return "Bilgi yok";
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
     appBar: AppBar(
  title: const Text("Profil"),
  backgroundColor: Colors.teal,
  foregroundColor: Colors.white,
  actions: [
    IconButton(
      icon: const Icon(Icons.edit),
      onPressed: user == null
          ? null
          : () async {
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
            },
    ),
  ],
),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? const Center(child: Text("Kullanıcı bulunamadı"))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildCard("Ad Soyad", getValue(user!["fullname"] ?? user!["Fullname"])),
                      _buildCard("Email", getValue(user!["email"] ?? user!["Email"])),
                      _buildCard("Yaş", getValue(user!["age"] ?? user!["Age"])),
                      _buildCard("Cinsiyet", getValue(user!["gender"] ?? user!["Gender"])),
                      _buildCard("Kilo", getValue(user!["weight"] ?? user!["Weight"])),
                      _buildCard("Boy", getValue(user!["height"] ?? user!["Height"])),
                      _buildCard("Hastalık", getValue(user!["chronicDisease"] ?? user!["ChronicDisease"])),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCard(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
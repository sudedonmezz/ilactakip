import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String email;

  const HomePage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ana Sayfa"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.teal),
                title: const Text("Hoş geldin"),
                subtitle: Text(email.isEmpty ? "Kullanıcı" : email),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.medication, color: Colors.teal),
                title: const Text("İlaçlarım"),
                subtitle: const Text("Henüz ilaç eklenmedi"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.monitor_heart, color: Colors.teal),
                title: const Text("Kan Şekeri Takibi"),
                subtitle: const Text("Ölçümlerinizi görüntüleyin"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.notifications, color: Colors.teal),
                title: const Text("Hatırlatmalar"),
                subtitle: const Text("İlaç saatlerinizi yönetin"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlucoseTargetSettingsPage extends StatefulWidget {
  const GlucoseTargetSettingsPage({super.key});

  @override
  State<GlucoseTargetSettingsPage> createState() =>
      _GlucoseTargetSettingsPageState();
}

class _GlucoseTargetSettingsPageState
    extends State<GlucoseTargetSettingsPage> {
  final fastingMin = TextEditingController();
  final fastingMax = TextEditingController();

  final postMin = TextEditingController();
  final postMax = TextEditingController();

  final randomMin = TextEditingController();
  final randomMax = TextEditingController();

  final bedtimeMin = TextEditingController();
  final bedtimeMax = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTargets();
  }

  @override
  void dispose() {
    fastingMin.dispose();
    fastingMax.dispose();
    postMin.dispose();
    postMax.dispose();
    randomMin.dispose();
    randomMax.dispose();
    bedtimeMin.dispose();
    bedtimeMax.dispose();
    super.dispose();
  }

  Future<void> loadTargets() async {
    final prefs = await SharedPreferences.getInstance();

    fastingMin.text = (prefs.getDouble("fastingMin") ?? 80).toStringAsFixed(0);
    fastingMax.text = (prefs.getDouble("fastingMax") ?? 130).toStringAsFixed(0);

    postMin.text = (prefs.getDouble("postMin") ?? 80).toStringAsFixed(0);
    postMax.text = (prefs.getDouble("postMax") ?? 180).toStringAsFixed(0);

    randomMin.text = (prefs.getDouble("randomMin") ?? 70).toStringAsFixed(0);
    randomMax.text = (prefs.getDouble("randomMax") ?? 180).toStringAsFixed(0);

    bedtimeMin.text = (prefs.getDouble("bedtimeMin") ?? 90).toStringAsFixed(0);
    bedtimeMax.text = (prefs.getDouble("bedtimeMax") ?? 150).toStringAsFixed(0);

    setState(() {});
  }

  Future<void> saveTargets() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble("fastingMin", double.parse(fastingMin.text));
    await prefs.setDouble("fastingMax", double.parse(fastingMax.text));

    await prefs.setDouble("postMin", double.parse(postMin.text));
    await prefs.setDouble("postMax", double.parse(postMax.text));

    await prefs.setDouble("randomMin", double.parse(randomMin.text));
    await prefs.setDouble("randomMax", double.parse(randomMax.text));

    await prefs.setDouble("bedtimeMin", double.parse(bedtimeMin.text));
    await prefs.setDouble("bedtimeMax", double.parse(bedtimeMax.text));

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.teal),
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

  Widget targetCard({
    required String title,
    required TextEditingController minController,
    required TextEditingController maxController,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minController,
                  keyboardType: TextInputType.number,
                  decoration: inputDecoration("Alt sınır"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: maxController,
                  keyboardType: TextInputType.number,
                  decoration: inputDecoration("Üst sınır"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Şeker Hedefleri"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            targetCard(
              title: "Açlık",
              minController: fastingMin,
              maxController: fastingMax,
            ),
            targetCard(
              title: "Tokluk",
              minController: postMin,
              maxController: postMax,
            ),
            targetCard(
              title: "Rastgele",
              minController: randomMin,
              maxController: randomMax,
            ),
            targetCard(
              title: "Yatmadan Önce",
              minController: bedtimeMin,
              maxController: bedtimeMax,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: saveTargets,
                icon: const Icon(Icons.save),
                label: const Text(
                  "Kaydet",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
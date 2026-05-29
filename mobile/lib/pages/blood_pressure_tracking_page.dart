import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'add_blood_pressure_measurement_page.dart';

class BloodPressureTrackingPage extends StatefulWidget {
  final int userId;

  const BloodPressureTrackingPage({super.key, required this.userId});

  @override
  State<BloodPressureTrackingPage> createState() =>
      _BloodPressureTrackingPageState();
}

class _BloodPressureTrackingPageState extends State<BloodPressureTrackingPage> {
  List measurements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMeasurements();
  }

  Future<void> fetchMeasurements() async {
    try {
      final data =
          await ApiService.getBloodPressureMeasurements(widget.userId);

      if (!mounted) return;

      setState(() {
        measurements = data;
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

  DateTime parseDate(dynamic value) {
    return DateTime.parse(value.toString());
  }

  String formatDateTime(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  int getInt(dynamic item, String key) {
    final value = item[key];
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  int? getNullableInt(dynamic item, String key) {
    final value = item[key];
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  int get latestSystolic {
    if (measurements.isEmpty) return 0;
    final sorted = [...measurements];
    sorted.sort((a, b) =>
        parseDate(b["measurementtime"]).compareTo(parseDate(a["measurementtime"])));
    return getInt(sorted.first, "systolic");
  }

  int get latestDiastolic {
    if (measurements.isEmpty) return 0;
    final sorted = [...measurements];
    sorted.sort((a, b) =>
        parseDate(b["measurementtime"]).compareTo(parseDate(a["measurementtime"])));
    return getInt(sorted.first, "diastolic");
  }

  double get averageSystolic {
    if (measurements.isEmpty) return 0;
    final total = measurements.fold<int>(
      0,
      (sum, item) => sum + getInt(item, "systolic"),
    );
    return total / measurements.length;
  }

  double get averageDiastolic {
    if (measurements.isEmpty) return 0;
    final total = measurements.fold<int>(
      0,
      (sum, item) => sum + getInt(item, "diastolic"),
    );
    return total / measurements.length;
  }

  String bloodPressureStatus(int systolic, int diastolic) {
    if (systolic < 90 || diastolic < 60) return "Düşük";
    if (systolic >= 140 || diastolic >= 90) return "Çok yüksek";
    if (systolic >= 120 || diastolic >= 80) return "Yüksek";
    return "Normal";
  }

  Color bloodPressureColor(int systolic, int diastolic) {
    final status = bloodPressureStatus(systolic, diastolic);

    if (status == "Düşük") return Colors.orange;
    if (status == "Yüksek") return Colors.deepOrange;
    if (status == "Çok yüksek") return Colors.red;
    return Colors.teal;
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

  Future<void> openAddMeasurementPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddBloodPressureMeasurementPage(userId: widget.userId),
      ),
    );

    if (result == true) {
      fetchMeasurements();
    }
  }

  Future<void> deleteMeasurement(int id) async {
    try {
      await ApiService.deleteBloodPressureMeasurement(id);
      fetchMeasurements();
    } catch (e) {
      showMessage("Hata", e.toString());
    }
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ölçümü Sil"),
        content: const Text("Bu tansiyon ölçümünü silmek istiyor musunuz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteMeasurement(id);
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

  Widget headerCard() {
    final systolic = latestSystolic;
    final diastolic = latestDiastolic;

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
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tansiyon Takibi",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  measurements.isEmpty
                      ? "Henüz ölçüm yok"
                      : "$systolic/$diastolic mmHg",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  measurements.isEmpty
                      ? "İlk ölçümünüzü ekleyin"
                      : "Son ölçüm: ${bloodPressureStatus(systolic, diastolic)}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
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
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
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
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
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
                Icons.favorite,
                size: 46,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Henüz tansiyon ölçümü eklenmedi",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tansiyon ve nabız ölçümlerinizi ekleyerek takibinizi başlatabilirsiniz.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: openAddMeasurementPage,
              icon: const Icon(Icons.add),
              label: const Text("Ölçüm Ekle"),
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

  Widget chip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget measurementCard(dynamic measurement) {
    final id = measurement["id"];
    final systolic = getInt(measurement, "systolic");
    final diastolic = getInt(measurement, "diastolic");
    final pulse = getNullableInt(measurement, "pulse");
    final note = measurement["note"] ?? "";
    final time = parseDate(measurement["measurementtime"]);
    final color = bloodPressureColor(systolic, diastolic);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.favorite,
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
                  "$systolic/$diastolic mmHg",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    chip(
                      icon: Icons.info_outline,
                      text: bloodPressureStatus(systolic, diastolic),
                      color: color,
                    ),
                    if (pulse != null)
                      chip(
                        icon: Icons.monitor_heart,
                        text: "$pulse nabız",
                        color: Colors.deepPurple,
                      ),
                    chip(
                      icon: Icons.event,
                      text: formatDateTime(time),
                      color: Colors.grey,
                    ),
                  ],
                ),
                if (note.toString().trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      note.toString(),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            tooltip: "Sil",
            onPressed: () => confirmDelete(id),
          ),
        ],
      ),
    );
  }

  Widget content() {
    final sorted = [...measurements];

    sorted.sort((a, b) {
      final aDate = parseDate(a["measurementtime"]);
      final bDate = parseDate(b["measurementtime"]);
      return bDate.compareTo(aDate);
    });

    return RefreshIndicator(
      color: Colors.teal,
      onRefresh: fetchMeasurements,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          headerCard(),
          const SizedBox(height: 18),
          Row(
            children: [
              statCard(
                icon: Icons.show_chart,
                title: "Ort. Büyük",
                value: measurements.isEmpty
                    ? "-"
                    : averageSystolic.toStringAsFixed(0),
                color: Colors.teal,
              ),
              const SizedBox(width: 12),
              statCard(
                icon: Icons.show_chart,
                title: "Ort. Küçük",
                value: measurements.isEmpty
                    ? "-"
                    : averageDiastolic.toStringAsFixed(0),
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              statCard(
                icon: Icons.list_alt,
                title: "Toplam",
                value: measurements.length.toString(),
                color: Colors.deepPurple,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
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
              const Text(
                "Ölçümler",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...sorted.map((item) => measurementCard(item)).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Tansiyon Takibi"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddMeasurementPage,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Ölçüm"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : measurements.isEmpty
              ? emptyState()
              : content(),
    );
  }
}
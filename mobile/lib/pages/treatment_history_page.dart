import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'add_treatment_page.dart';

class TreatmentHistoryPage extends StatefulWidget {
  final int userId;

  const TreatmentHistoryPage({
    super.key,
    required this.userId,
  });

  @override
  State<TreatmentHistoryPage> createState() =>
      _TreatmentHistoryPageState();
}

class _TreatmentHistoryPageState
    extends State<TreatmentHistoryPage> {
  List treatments = [];
  bool isLoading = true;

  String selectedFilter = "Today";

  @override
  void initState() {
    super.initState();
    fetchTreatments();
  }

  Future<void> fetchTreatments() async {
    try {
      final data =
          await ApiService.getTreatments(widget.userId);

      if (!mounted) return;

      setState(() {
        treatments = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  DateTime parseDate(dynamic value) {
    return DateTime.parse(value.toString());
  }

  List get filteredTreatments {
    final now = DateTime.now();

    return treatments.where((t) {
      final date = parseDate(t["takentime"]);

      if (selectedFilter == "Today") {
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      }

      if (selectedFilter == "Week") {
        return date.isAfter(
          now.subtract(const Duration(days: 7)),
        );
      }

      if (selectedFilter == "Month") {
        return date.isAfter(
          DateTime(now.year, now.month - 1, now.day),
        );
      }

      return true;
    }).toList();
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}."
        "${date.month.toString().padLeft(2, '0')}."
        "${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  Color typeColor(String type) {
    switch (type) {
      case "Insulin":
        return Colors.orange;

      case "Medication":
        return Colors.teal;

      case "Food":
        return Colors.green;

      case "Exercise":
        return Colors.purple;

      default:
        return Colors.blueGrey;
    }
  }

  IconData typeIcon(String type) {
    switch (type) {
      case "Insulin":
        return Icons.vaccines;

      case "Medication":
        return Icons.medication;

      case "Food":
        return Icons.restaurant;

      case "Exercise":
        return Icons.fitness_center;

      default:
        return Icons.health_and_safety;
    }
  }

  String typeText(String type) {
    switch (type) {
      case "Insulin":
        return "İnsülin";

      case "Medication":
        return "İlaç";

      case "Food":
        return "Besin";

      case "Exercise":
        return "Egzersiz";

      default:
        return type;
    }
  }

  Future<void> deleteTreatment(int id) async {
    await ApiService.deleteTreatment(id);
    fetchTreatments();
  }

  Widget filterChips() {
    final filters = {
      "Today": "Bugün",
      "Week": "Bu Hafta",
      "Month": "Bu Ay",
      "All": "Hepsi",
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.entries.map((e) {
          final selected = selectedFilter == e.key;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(e.value),
              selected: selected,
              selectedColor: Colors.teal,
              labelStyle: TextStyle(
                color:
                    selected ? Colors.white : Colors.teal,
                fontWeight: FontWeight.bold,
              ),
              onSelected: (_) {
                setState(() {
                  selectedFilter = e.key;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget treatmentCard(dynamic t) {
    final type = t["treatmenttype"] ?? "";
    final color = typeColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              typeIcon(type),
              color: color,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  t["name"] ?? "",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "${t["dose"] ?? "-"} ${t["unit"] ?? ""}",
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  formatDate(
                    parseDate(t["takentime"]),
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),

                if ((t["note"] ?? "")
                    .toString()
                    .isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    t["note"],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  typeText(type),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              IconButton(
                onPressed: () {
                  deleteTreatment(t["id"]);
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
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
    final visible = filteredTreatments;

    return Scaffold(
      floatingActionButton:
    FloatingActionButton.extended(
  backgroundColor: Colors.teal,
  foregroundColor: Colors.white,
  icon: const Icon(Icons.add),
  label: const Text("Ekle"),
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddTreatmentPage(
          userId: widget.userId,
        ),
      ),
    );

    if (result == true) {
      fetchTreatments();
    }
  },
),
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Tedavi Geçmişi"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: fetchTreatments,
              color: Colors.teal,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    filterChips(),
                    const SizedBox(height: 20),

                    if (visible.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Text(
                          "Kayıt bulunamadı",
                        ),
                      ),

                    ...visible.map(
                      (t) => treatmentCard(t),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
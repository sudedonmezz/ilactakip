import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'add_medication_page.dart';

class MedicationListPage extends StatefulWidget {
  final int userId;

  const MedicationListPage({super.key, required this.userId});

  @override
  State<MedicationListPage> createState() => _MedicationListPageState();
}

class _MedicationListPageState extends State<MedicationListPage> {
  List<dynamic> medications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMedications();
  }

  Future<void> fetchMedications() async {
    try {
      final data = await ApiService.getMedications(widget.userId);

      setState(() {
        medications = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  dynamic getField(Map med, String lower, String upper) {
    return med[lower] ?? med[upper];
  }

  Future<void> deleteMedication(int medicationId) async {
    await ApiService.deleteMedication(medicationId);
    fetchMedications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("İlaçlarım"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMedicationPage(userId: widget.userId),
            ),
          );

          if (result == true) {
            fetchMedications();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : medications.isEmpty
              ? const Center(child: Text("Henüz ilaç eklenmedi."))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    final med = medications[index] as Map;

                    final id = getField(med, "id", "Id");
                    final name = getField(med, "name", "Name") ?? "";
                    final dosage = getField(med, "dosage", "Dosage") ?? "";
                    final type = getField(med, "type", "Type") ?? "";
                    final notes = getField(med, "notes", "Notes") ?? "";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.medication,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.toString(),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$dosage • $type",
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                                if (notes.toString().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    notes.toString(),
                                    style: const TextStyle(
                                      color: Colors.black45,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              deleteMedication(id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
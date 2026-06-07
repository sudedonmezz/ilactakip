import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_services.dart';

class MedicationLogStatsPage extends StatefulWidget {
  final int userId;

  const MedicationLogStatsPage({super.key, required this.userId});

  @override
  State<MedicationLogStatsPage> createState() => _MedicationLogStatsPageState();
}

class _MedicationLogStatsPageState extends State<MedicationLogStatsPage> {
  List logs = [];
  bool isLoading = true;

  String selectedRange = "Daily";
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    try {
      final data = await ApiService.getMedicationLogs(widget.userId);

      if (!mounted) return;

      setState(() {
        logs = data;
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

  DateTime parseDate(dynamic value) {
    return DateTime.parse(value.toString());
  }

  String getStatus(dynamic log) {
    return (log["status"] ?? log["Status"] ?? "").toString();
  }

  DateTime rangeStartDate() {
    if (selectedRange == "Daily") {
      return DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    }

    if (selectedRange == "Weekly") {
      return selectedDate.subtract(const Duration(days: 6));
    }

    if (selectedRange == "Monthly") {
      return DateTime(
        selectedDate.year,
        selectedDate.month - 1,
        selectedDate.day,
      );
    }

    if (selectedRange == "Yearly") {
      return DateTime(selectedDate.year, 1, 1);
    }

    if (selectedRange == "SixMonths") {
      return DateTime(
        selectedDate.year,
        selectedDate.month - 6,
        selectedDate.day,
      );
    }

    return DateTime(selectedDate.year, 1, 1);
  }

  DateTime rangeEndDate() {
    if (selectedRange == "Daily") {
      return DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        23,
        59,
        59,
      );
    }

    if (selectedRange == "Yearly") {
      return DateTime(selectedDate.year, 12, 31, 23, 59, 59);
    }

    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
      59,
    );
  }

  List get filteredLogs {
    final start = rangeStartDate();
    final end = rangeEndDate();

    return logs.where((log) {
      final scheduled = parseDate(log["scheduledDateTime"]);

      return (scheduled.isAfter(start) || scheduled.isAtSameMomentAs(start)) &&
          (scheduled.isBefore(end) || scheduled.isAtSameMomentAs(end));
    }).toList();
  }

  int get totalTaken => filteredLogs.length;

  int get onTimeCount {
    return filteredLogs.where((log) => getStatus(log) == "Taken").length;
  }

  int get lateCount {
    return filteredLogs.where((log) => getStatus(log) == "Late").length;
  }

  int get missedCount {
    return filteredLogs.where((log) => getStatus(log) == "Missed").length;
  }

  double get onTimeRate {
    if (filteredLogs.isEmpty) return 0;
    return (onTimeCount / filteredLogs.length) * 100;
  }

  void previousPeriod() {
    setState(() {
      if (selectedRange == "Daily") {
        selectedDate = selectedDate.subtract(const Duration(days: 1));
      } else if (selectedRange == "Weekly") {
        selectedDate = selectedDate.subtract(const Duration(days: 7));
      } else if (selectedRange == "Monthly") {
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month - 1,
          selectedDate.day,
        );
      } else if (selectedRange == "SixMonths") {
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month - 6,
          selectedDate.day,
        );
      } else {
        selectedDate = DateTime(
          selectedDate.year - 1,
          selectedDate.month,
          selectedDate.day,
        );
      }
    });
  }

  void nextPeriod() {
    final now = DateTime.now();

    setState(() {
      if (selectedRange == "Daily") {
        selectedDate = selectedDate.add(const Duration(days: 1));
      } else if (selectedRange == "Weekly") {
        selectedDate = selectedDate.add(const Duration(days: 7));
      } else if (selectedRange == "Monthly") {
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month + 1,
          selectedDate.day,
        );
      } else if (selectedRange == "SixMonths") {
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month + 6,
          selectedDate.day,
        );
      } else {
        selectedDate = DateTime(
          selectedDate.year + 1,
          selectedDate.month,
          selectedDate.day,
        );
      }

      if (selectedDate.isAfter(now)) {
        selectedDate = now;
      }
    });
  }

  String periodTitle() {
    final start = rangeStartDate();
    final end = rangeEndDate();

    if (selectedRange == "Daily") {
      return formatDate(start);
    }

    return "${formatDate(start)} - ${formatDate(end)}";
  }

  List<Map<String, dynamic>> chartData() {
    final now = selectedDate;

    const monthNames = [
      "Oca",
      "Şub",
      "Mar",
      "Nis",
      "May",
      "Haz",
      "Tem",
      "Ağu",
      "Eyl",
      "Eki",
      "Kas",
      "Ara",
    ];

    double calculateRate(List items) {
      final total = items.length;
      final onTime = items.where((log) => getStatus(log) == "Taken").length;
      return total == 0 ? 0.0 : (onTime / total) * 100;
    }

    if (selectedRange == "Daily") {
      return List.generate(24, (index) {
        final hourLogs = filteredLogs.where((log) {
          final scheduled = parseDate(log["scheduledDateTime"]);
          return scheduled.hour == index;
        }).toList();

        return {
          "label": index.toString().padLeft(2, "0"),
          "rate": calculateRate(hourLogs),
        };
      });
    }

    if (selectedRange == "Weekly") {
      return List.generate(7, (index) {
        final date = now.subtract(Duration(days: 6 - index));

        final dayLogs = filteredLogs.where((log) {
          final scheduled = parseDate(log["scheduledDateTime"]);
          return scheduled.year == date.year &&
              scheduled.month == date.month &&
              scheduled.day == date.day;
        }).toList();

        return {
          "label": "${date.day}/${date.month}",
          "rate": calculateRate(dayLogs),
        };
      });
    }

    if (selectedRange == "Monthly") {
      return List.generate(4, (index) {
        final start = now.subtract(Duration(days: (4 - index) * 7));
        final end = start.add(const Duration(days: 7));

        final weekLogs = filteredLogs.where((log) {
          final scheduled = parseDate(log["scheduledDateTime"]);
          return (scheduled.isAfter(start) ||
                  scheduled.isAtSameMomentAs(start)) &&
              scheduled.isBefore(end);
        }).toList();

        return {
          "label": "${index + 1}. H",
          "rate": calculateRate(weekLogs),
        };
      });
    }

    if (selectedRange == "Yearly") {
      return List.generate(12, (index) {
        final month = index + 1;

        final monthLogs = filteredLogs.where((log) {
          final scheduled = parseDate(log["scheduledDateTime"]);
          return scheduled.year == selectedDate.year &&
              scheduled.month == month;
        }).toList();

        return {
          "label": monthNames[index],
          "rate": calculateRate(monthLogs),
        };
      });
    }

    final monthCount = selectedRange == "SixMonths" ? 6 : 12;

    return List.generate(monthCount, (index) {
      final date = DateTime(
        now.year,
        now.month - (monthCount - 1 - index),
        1,
      );

      final monthLogs = filteredLogs.where((log) {
        final scheduled = parseDate(log["scheduledDateTime"]);
        return scheduled.year == date.year && scheduled.month == date.month;
      }).toList();

      return {
        "label": monthNames[date.month - 1],
        "rate": calculateRate(monthLogs),
      };
    });
  }

  String rangeText(String value) {
    if (value == "Daily") return "Günlük";
    if (value == "Weekly") return "Haftalık";
    if (value == "Monthly") return "Aylık";
    if (value == "SixMonths") return "6 Aylık";
    if (value == "Yearly") return "Yıllık";
    return value;
  }

  Widget rangeSelector() {
    final ranges = ["Daily", "Weekly", "Monthly", "SixMonths", "Yearly"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ranges.map((range) {
          final selected = selectedRange == range;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selected,
              label: Text(rangeText(range)),
              selectedColor: Colors.teal,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.teal,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: Colors.teal.shade50,
              onSelected: (_) {
                setState(() {
                  selectedRange = range;
                  selectedDate = DateTime.now();
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget periodNavigator() {
    return Row(
      children: [
        IconButton(
          onPressed: previousPeriod,
          icon: const Icon(Icons.chevron_left),
          color: Colors.teal,
        ),
        Expanded(
          child: Text(
            periodTitle(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        IconButton(
          onPressed: nextPeriod,
          icon: const Icon(Icons.chevron_right),
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget chartCard() {
    final data = chartData();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          const Text(
            "Zamanında Alma Oranı",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Seçilen dönemde ilaçları zamanında alma oranınız",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),
          periodNavigator(),
          const SizedBox(height: 12),
          GestureDetector(
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;

              if (velocity > 0) {
                previousPeriod();
              } else if (velocity < 0) {
                nextPeriod();
              }
            },
            child: SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: 100,
                  minY: 0,
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            "${value.toInt()}%",
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 34,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();

                          if (index < 0 || index >= data.length) {
                            return const SizedBox.shrink();
                          }

                          if (selectedRange == "Daily") {
                            if (![0, 6, 12, 18, 23].contains(index)) {
                              return const SizedBox.shrink();
                            }

                            final label = index == 23
                                ? "24"
                                : index.toString().padLeft(2, "0");

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                label,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              data[index]["label"],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(data.length, (index) {
                    final rate = data[index]["rate"] as double;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: rate,
                          width: selectedRange == "Daily"
                              ? 8
                              : selectedRange == "Yearly"
                                  ? 9
                                  : selectedRange == "SixMonths"
                                      ? 13
                                      : 16,
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.analytics, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "İlaç Takip Analizi",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  "%${onTimeRate.toStringAsFixed(0)} zamanında",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "$totalTaken kayıt incelendi",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget statBox({
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget logsList() {
    final sorted = [...filteredLogs];

    sorted.sort((a, b) {
      final aDate = parseDate(a["scheduledDateTime"]);
      final bDate = parseDate(b["scheduledDateTime"]);
      return bDate.compareTo(aDate);
    });

    final visibleLogs = sorted.take(10).toList();

    if (sorted.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Text(
          "Bu dönem için kayıt bulunamadı.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Column(
      children: visibleLogs.map((log) {
        final scheduled = parseDate(log["scheduledDateTime"]);
        final takenRaw = log["takenDateTime"];
        final taken = takenRaw == null ? null : parseDate(takenRaw);
        final medicationName = log["medicationName"] ?? "İlaç";

        final status = getStatus(log);

        final statusText = status == "Taken"
            ? "Zamanında"
            : status == "Late"
                ? "Geç"
                : status == "Missed"
                    ? "Alınmadı"
                    : "Bilinmiyor";

        final statusColor = status == "Taken"
            ? Colors.green
            : status == "Late"
                ? Colors.orange
                : status == "Missed"
                    ? Colors.red
                    : Colors.grey;

        final statusIcon = status == "Taken"
            ? Icons.check_circle
            : status == "Late"
                ? Icons.schedule
                : status == "Missed"
                    ? Icons.cancel
                    : Icons.help_outline;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicationName.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Planlanan: ${formatDateTime(scheduled)}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      "Alınan: ${taken == null ? "Yok" : formatDateTime(taken)}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

  String formatDateTime(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  Widget statsSection() {
    return Column(
      children: [
        Row(
          children: [
            statBox(
              icon: Icons.check_circle,
              title: "Zamanında",
              value: onTimeCount.toString(),
              color: Colors.green,
            ),
            const SizedBox(width: 12),
            statBox(
              icon: Icons.schedule,
              title: "Geç",
              value: lateCount.toString(),
              color: Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            statBox(
              icon: Icons.cancel,
              title: "Alınmadı",
              value: missedCount.toString(),
              color: Colors.red,
            ),
            const SizedBox(width: 12),
            statBox(
              icon: Icons.list_alt,
              title: "Toplam",
              value: totalTaken.toString(),
              color: Colors.teal,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("İlaç Analizi"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: Colors.teal,
              onRefresh: fetchLogs,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    summaryCard(),
                    const SizedBox(height: 18),
                    rangeSelector(),
                    const SizedBox(height: 18),
                    chartCard(),
                    const SizedBox(height: 18),
                    statsSection(),
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
                          "En Güncel 10 Kayıt",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    logsList(),
                  ],
                ),
              ),
            ),
    );
  }
}
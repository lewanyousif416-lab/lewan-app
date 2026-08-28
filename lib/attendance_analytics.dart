import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'l10n/app_localizations.dart';

class StudentAttendanceModel {
  final String studentId;
  final String studentName;
  final int attendedLessons;
  final int totalLessons;
  final double percentage;

  StudentAttendanceModel({
    required this.studentId,
    required this.studentName,
    required this.attendedLessons,
    required this.totalLessons,
    required this.percentage,
  });
}

class AttendanceAnalyticsPage extends StatefulWidget {
  const AttendanceAnalyticsPage({super.key});

  @override
  State<AttendanceAnalyticsPage> createState() =>
      _AttendanceAnalyticsPageState();
}

class _AttendanceAnalyticsPageState extends State<AttendanceAnalyticsPage> {
  DateTime selectedMonth = DateTime.now();

  Future<List<StudentAttendanceModel>> _fetchMonthlyAttendance() async {
    final startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final endOfMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      0,
      23,
      59,
      59,
    );

    // Get all attendance documents or subcollections
    QuerySnapshot snapshot;
    try {
      snapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .get();
    } catch (_) {
      snapshot = await FirebaseFirestore.instance
          .collectionGroup('records')
          .get();
    }

    Map<String, int> attendedMap = {};
    Map<String, String> namesMap = {};
    int totalLessonsInMonth = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Try parsing date from multiple common field types
      DateTime? docDate;
      if (data['date'] is Timestamp) {
        docDate = (data['date'] as Timestamp).toDate();
      } else if (data['createdAt'] is Timestamp) {
        docDate = (data['createdAt'] as Timestamp).toDate();
      } else if (data['date'] is String) {
        docDate = DateTime.tryParse(data['date']);
      }

      // If no date field exists, treat all records as part of current dataset
      bool isMatch =
          docDate == null ||
          (docDate.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
              docDate.isBefore(endOfMonth.add(const Duration(seconds: 1))));

      if (isMatch) {
        totalLessonsInMonth++;

        // Support multiple common field array formats
        List presentList =
            data['presentStudentIds'] ??
            data['present_students'] ??
            data['present'] ??
            data['students'] ??
            [];

        for (var item in presentList) {
          String id = item is Map
              ? (item['id'] ?? item['studentId'])
              : item.toString();
          attendedMap[id] = (attendedMap[id] ?? 0) + 1;
        }
      }
    }

    if (totalLessonsInMonth == 0) return [];

    // Fetch names from students collection
    final studentsSnapshot = await FirebaseFirestore.instance
        .collection('students')
        .get();
    for (var doc in studentsSnapshot.docs) {
      final sData = doc.data();
      namesMap[doc.id] = sData['name'] ?? 'Unnamed';
    }

    List<StudentAttendanceModel> results = [];
    attendedMap.forEach((id, attendedCount) {
      double percentage = (attendedCount / totalLessonsInMonth) * 100;
      results.add(
        StudentAttendanceModel(
          studentId: id,
          studentName: namesMap[id] ?? id,
          attendedLessons: attendedCount,
          totalLessons: totalLessonsInMonth,
          percentage: percentage,
        ),
      );
    });

    results.sort((a, b) => b.percentage.compareTo(a.percentage));
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isKurdish = Localizations.localeOf(context).languageCode == 'ckb';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.attendanceAnalyticsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    setState(() {
                      selectedMonth = DateTime(
                        selectedMonth.year,
                        selectedMonth.month - 1,
                      );
                    });
                  },
                ),
                Text(
                  '${selectedMonth.year} - ${selectedMonth.month}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    setState(() {
                      selectedMonth = DateTime(
                        selectedMonth.year,
                        selectedMonth.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<StudentAttendanceModel>>(
              future: _fetchMonthlyAttendance(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      isKurdish
                          ? 'هیچ داتایەک نەدۆزرایەوە بۆ ئەم مانگە'
                          : 'No data found for this month',
                    ),
                  );
                }

                final data = snapshot.data!;
                final topStudent = data.first;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        color: const Color(0xFF673AB7).withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                isKurdish
                                    ? 'بەرزترین ڕێژەی ئامادەبوون'
                                    : 'Most Attended Student',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${topStudent.studentName}: ${topStudent.percentage.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF673AB7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 100,
                            barTouchData: BarTouchData(enabled: true),
                            titlesData: FlTitlesData(
                              show: true,
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) =>
                                      Text('${value.toInt()}%'),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (index, meta) {
                                    int i = index.toInt();
                                    if (i >= 0 && i < data.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          data[i].studentName,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: const Border(
                                bottom: BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                                left: BorderSide(color: Colors.black, width: 2),
                              ),
                            ),
                            barGroups: data.asMap().entries.map((entry) {
                              int idx = entry.key;
                              var item = entry.value;
                              return BarChartGroupData(
                                x: idx,
                                barRods: [
                                  BarChartRodData(
                                    toY: item.percentage,
                                    color: idx == 0
                                        ? Colors.green
                                        : const Color(0xFF673AB7),
                                    width: 22,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

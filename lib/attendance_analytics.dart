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
    final yearStr = selectedMonth.year.toString();
    final paddedMonthStr = selectedMonth.month.toString().padLeft(2, '0');

    Map<String, int> attendedMap = {};
    Map<String, String> namesMap = {};
    Set<String> uniqueDatesInMonth = {};
    Set<String> allStudentIds = {};

    // 1. Fetch all registered students (Server first, fallback to Cache offline)
    try {
      QuerySnapshot<Map<String, dynamic>> studentsSnapshot;
      try {
        studentsSnapshot = await FirebaseFirestore.instance
            .collection('students')
            .get();
      } catch (_) {
        studentsSnapshot = await FirebaseFirestore.instance
            .collection('students')
            .get(const GetOptions(source: Source.cache));
      }

      for (var doc in studentsSnapshot.docs) {
        final sData = doc.data();
        final studentId = doc.id;
        namesMap[studentId] = sData['name'] ?? 'Unnamed';
        allStudentIds.add(studentId);
        attendedMap[studentId] = 0;
      }
    } catch (_) {}

    // 2. Fetch all attendance records (Server first, fallback to Cache offline)
    List<QueryDocumentSnapshot> docsList = [];
    try {
      QuerySnapshot groupSnap;
      try {
        groupSnap = await FirebaseFirestore.instance
            .collectionGroup('records')
            .get();
      } catch (_) {
        groupSnap = await FirebaseFirestore.instance
            .collectionGroup('records')
            .get(const GetOptions(source: Source.cache));
      }
      docsList = groupSnap.docs;
    } catch (_) {}

    for (var doc in docsList) {
      final data = doc.data() as Map<String, dynamic>;
      bool isCurrentSelectedMonth = false;
      DateTime? recordDate;

      if (data['date'] is Timestamp) {
        recordDate = (data['date'] as Timestamp).toDate();
        if (recordDate.year == selectedMonth.year &&
            recordDate.month == selectedMonth.month) {
          isCurrentSelectedMonth = true;
        }
      } else {
        final pathSegments = doc.reference.path.split('/');
        for (var segment in pathSegments) {
          if (segment.startsWith("$yearStr-$paddedMonthStr-") ||
              segment.startsWith("$yearStr-${selectedMonth.month}-")) {
            isCurrentSelectedMonth = true;
            try {
              List<String> parts = segment.split('-');
              if (parts.length >= 3) {
                recordDate = DateTime(
                  int.parse(parts[0]),
                  int.parse(parts[1]),
                  int.parse(parts[2]),
                );
              }
            } catch (_) {}
            break;
          }
        }
      }

      if (isCurrentSelectedMonth) {
        String dateKey = recordDate != null
            ? "${recordDate.year}-${recordDate.month}-${recordDate.day}"
            : doc.reference.path.split('/')[1];

        uniqueDatesInMonth.add(dateKey);

        final studentId = data['studentId']?.toString() ?? doc.id;
        final status = data['status']?.toString().toLowerCase() ?? '';
        final name = data['name']?.toString();

        if (name != null && name.isNotEmpty) {
          namesMap[studentId] = name;
        }

        allStudentIds.add(studentId);

        if (status == 'present' || status == '1' || status == 'true') {
          attendedMap[studentId] = (attendedMap[studentId] ?? 0) + 1;
        }
      }
    }

    int totalLessonsInMonth = uniqueDatesInMonth.length;

    if (totalLessonsInMonth == 0 && attendedMap.isNotEmpty) {
      totalLessonsInMonth = attendedMap.values.fold(
        0,
        (max, element) => element > max ? element : max,
      );
    }

    if (totalLessonsInMonth == 0) return [];

    List<StudentAttendanceModel> results = [];
    for (String id in allStudentIds) {
      int attendedCount = attendedMap[id] ?? 0;
      double percentage = (attendedCount / totalLessonsInMonth) * 100;

      results.add(
        StudentAttendanceModel(
          studentId: id,
          studentName: namesMap[id] ?? id,
          attendedLessons: attendedCount,
          totalLessons: totalLessonsInMonth,
          percentage: percentage > 100 ? 100 : percentage,
        ),
      );
    }

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
          // Month Selector Header
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

                // Get highest percentage score
                final double topPercentage = data.first.percentage;

                // Collect all students who tied for top score
                final topStudents = data
                    .where((student) => student.percentage == topPercentage)
                    .toList();

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
                                    ? (topStudents.length > 1
                                          ? 'بەرزترین ڕێژەی ئامادەبوون'
                                          : 'بەرزترین ڕێژەی ئامادەبوون')
                                    : (topStudents.length > 1
                                          ? 'Most Attended Students'
                                          : 'Most Attended Student'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Displays all top students separated by comma
                              Text(
                                '${topStudents.map((s) => s.studentName).join(', ')}: ${topPercentage.toStringAsFixed(1)}%',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
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
                                    color: item.percentage == topPercentage
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

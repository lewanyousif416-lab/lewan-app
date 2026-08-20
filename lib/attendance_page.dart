import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendancePage extends StatefulWidget {
  final int month; // 1 - 12
  final String monthName;

  const AttendancePage({Key? key, required this.month, required this.monthName})
    : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  static const int year = 2026;

  final CollectionReference studentsRef = FirebaseFirestore.instance.collection(
    'students',
  );

  // date string (yyyy-MM-dd) -> studentId -> status
  // This holds whatever is currently on screen (edited or not yet saved).
  Map<String, Map<String, String>> localStatuses = {};

  // Snapshot of what is actually saved in Firestore right now.
  Map<String, Map<String, String>> savedStatuses = {};

  bool loadingStatuses = true;
  bool saving = false;

  late List<DateTime> fridays;

  @override
  void initState() {
    super.initState();
    fridays = _computeFridays(widget.month, year);
    _loadExistingStatuses();
  }

  List<DateTime> _computeFridays(int month, int year) {
    final List<DateTime> result = [];
    final int daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      if (date.weekday == DateTime.friday) {
        result.add(date);
      }
    }
    return result;
  }

  String _dateKey(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return "${date.year}-$mm-$dd";
  }

  String _dateLabel(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return "Friday $dd/$mm/${date.year}";
  }

  Future<void> _loadExistingStatuses() async {
    final Map<String, Map<String, String>> loaded = {};

    for (final friday in fridays) {
      final key = _dateKey(friday);
      final snapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(key)
          .collection('records')
          .get();

      final Map<String, String> dayMap = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        dayMap[doc.id] = (data['status'] ?? '') as String;
      }
      loaded[key] = dayMap;
    }

    if (mounted) {
      setState(() {
        savedStatuses = loaded;
        // Deep copy so editing locally doesn't mutate savedStatuses.
        localStatuses = {
          for (final entry in loaded.entries)
            entry.key: Map<String, String>.from(entry.value),
        };
        loadingStatuses = false;
      });
    }
  }

  // Just updates what's on screen. No Firestore write here.
  void _selectStatus({
    required DateTime friday,
    required String studentId,
    required String status,
  }) {
    final key = _dateKey(friday);
    setState(() {
      localStatuses.putIfAbsent(key, () => {});
      localStatuses[key]![studentId] = status;
    });
  }

  // ignore: unused_element
  bool get _hasUnsavedChanges {
    for (final key in localStatuses.keys) {
      final local = localStatuses[key] ?? {};
      final saved = savedStatuses[key] ?? {};
      if (local.length != saved.length) return true;
      for (final studentId in local.keys) {
        if (local[studentId] != saved[studentId]) return true;
      }
    }
    return false;
  }

  Future<void> _saveAll(List<QueryDocumentSnapshot> students) async {
    setState(() => saving = true);

    try {
      final batch = FirebaseFirestore.instance.batch();

      // Build a lookup of studentId -> name for the write.
      final Map<String, String> nameById = {
        for (final doc in students)
          doc.id:
              ((doc.data() as Map<String, dynamic>)['name'] ?? 'Unknown')
                  as String,
      };

      for (final friday in fridays) {
        final key = _dateKey(friday);
        final dayMap = localStatuses[key] ?? {};

        for (final entry in dayMap.entries) {
          final studentId = entry.key;
          final status = entry.value;
          final studentName = nameById[studentId] ?? '';

          final docRef = FirebaseFirestore.instance
              .collection('attendance')
              .doc(key)
              .collection('records')
              .doc(studentId);

          batch.set(docRef, {
            // IMPORTANT: studentId is stored as a field (not just the doc
            // id) so we can find and delete a student's records later via
            // a collectionGroup query, even if the parent "attendance/{date}"
            // document was never directly written and doesn't show up in a
            // plain collection().get() call.
            'studentId': studentId,
            'name': studentName,
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();

      setState(() {
        savedStatuses = {
          for (final entry in localStatuses.entries)
            entry.key: Map<String, String>.from(entry.value),
        };
        saving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Attendance saved.")));
      }
    } catch (e) {
      setState(() => saving = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to save: $e")));
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'permission':
        return Colors.orange;
      default:
        return Colors.grey.shade400;
    }
  }

  Widget _statusChip({
    required String label,
    required String value,
    required String? currentStatus,
    required VoidCallback onTap,
  }) {
    final bool selected = currentStatus == value;
    final Color color = _statusColor(value);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: selected ? 0 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle,
              size: 10,
              color: selected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.monthName} $year"),
        backgroundColor: const Color(0xFF1B263B),
        centerTitle: true,
      ),
      body: loadingStatuses
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: studentsRef.orderBy('name').snapshots(),
              builder: (context, studentSnapshot) {
                if (studentSnapshot.hasError) {
                  return Center(child: Text("Error: ${studentSnapshot.error}"));
                }
                if (!studentSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final students = studentSnapshot.data!.docs;

                if (students.isEmpty) {
                  return const Center(child: Text("No students found."));
                }

                if (fridays.isEmpty) {
                  return const Center(child: Text("No Fridays in this month."));
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: fridays.length,
                        itemBuilder: (context, index) {
                          final friday = fridays[index];
                          final key = _dateKey(friday);
                          final dayStatuses = localStatuses[key] ?? {};

                          return Card(
                            margin: const EdgeInsets.only(bottom: 18),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _dateLabel(friday),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B263B),
                                    ),
                                  ),
                                  const Divider(height: 20),
                                  ...students.map((studentDoc) {
                                    final data =
                                        studentDoc.data()
                                            as Map<String, dynamic>;
                                    final studentId = studentDoc.id;
                                    final studentName =
                                        (data['name'] ?? 'Unknown') as String;
                                    final currentStatus =
                                        dayStatuses[studentId];

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            studentName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              _statusChip(
                                                label: "Present",
                                                value: "present",
                                                currentStatus: currentStatus,
                                                onTap: () => _selectStatus(
                                                  friday: friday,
                                                  studentId: studentId,
                                                  status: "present",
                                                ),
                                              ),
                                              _statusChip(
                                                label: "Absent",
                                                value: "absent",
                                                currentStatus: currentStatus,
                                                onTap: () => _selectStatus(
                                                  friday: friday,
                                                  studentId: studentId,
                                                  status: "absent",
                                                ),
                                              ),
                                              _statusChip(
                                                label: "Permission",
                                                value: "permission",
                                                currentStatus: currentStatus,
                                                onTap: () => _selectStatus(
                                                  friday: friday,
                                                  studentId: studentId,
                                                  status: "permission",
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          if (index != students.length - 1)
                                            const Divider(height: 20),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom Save bar
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: saving ? null : () => _saveAll(students),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B263B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save, color: Colors.white),
                            label: Text(
                              saving ? "Saving..." : "Save Attendance",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

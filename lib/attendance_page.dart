import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'l10n/app_localizations.dart';

class AttendancePage extends StatefulWidget {
  final int month;
  final String monthName;

  const AttendancePage({
    super.key,
    required this.month,
    required this.monthName,
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  static const int year = 2026;

  final CollectionReference studentsRef = FirebaseFirestore.instance.collection(
    'students',
  );

  Map<String, Map<String, String>> localStatuses = {};
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

  String _dateLabel(DateTime date, AppLocalizations l10n) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return l10n.fridayDateLabel("$dd/$mm/${date.year}");
  }

  Future<void> _loadExistingStatuses() async {
    final Map<String, Map<String, String>> loaded = {};

    for (final friday in fridays) {
      final key = _dateKey(friday);
      final dayMap = <String, String>{};

      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        // Attempt normal fetch (Server + Cache)
        snapshot = await FirebaseFirestore.instance
            .collection('attendance')
            .doc(key)
            .collection('records')
            .get();
      } catch (_) {
        // Fallback directly to local cache when offline
        try {
          snapshot = await FirebaseFirestore.instance
              .collection('attendance')
              .doc(key)
              .collection('records')
              .get(const GetOptions(source: Source.cache));
        } catch (_) {
          loaded[key] = {};
          continue;
        }
      }

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = (data['status'] ?? '').toString();
        if (status.isNotEmpty) {
          dayMap[doc.id] = status;
        }
      }
      loaded[key] = dayMap;
    }

    if (mounted) {
      setState(() {
        savedStatuses = loaded;
        localStatuses = {
          for (final entry in loaded.entries)
            entry.key: Map<String, String>.from(entry.value),
        };
        loadingStatuses = false;
      });
    }
  }

  Future<void> _selectStatus({
    required DateTime friday,
    required String studentId,
    required String studentName,
    required String status,
  }) async {
    final key = _dateKey(friday);

    final currentSelected = localStatuses[key]?[studentId];
    final isDeselecting = currentSelected == status;

    setState(() {
      localStatuses.putIfAbsent(key, () => {});
      savedStatuses.putIfAbsent(key, () => {});

      if (isDeselecting) {
        localStatuses[key]!.remove(studentId);
        savedStatuses[key]!.remove(studentId);
      } else {
        localStatuses[key]![studentId] = status;
        savedStatuses[key]![studentId] = status;
      }
    });

    final docRef = FirebaseFirestore.instance
        .collection('attendance')
        .doc(key)
        .collection('records')
        .doc(studentId);

    if (isDeselecting) {
      docRef.delete().catchError((_) {});
    } else {
      docRef
          .set({
            'studentId': studentId,
            'name': studentName,
            'status': status,
            'date': Timestamp.fromDate(friday),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .catchError((_) {});
    }
  }

  Future<void> _saveAll(List<QueryDocumentSnapshot> students) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => saving = true);

    try {
      final batch = FirebaseFirestore.instance.batch();

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

          if (status.isEmpty) {
            batch.delete(docRef);
          } else {
            batch.set(docRef, {
              'studentId': studentId,
              'name': studentName,
              'status': status,
              'date': Timestamp.fromDate(friday),
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
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
        ).showSnackBar(SnackBar(content: Text(l10n.attendanceSaved)));
      }
    } catch (e) {
      setState(() => saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToSave(e.toString()))),
        );
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

  Widget _statusSummaryBadge({
    required String status,
    required String label,
    required Map<String, String> dayStatuses,
    required List<QueryDocumentSnapshot> students,
    required void Function() onTap,
  }) {
    final color = _statusColor(status);
    final count = dayStatuses.values.where((s) => s == status).length;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 8, color: color),
            const SizedBox(width: 6),
            Text(
              "$count $label",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusListDialog({
    required BuildContext context,
    required String status,
    required Map<String, String> dayStatuses,
    required List<QueryDocumentSnapshot> students,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final matchingNames = <String>[];

    for (final studentDoc in students) {
      final data = studentDoc.data() as Map<String, dynamic>;
      final studentId = studentDoc.id;
      final studentName = (data['name'] ?? 'Unknown') as String;
      if (dayStatuses[studentId] == status) {
        matchingNames.add(studentName);
      }
    }

    String title;
    switch (status) {
      case 'present':
        title = l10n.presentStudentsTitle;
        break;
      case 'absent':
        title = l10n.absentStudentsTitle;
        break;
      default:
        title = l10n.permissionStudentsTitle;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: matchingNames.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(l10n.noStudentsWithStatus),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: matchingNames.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(status),
                      child: Text(
                        matchingNames[index].isNotEmpty
                            ? matchingNames[index][0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(matchingNames[index]),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.monthName} $year"),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: loadingStatuses
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: studentsRef.orderBy('name').snapshots(),
              builder: (context, studentSnapshot) {
                if (studentSnapshot.hasError) {
                  return Center(
                    child: Text(l10n.error(studentSnapshot.error.toString())),
                  );
                }
                if (!studentSnapshot.hasData &&
                    studentSnapshot.connectionState ==
                        ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final students = studentSnapshot.data?.docs ?? [];

                if (students.isEmpty) {
                  return Center(child: Text(l10n.noStudentsFound));
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
                                    _dateLabel(friday, l10n),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF673AB7),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    children: [
                                      _statusSummaryBadge(
                                        status: "present",
                                        label: l10n.present,
                                        dayStatuses: dayStatuses,
                                        students: students,
                                        onTap: () => _showStatusListDialog(
                                          context: context,
                                          status: "present",
                                          dayStatuses: dayStatuses,
                                          students: students,
                                        ),
                                      ),
                                      _statusSummaryBadge(
                                        status: "absent",
                                        label: l10n.absent,
                                        dayStatuses: dayStatuses,
                                        students: students,
                                        onTap: () => _showStatusListDialog(
                                          context: context,
                                          status: "absent",
                                          dayStatuses: dayStatuses,
                                          students: students,
                                        ),
                                      ),
                                      _statusSummaryBadge(
                                        status: "permission",
                                        label: l10n.permission,
                                        dayStatuses: dayStatuses,
                                        students: students,
                                        onTap: () => _showStatusListDialog(
                                          context: context,
                                          status: "permission",
                                          dayStatuses: dayStatuses,
                                          students: students,
                                        ),
                                      ),
                                    ],
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
                                                label: l10n.present,
                                                value: "present",
                                                currentStatus: currentStatus,
                                                onTap: () => _selectStatus(
                                                  friday: friday,
                                                  studentId: studentId,
                                                  studentName: studentName,
                                                  status: "present",
                                                ),
                                              ),
                                              _statusChip(
                                                label: l10n.absent,
                                                value: "absent",
                                                currentStatus: currentStatus,
                                                onTap: () => _selectStatus(
                                                  friday: friday,
                                                  studentId: studentId,
                                                  studentName: studentName,
                                                  status: "absent",
                                                ),
                                              ),
                                              _statusChip(
                                                label: l10n.permission,
                                                value: "permission",
                                                currentStatus: currentStatus,
                                                onTap: () => _selectStatus(
                                                  friday: friday,
                                                  studentId: studentId,
                                                  studentName: studentName,
                                                  status: "permission",
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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
                              backgroundColor: const Color(0xFF673AB7),
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
                              saving ? l10n.saving : l10n.saveAttendance,
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

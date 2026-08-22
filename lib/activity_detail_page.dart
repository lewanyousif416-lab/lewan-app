import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityDetailPage extends StatefulWidget {
  final String activityId;
  final String activityTitle;

  const ActivityDetailPage({
    super.key,
    required this.activityId,
    required this.activityTitle,
  });

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  // studentId -> selected answer ("yes" / "no" / null if not chosen yet)
  final Map<String, String?> _gradeAnswers = {};
  bool isSaving = false;

  Future<void> saveGrades(List<QueryDocumentSnapshot> students) async {
    setState(() => isSaving = true);
    try {
      final batch = FirebaseFirestore.instance.batch();

      for (var student in students) {
        final studentId = student.id;
        final answer = _gradeAnswers[studentId];
        if (answer != null) {
          final gradeRef = FirebaseFirestore.instance
              .collection('activities_list')
              .doc(widget.activityId)
              .collection('grades')
              .doc(studentId);

          batch.set(gradeRef, {
            'studentId': studentId,
            'studentName':
                (student.data() as Map<String, dynamic>)['name'] ?? 'Unknown',
            'activityId': widget.activityId, // Added activity ID
            'activityTitle': widget.activityTitle, // Added activity name
            'score': answer,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Grades saved successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving: $e")));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Widget _answerChip({
    required String label,
    required String value,
    required String? currentAnswer,
    required VoidCallback onTap,
  }) {
    final bool selected = currentAnswer == value;
    final Color color = value == 'yes' ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: selected ? 0 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activityTitle),
        backgroundColor: const Color(0xFF673AB7), // Deep Purple 500
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, studentSnapshot) {
          if (!studentSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = studentSnapshot.data!.docs;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('activities_list')
                .doc(widget.activityId)
                .collection('grades')
                .snapshots(),
            builder: (context, gradeSnapshot) {
              if (gradeSnapshot.hasData) {
                for (var gradeDoc in gradeSnapshot.data!.docs) {
                  final data = gradeDoc.data() as Map<String, dynamic>;
                  final studentId = gradeDoc.id;
                  if (!_gradeAnswers.containsKey(studentId)) {
                    final existing = data['score'];
                    _gradeAnswers[studentId] =
                        (existing == 'yes' || existing == 'no')
                        ? existing as String
                        : null;
                  }
                }
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final studentDoc = students[index];
                        final studentData =
                            studentDoc.data() as Map<String, dynamic>;
                        final studentId = studentDoc.id;
                        final studentName = studentData['name'] ?? 'Unnamed';

                        _gradeAnswers.putIfAbsent(studentId, () => null);
                        final currentAnswer = _gradeAnswers[studentId];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    studentName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    _answerChip(
                                      label: "Yes",
                                      value: "yes",
                                      currentAnswer: currentAnswer,
                                      onTap: () {
                                        setState(() {
                                          _gradeAnswers[studentId] = "yes";
                                        });
                                      },
                                    ),
                                    _answerChip(
                                      label: "No",
                                      value: "no",
                                      currentAnswer: currentAnswer,
                                      onTap: () {
                                        setState(() {
                                          _gradeAnswers[studentId] = "no";
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF673AB7),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: isSaving ? null : () => saveGrades(students),
                        child: isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Save All Grades"),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

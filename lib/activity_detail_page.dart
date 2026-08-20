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
  final Map<String, TextEditingController> _gradeControllers = {};
  bool isSaving = false;

  @override
  void dispose() {
    for (var controller in _gradeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> saveGrades(List<QueryDocumentSnapshot> students) async {
    setState(() => isSaving = true);
    try {
      final batch = FirebaseFirestore.instance.batch();

      for (var student in students) {
        final studentId = student.id;
        final controller = _gradeControllers[studentId];
        if (controller != null && controller.text.trim().isNotEmpty) {
          final score = double.tryParse(controller.text.trim()) ?? 0.0;

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
            'score': score,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.activityTitle)),
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
                  if (!_gradeControllers.containsKey(studentId)) {
                    _gradeControllers[studentId] = TextEditingController(
                      text: data['score']?.toString() ?? '',
                    );
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

                        _gradeControllers.putIfAbsent(
                          studentId,
                          () => TextEditingController(),
                        );

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
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: _gradeControllers[studentId],
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "Score",
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
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

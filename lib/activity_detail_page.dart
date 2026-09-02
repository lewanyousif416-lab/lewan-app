import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'l10n/app_localizations.dart';

class ActivityDetailPage extends StatelessWidget {
  final String activityId;
  final String activityTitle;

  const ActivityDetailPage({
    super.key,
    required this.activityId,
    required this.activityTitle,
  });

  CollectionReference get _gradesRef => FirebaseFirestore.instance
      .collection('activities_list')
      .doc(activityId)
      .collection('grades');

  Future<void> _removeStudent(
    BuildContext context,
    String studentId,
    String studentName,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeStudentTitle),
        content: Text(l10n.removeStudentContent(studentName, activityTitle)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Direct deletion works offline immediately in local Firestore cache
    _gradesRef.doc(studentId).delete().catchError((_) {});
  }

  Future<void> _setStudentScore(
    String studentId,
    String studentName,
    String score,
  ) async {
    _gradesRef
        .doc(studentId)
        .set({
          'studentId': studentId,
          'studentName': studentName,
          'activityId': activityId,
          'activityTitle': activityTitle,
          'score': score,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        .catchError((_) {});
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(activityTitle),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _gradesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text(
                l10n.noStudentsAddedYet,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final studentId = doc.id;
              final studentName =
                  data['studentName'] ?? data['name'] ?? 'Unknown';
              final score = data['score'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
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
                            label: l10n.yes,
                            value: "yes",
                            currentAnswer: score,
                            onTap: () =>
                                _setStudentScore(studentId, studentName, "yes"),
                          ),
                          _answerChip(
                            label: l10n.no,
                            value: "no",
                            currentAnswer: score,
                            onTap: () =>
                                _setStudentScore(studentId, studentName, "no"),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 20,
                            ),
                            tooltip: l10n.delete,
                            onPressed: () =>
                                _removeStudent(context, studentId, studentName),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

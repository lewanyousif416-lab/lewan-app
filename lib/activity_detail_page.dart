import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'l10n/app_localizations.dart';

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
  bool _isSaving = false;
  final Map<String, String?> _localScores = {};

  CollectionReference get _gradesRef => FirebaseFirestore.instance
      .collection('activities_list')
      .doc(widget.activityId)
      .collection('grades');

  Future<void> _openAddStudentDialog(
    List<QueryDocumentSnapshot> currentDocs,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final existingIds = currentDocs.map((d) => d.id).toSet();

    QuerySnapshot studentsSnapshot;
    try {
      studentsSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .orderBy('name')
          .get();
    } catch (_) {
      try {
        studentsSnapshot = await FirebaseFirestore.instance
            .collection('students')
            .orderBy('name')
            .get(const GetOptions(source: Source.cache));
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.noStudentsFound)));
        return;
      }
    }

    final available = studentsSnapshot.docs
        .where((doc) => !existingIds.contains(doc.id))
        .toList();

    if (!mounted) return;

    if (available.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.allStudentsAlreadyAdded)));
      return;
    }

    final Set<String> selectedIds = {};

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          l10n.addStudentsSheetTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: available.length,
                          itemBuilder: (context, index) {
                            final doc = available[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final name = (data['name'] ?? 'Unknown') as String;
                            final isSelected = selectedIds.contains(doc.id);

                            return CheckboxListTile(
                              secondary: CircleAvatar(
                                backgroundColor: const Color(0xFF673AB7),
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(name),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setModalState(() {
                                  if (value == true) {
                                    selectedIds.add(doc.id);
                                  } else {
                                    selectedIds.remove(doc.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF673AB7),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: selectedIds.isEmpty
                                ? null
                                : () => Navigator.pop(context),
                            child: Text(
                              l10n.addSelected(selectedIds.length),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (selectedIds.isEmpty) return;

    // Batch commit works offline immediately in local Firestore cache
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in available) {
      if (selectedIds.contains(doc.id)) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] ?? 'Unknown') as String;

        final docRef = _gradesRef.doc(doc.id);
        batch.set(docRef, {
          'studentId': doc.id,
          'studentName': name,
          'activityId': widget.activityId,
          'activityTitle': widget.activityTitle,
          'score': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
    await batch.commit();
  }

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
        content: Text(
          l10n.removeStudentContent(studentName, widget.activityTitle),
        ),
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

    setState(() {
      _localScores.remove(studentId);
    });

    // Direct deletion works offline immediately in local Firestore cache
    _gradesRef.doc(studentId).delete().catchError((_) {});
  }

  Future<void> _setStudentScore(
    String studentId,
    String studentName,
    String score,
  ) async {
    setState(() {
      _localScores[studentId] = score;
    });

    _gradesRef
        .doc(studentId)
        .set({
          'studentId': studentId,
          'studentName': studentName,
          'activityId': widget.activityId,
          'activityTitle': widget.activityTitle,
          'score': score,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        .catchError((_) {});
  }

  Future<void> _saveAllGrades(List<QueryDocumentSnapshot> docs) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);

    try {
      final batch = FirebaseFirestore.instance.batch();

      for (final doc in docs) {
        final studentId = doc.id;
        final data = doc.data() as Map<String, dynamic>;
        final studentName = data['studentName'] ?? data['name'] ?? 'Unknown';
        final score = _localScores.containsKey(studentId)
            ? _localScores[studentId]
            : data['score'];

        final docRef = _gradesRef.doc(studentId);
        batch.set(docRef, {
          'studentId': studentId,
          'studentName': studentName,
          'activityId': widget.activityId,
          'activityTitle': widget.activityTitle,
          'score': score,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.gradesSavedSuccessfully)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorSaving(e.toString()))));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
          color: selected ? color : color.withValues(alpha: 0.12),
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

    return StreamBuilder<QuerySnapshot>(
      stream: _gradesRef.snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.activityTitle),
            backgroundColor: const Color(0xFF673AB7),
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add, color: Colors.white),
                tooltip: l10n.addStudentsButton,
                onPressed: () => _openAddStudentDialog(docs),
              ),
            ],
          ),
          body:
              snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData
              ? const Center(child: CircularProgressIndicator())
              : docs.isEmpty
              ? Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.person_add_alt,
                              size: 50,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.noStudentsAddedYet,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => _openAddStudentDialog(docs),
                              icon: const Icon(Icons.person_add),
                              label: Text(l10n.addStudentsButton),
                            ),
                          ],
                        ),
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF673AB7),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _openAddStudentDialog(docs),
                            icon: const Icon(
                              Icons.person_add,
                              color: Colors.white,
                            ),
                            label: Text(
                              l10n.addStudentsButton,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final studentId = doc.id;
                          final studentName =
                              data['studentName'] ?? data['name'] ?? 'Unknown';
                          final score = _localScores.containsKey(studentId)
                              ? _localScores[studentId]
                              : data['score'];

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
                                        onTap: () => _setStudentScore(
                                          studentId,
                                          studentName,
                                          "yes",
                                        ),
                                      ),
                                      _answerChip(
                                        label: l10n.no,
                                        value: "no",
                                        currentAnswer: score,
                                        onTap: () => _setStudentScore(
                                          studentId,
                                          studentName,
                                          "no",
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                        tooltip: l10n.delete,
                                        onPressed: () => _removeStudent(
                                          context,
                                          studentId,
                                          studentName,
                                        ),
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
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF673AB7),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isSaving
                                ? null
                                : () => _saveAllGrades(docs),
                            icon: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save, color: Colors.white),
                            label: Text(
                              _isSaving ? l10n.saving : l10n.saveAllGrades,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

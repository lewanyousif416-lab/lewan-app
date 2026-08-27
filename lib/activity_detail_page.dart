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

class _ActivityStudentEntry {
  final String name;
  String? score; // 'yes', 'no', or null

  _ActivityStudentEntry({
    required this.name,
    this.score,
  });
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  final Map<String, _ActivityStudentEntry> entries = {};

  bool loading = true;
  bool isSaving = false;

  CollectionReference get _gradesRef => FirebaseFirestore.instance
      .collection('activities_list')
      .doc(widget.activityId)
      .collection('grades');

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    QuerySnapshot snapshot;
    try {
      snapshot = await _gradesRef.get(const GetOptions(source: Source.cache));
    } catch (_) {
      try {
        snapshot = await _gradesRef
            .get()
            .timeout(const Duration(milliseconds: 1000));
      } catch (_) {
        if (mounted) setState(() => loading = false);
        return;
      }
    }

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final rawScore = data['score'];
      entries[doc.id] = _ActivityStudentEntry(
        name: (data['studentName'] ?? data['name'] ?? 'Unknown') as String,
        score: (rawScore == 'yes' || rawScore == 'no') ? rawScore as String : null,
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> _openAddStudentDialog() async {
    final l10n = AppLocalizations.of(context)!;
    QuerySnapshot studentsSnapshot;
    try {
      studentsSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .orderBy('name')
          .get(const GetOptions(source: Source.cache));
    } catch (_) {
      try {
        studentsSnapshot = await FirebaseFirestore.instance
            .collection('students')
            .orderBy('name')
            .get()
            .timeout(const Duration(milliseconds: 1000));
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noStudentsFound)),
        );
        return;
      }
    }

    // Only offer students not already added to this activity
    final available = studentsSnapshot.docs
        .where((doc) => !entries.containsKey(doc.id))
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
                                  style: const TextStyle(color: Colors.white),
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

    // Add all selected students into the entries map and auto-save
    setState(() {
      for (final doc in available) {
        if (selectedIds.contains(doc.id)) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? 'Unknown') as String;

          entries[doc.id] = _ActivityStudentEntry(
            name: name,
            score: null,
          );

          // Auto-persist new student entry to Firestore
          _gradesRef.doc(doc.id).set({
            'studentId': doc.id,
            'studentName': name,
            'activityId': widget.activityId,
            'activityTitle': widget.activityTitle,
            'score': null,
            'updatedAt': DateTime.now().toIso8601String(),
          }).catchError((_) {});
        }
      }
    });
  }

  Future<void> _removeStudent(String studentId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeStudentTitle),
        content: Text(
          l10n.removeStudentContent(
            entries[studentId]?.name ?? '',
            widget.activityTitle,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _gradesRef.doc(studentId).delete();
    } catch (_) {}

    setState(() {
      entries.remove(studentId);
    });
  }

  Future<void> _setStudentScore(String studentId, String score) async {
    final entry = entries[studentId];
    if (entry == null) return;

    setState(() {
      entry.score = score;
    });

    try {
      await _gradesRef.doc(studentId).set({
        'studentId': studentId,
        'studentName': entry.name,
        'activityId': widget.activityId,
        'activityTitle': widget.activityTitle,
        'score': score,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  Future<void> saveGrades() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => isSaving = true);
    try {
      final batch = FirebaseFirestore.instance.batch();

      for (final entry in entries.entries) {
        final studentId = entry.key;
        final studentEntry = entry.value;

        final gradeDocRef = _gradesRef.doc(studentId);

        batch.set(gradeDocRef, {
          'studentId': studentId,
          'studentName': studentEntry.name,
          'activityId': widget.activityId,
          'activityTitle': widget.activityTitle,
          'score': studentEntry.score,
          'updatedAt': DateTime.now().toIso8601String(),
        });
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
    final studentIds = entries.keys.toList();

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
            onPressed: loading ? null : _openAddStudentDialog,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: studentIds.isEmpty
                      ? Center(
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
                                onPressed: _openAddStudentDialog,
                                icon: const Icon(Icons.person_add),
                                label: Text(l10n.addStudentsButton),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: studentIds.length,
                          itemBuilder: (context, index) {
                            final studentId = studentIds[index];
                            final entry = entries[studentId]!;

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
                                        entry.name,
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
                                          currentAnswer: entry.score,
                                          onTap: () => _setStudentScore(
                                            studentId,
                                            "yes",
                                          ),
                                        ),
                                        _answerChip(
                                          label: l10n.no,
                                          value: "no",
                                          currentAnswer: entry.score,
                                          onTap: () => _setStudentScore(
                                            studentId,
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
                                          onPressed: () =>
                                              _removeStudent(studentId),
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
                if (studentIds.isNotEmpty)
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF673AB7),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isSaving ? null : saveGrades,
                          child: isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  l10n.saveAllGrades,
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
  }
}

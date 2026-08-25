import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'l10n/app_localizations.dart';

class EditDeleteStudentPage extends StatefulWidget {
  final QueryDocumentSnapshot student;

  const EditDeleteStudentPage({super.key, required this.student});

  @override
  State<EditDeleteStudentPage> createState() => _EditDeleteStudentPageState();
}

class _EditDeleteStudentPageState extends State<EditDeleteStudentPage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController locationController;
  late TextEditingController ageController;

  // Canonical keys — must match add_student.dart so saved data round-trips
  // correctly regardless of which language was active when it was written.
  static const List<String> educationKeys = ["diploma", "bachelor"];
  static const List<String> maritalKeys = ["married", "single"];

  String? selectedEducation;
  String? selectedMaritalStatus;

  bool isSaving = false;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();

    final data = widget.student.data() as Map<String, dynamic>;

    nameController = TextEditingController(text: data["name"] ?? "");
    phoneController = TextEditingController(text: data["phone"] ?? "");
    locationController = TextEditingController(text: data["location"] ?? "");
    ageController = TextEditingController(text: data["age"]?.toString() ?? "");

    final existingEducation = data["education"];
    if (educationKeys.contains(existingEducation)) {
      selectedEducation = existingEducation;
    }

    final existingMaritalStatus = data["maritalStatus"];
    if (maritalKeys.contains(existingMaritalStatus)) {
      selectedMaritalStatus = existingMaritalStatus;
    }
  }

  String _educationLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case "twelfth":
        return l10n.educationTwelfthGrade;
      case "diploma":
        return l10n.educationDiploma;
      case "bachelor":
        return l10n.educationBachelor;
    }
    return key;
  }

  String _maritalLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case "married":
        return l10n.maritalMarried;
      case "single":
        return l10n.maritalSingle;
    }
    return key;
  }

  Future<void> updateStudent() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection("students")
          .doc(widget.student.id)
          .update({
            "name": nameController.text.trim(),
            "phone": phoneController.text.trim(),
            "location": locationController.text.trim(),
            "age": ageController.text.trim(),
            "education": selectedEducation,
            "maritalStatus": selectedMaritalStatus,
          });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.studentUpdated)));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.failedToUpdate(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> deleteStudent() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteStudentTitle),
        content: Text(l10n.deleteStudentEditContent),
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

    setState(() => isDeleting = true);

    try {
      final studentId = widget.student.id;

      // Fetch all records using collection group query
      final recordsSnapshot = await FirebaseFirestore.instance
          .collectionGroup('records')
          .get();

      final batch = FirebaseFirestore.instance.batch();

      for (final doc in recordsSnapshot.docs) {
        if (doc.id == studentId) {
          batch.delete(doc.reference);
        }
      }

      // Delete the student document itself
      batch.delete(
        FirebaseFirestore.instance.collection("students").doc(studentId),
      );

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.studentDeletedSuccessfully)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = l10n.failedToDelete(e.toString());
        if (e.toString().contains("permission-denied")) {
          errorMessage = l10n.permissionDeniedMessage;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      if (mounted) setState(() => isDeleting = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    locationController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editStudentTitle)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.nameLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: l10n.phoneLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: l10n.locationLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.ageLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedEducation,
              decoration: InputDecoration(
                labelText: l10n.educationLabel,
                border: const OutlineInputBorder(),
              ),
              items: educationKeys
                  .map(
                    (key) => DropdownMenuItem(
                      value: key,
                      child: Text(_educationLabel(l10n, key)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => selectedEducation = value);
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedMaritalStatus,
              decoration: InputDecoration(
                labelText: l10n.maritalStatusLabel,
                border: const OutlineInputBorder(),
              ),
              items: maritalKeys
                  .map(
                    (key) => DropdownMenuItem(
                      value: key,
                      child: Text(_maritalLabel(l10n, key)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => selectedMaritalStatus = value);
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (isSaving || isDeleting) ? null : updateStudent,
                child: isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.update),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: (isSaving || isDeleting) ? null : deleteStudent,
                child: isDeleting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.deleteStudentButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
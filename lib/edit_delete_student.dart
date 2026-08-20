import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  static const List<String> educationOptions = ["Diploma", "Bachelor's Degree"];
  static const List<String> maritalStatusOptions = ["Married", "Single"];

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
    if (educationOptions.contains(existingEducation)) {
      selectedEducation = existingEducation;
    }

    final existingMaritalStatus = data["maritalStatus"];
    if (maritalStatusOptions.contains(existingMaritalStatus)) {
      selectedMaritalStatus = existingMaritalStatus;
    }
  }

  Future<void> updateStudent() async {
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
        ).showSnackBar(const SnackBar(content: Text("Student Updated")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update: $e")));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> deleteStudent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Student"),
        content: const Text(
          "Are you sure you want to delete this student? This also removes all of their associated records.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
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
          const SnackBar(content: Text("Student Deleted Successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = "Failed to delete: $e";
        if (e.toString().contains("permission-denied")) {
          errorMessage =
              "Permission denied: Ensure you are logged in with an admin account.";
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
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Student")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "Location",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Age",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedEducation,
              decoration: const InputDecoration(
                labelText: "Education",
                border: OutlineInputBorder(),
              ),
              items: educationOptions
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => selectedEducation = value);
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedMaritalStatus,
              decoration: const InputDecoration(
                labelText: "Marital Status",
                border: OutlineInputBorder(),
              ),
              items: maritalStatusOptions
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
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
                    : const Text("Update"),
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
                    : const Text("Delete Student"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

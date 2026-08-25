import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'l10n/app_localizations.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  // Canonical (language-independent) keys stored in Firestore.
  // Only the on-screen label is translated.
  static const List<String> educationKeys = ["twelfth", "diploma", "bachelor"];
  static const List<String> maritalKeys = ["married", "single"];

  String? selectedEducation;
  String? selectedMaritalStatus;

  bool isLoading = false;

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

  Future<void> saveStudent() async {
    final l10n = AppLocalizations.of(context)!;
    // Check all fields
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        ageController.text.trim().isEmpty ||
        selectedEducation == null ||
        selectedMaritalStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseFillAllFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Save student to Firestore
      await FirebaseFirestore.instance.collection("students").add({
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "location": locationController.text.trim(),
        "age": ageController.text.trim(),
        "education": selectedEducation,
        "maritalStatus": selectedMaritalStatus,
        "createdAt": FieldValue.serverTimestamp(),
      });

      // Clear all text fields
      nameController.clear();
      phoneController.clear();
      locationController.clear();
      ageController.clear();

      // Clear dropdown selections
      setState(() {
        selectedEducation = null;
        selectedMaritalStatus = null;
        isLoading = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.studentAddedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorGeneric(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      appBar: AppBar(
        title: Text(l10n.addStudentTitle),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Student Name
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.studentNameLabel,
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Phone Number
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.phoneNumberLabel,
                prefixIcon: const Icon(Icons.phone),
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Location
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: l10n.locationLabel,
                prefixIcon: const Icon(Icons.location_on),
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Age
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.ageLabel,
                prefixIcon: const Icon(Icons.numbers),
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Education
            DropdownButtonFormField<String>(
              value: selectedEducation,
              decoration: InputDecoration(
                labelText: l10n.educationLabel,
                prefixIcon: const Icon(Icons.school),
                border: const OutlineInputBorder(),
              ),
              items: educationKeys.map((key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(_educationLabel(l10n, key)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedEducation = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // Marital Status
            DropdownButtonFormField<String>(
              value: selectedMaritalStatus,
              decoration: InputDecoration(
                labelText: l10n.maritalStatusLabel,
                prefixIcon: const Icon(Icons.person_pin_circle),
                border: const OutlineInputBorder(),
              ),
              items: maritalKeys.map((key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(_maritalLabel(l10n, key)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMaritalStatus = value;
                });
              },
            ),

            const SizedBox(height: 30),

            // Save Student Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        l10n.saveStudent,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  static const List<String> educationOptions = [
    "Diploma 's Degree",
    "Bachelor's Degree",
  ];

  static const List<String> maritalStatusOptions = ["Married", "Single"];

  String? selectedEducation;
  String? selectedMaritalStatus;

  bool isLoading = false;

  Future<void> saveStudent() async {
    // Check all fields
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        ageController.text.trim().isEmpty ||
        selectedEducation == null ||
        selectedMaritalStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Student Added Successfully"),
          backgroundColor: Colors.green,
        ),
      );

      // IMPORTANT:
      // Do NOT use Navigator.pop(context)
      // The page stays open so you can add another student.
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
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
      appBar: AppBar(
        title: const Text("Add Student"),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,

        // Back button still works when YOU want to leave the page
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
              decoration: const InputDecoration(
                labelText: "Student Name",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Phone Number
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Location
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "Location",
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Age
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Age",
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Education
            DropdownButtonFormField<String>(
              value: selectedEducation,
              decoration: const InputDecoration(
                labelText: "Education",
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(),
              ),
              items: educationOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
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
              decoration: const InputDecoration(
                labelText: "Marital Status",
                prefixIcon: Icon(Icons.person_pin_circle),
                border: OutlineInputBorder(),
              ),
              items: maritalStatusOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
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
                    : const Text(
                        "Save Student",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

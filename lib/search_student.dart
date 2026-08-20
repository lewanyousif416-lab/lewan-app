import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchStudentPage extends StatefulWidget {
  const SearchStudentPage({super.key});

  @override
  State<SearchStudentPage> createState() => _SearchStudentPageState();
}

class _SearchStudentPageState extends State<SearchStudentPage> {
  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Student"),
        backgroundColor: const Color(0xFF1B263B),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by student name",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("students")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Something went wrong"));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final students = snapshot.data!.docs.where((student) {
                    final name = student["name"].toString().toLowerCase();

                    return name.contains(searchText);
                  }).toList();

                  if (students.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Student Found",
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final data = student.data() as Map<String, dynamic>;

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 15),

                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              student["name"][0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),

                          title: Text(student["name"]),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Phone: ${data["phone"]}"),
                              Text("Location: ${data["location"]}"),
                              Text("Age: ${data["age"] ?? '-'}"),
                              Text("Education: ${data["education"] ?? '-'}"),
                              Text(
                                "Marital Status: ${data["maritalStatus"] ?? '-'}",
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

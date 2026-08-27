import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchStudentTitle),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: l10n.searchByNameHint,
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
                    return Center(child: Text(l10n.somethingWentWrong));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final students = snapshot.data!.docs.where((student) {
                    final name = student["name"].toString().toLowerCase();

                    return name.contains(searchText);
                  }).toList();

                  if (students.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.noStudentFound,
                        style: const TextStyle(fontSize: 20),
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
                            backgroundColor: const Color(0xFF673AB7),
                            child: Text(
                              student["name"][0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),

                          title: Text(student["name"]),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.phoneField(
                                  data["phone"]?.toString() ?? '-',
                                ),
                              ),
                              Text(
                                l10n.locationField(
                                  data["location"]?.toString() ?? '-',
                                ),
                              ),
                              Text(
                                l10n.ageField(data["age"]?.toString() ?? '-'),
                              ),
                              Text(
                                l10n.educationField(
                                  data["education"]?.toString() ?? '-',
                                ),
                              ),
                              Text(
                                l10n.maritalStatusField(
                                  data["maritalStatus"]?.toString() ?? '-',
                                ),
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

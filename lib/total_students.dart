import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TotalStudentsPage extends StatelessWidget {
  const TotalStudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Total Students"),
        backgroundColor: const Color(0xFF673AB7),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("students").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          int totalStudents = snapshot.data!.docs.length;

          return Center(
            child: Card(
              elevation: 8,
              margin: const EdgeInsets.all(30),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.groups,
                      size: 80,
                      color: Color(0xFF673AB7),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Total Number of Students",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 25),

                    Text(
                      "$totalStudents",
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

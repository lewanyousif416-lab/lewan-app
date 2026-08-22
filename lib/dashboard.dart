import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/attendance_months.dart';
import 'login.dart';
import 'add_student.dart';
import 'edit_delete_student.dart';
import 'search_student.dart';
import 'total_students.dart';
import 'change_password.dart';
import 'payments_page.dart';
import 'activities_list_page.dart'; // Import your activities list page

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  // Deletes this student's attendance records, payment records, activity grades, and the student document itself.
  Future<void> _deleteStudentAndRecords(
    BuildContext context,
    String studentId,
  ) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // 1. Find and delete matching records (attendance, payments, etc.)
      final recordsSnapshot = await FirebaseFirestore.instance
          .collectionGroup('records')
          .get();

      for (final doc in recordsSnapshot.docs) {
        if (doc.id == studentId) {
          batch.delete(doc.reference);
        }
      }

      // 2. Find and delete matching activity grades
      final gradesSnapshot = await FirebaseFirestore.instance
          .collectionGroup('grades')
          .get();

      for (final doc in gradesSnapshot.docs) {
        // ignore: unnecessary_cast
        final data = doc.data() as Map<String, dynamic>;
        if (doc.id == studentId || data['studentId'] == studentId) {
          batch.delete(doc.reference);
        }
      }

      // 3. Delete the student document itself.
      batch.delete(
        FirebaseFirestore.instance.collection("students").doc(studentId),
      );

      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Student and all related records deleted"),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color(0xFF673AB7),
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF673AB7)),
              child: Center(
                child: Text(
                  "Information",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text("Add Student"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddStudentPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text("Search Student"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchStudentPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.groups),
              title: const Text("Total Students"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TotalStudentsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_available),
              title: const Text("Attendance"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AttendanceMonthsPage(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.payments),
              title: const Text("Payments"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentsPage()),
                );
              },
            ),

            // Added: ListTile to open Activities page from the drawer
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text("Activities"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ActivitiesListPage()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: const Text("Change Password"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () => logout(context),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("students").snapshots(),

          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong"));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No Students Found",
                  style: TextStyle(fontSize: 20),
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,

              itemBuilder: (context, index) {
                var student = snapshot.data!.docs[index];
                final data = student.data() as Map<String, dynamic>;

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 15),

                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF673AB7),
                      child: Text(student["name"][0].toUpperCase()),
                    ),

                    title: Text(student["name"]),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Phone: ${data["phone"] ?? '-'}"),
                        Text("Location: ${data["location"] ?? '_'}"),
                        Text("Age: ${data["age"] ?? '-'}"),
                        Text("Education: ${data["education"] ?? '-'}"),
                        Text("Status: ${data["maritalStatus"] ?? '-'}"),
                      ],
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditDeleteStudentPage(student: student),
                              ),
                            );
                          },
                        ),

                        // Delete
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool? confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Delete Student"),
                                content: const Text(
                                  "Are you sure you want to delete this student and all their activity/attendance data?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await _deleteStudentAndRecords(
                                context,
                                student.id,
                              );
                            }
                          },
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
    );
  }
}

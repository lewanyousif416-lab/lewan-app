import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'attendance_months.dart';
import 'login.dart';
import 'add_student.dart';
import 'edit_delete_student.dart';
import 'search_student.dart';
import 'total_students.dart';
import 'change_password.dart';
import 'payments_page.dart';
import 'activities_list_page.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Future<void> _deleteStudentAndRecords(
    BuildContext context,
    String studentId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final batch = FirebaseFirestore.instance.batch();

      QuerySnapshot recordsSnapshot;
      try {
        recordsSnapshot = await FirebaseFirestore.instance
            .collectionGroup('records')
            .get(const GetOptions(source: Source.cache));
      } catch (_) {
        try {
          recordsSnapshot = await FirebaseFirestore.instance
              .collectionGroup('records')
              .get()
              .timeout(const Duration(milliseconds: 1000));
        } catch (_) {
          recordsSnapshot = await FirebaseFirestore.instance
              .collection('students')
              .limit(0)
              .get(const GetOptions(source: Source.cache));
        }
      }

      for (final doc in recordsSnapshot.docs) {
        if (doc.id == studentId) {
          batch.delete(doc.reference);
        }
      }

      QuerySnapshot gradesSnapshot;
      try {
        gradesSnapshot = await FirebaseFirestore.instance
            .collectionGroup('grades')
            .get(const GetOptions(source: Source.cache));
      } catch (_) {
        try {
          gradesSnapshot = await FirebaseFirestore.instance
              .collectionGroup('grades')
              .get()
              .timeout(const Duration(milliseconds: 1000));
        } catch (_) {
          gradesSnapshot = await FirebaseFirestore.instance
              .collection('students')
              .limit(0)
              .get(const GetOptions(source: Source.cache));
        }
      }

      for (final doc in gradesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (doc.id == studentId || data['studentId'] == studentId) {
          batch.delete(doc.reference);
        }
      }

      batch.delete(
        FirebaseFirestore.instance.collection("students").doc(studentId),
      );

      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.studentAndRecordsDeleted)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToDelete(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardTitle),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [LanguageSwitcherAction()],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF673AB7)),
              child: Center(
                child: Text(
                  l10n.informationDrawerHeader,
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: Text(l10n.dashboardTitle),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: Text(l10n.addStudentDrawer),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddStudentPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: Text(l10n.searchStudentDrawer),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchStudentPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.groups),
              title: Text(l10n.totalStudentsDrawer),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TotalStudentsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_available),
              title: Text(l10n.attendanceDrawer),
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
              title: Text(l10n.paymentsDrawer),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: Text(l10n.activitiesDrawer),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ActivitiesListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: Text(l10n.changePasswordDrawer),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.languageMenuTooltip),
              trailing: ValueListenableBuilder<Locale>(
                valueListenable: LocaleController.notifier,
                builder: (context, locale, _) =>
                    Text(locale.languageCode == 'ckb' ? 'کوردی' : 'English'),
              ),
              onTap: () {
                final isKurdish = LocaleController.isKurdish;
                LocaleController.setLocale(Locale(isKurdish ? 'en' : 'ckb'));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.logoutDrawer),
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
              return Center(child: Text(l10n.somethingWentWrong));
            }

            // Only show loader if we have NO cached data and are waiting
            if (!snapshot.hasData &&
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return Center(
                child: Text(
                  l10n.noStudentsFoundBig,
                  style: const TextStyle(fontSize: 20),
                ),
              );
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var student = docs[index];
                final data = student.data() as Map<String, dynamic>;

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 15),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF673AB7),
                      child: Text(
                        (student["name"] ?? '?')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    title: Text(student["name"] ?? 'Unnamed'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.phoneField(data["phone"]?.toString() ?? '-')),
                        Text(
                          l10n.locationField(
                            data["location"]?.toString() ?? '-',
                          ),
                        ),
                        Text(l10n.ageField(data["age"]?.toString() ?? '-')),
                        Text(
                          l10n.educationField(
                            data["education"]?.toString() ?? '-',
                          ),
                        ),
                        Text(
                          l10n.statusField(
                            data["maritalStatus"]?.toString() ?? '-',
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool? confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(l10n.deleteStudentTitle),
                                content: Text(
                                  l10n.deleteStudentDashboardContent,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(l10n.cancel),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(l10n.delete),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
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

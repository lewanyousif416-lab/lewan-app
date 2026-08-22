import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'activity_detail_page.dart';

class ActivitiesListPage extends StatelessWidget {
  const ActivitiesListPage({super.key});

  Future<void> _deleteActivityCard(
    BuildContext context,
    String activityId,
  ) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Activity Card"),
        content: const Text(
          "Are you sure you want to delete this card and all its records?",
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

    if (confirm == true) {
      try {
        final activityRef = FirebaseFirestore.instance
            .collection('activities_list')
            .doc(activityId);

        await activityRef.delete();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Activity Card and its records deleted"),
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
  }

  void _showUpdateActivityDialog(
    BuildContext context,
    String activityId,
    String currentTitle,
  ) {
    final controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Activity Card"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Card Title",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && newTitle != currentTitle) {
                // Since Firestore document IDs can't be renamed directly,
                // we create a new document with the new ID/title, copy data, and delete the old one.
                final firestore = FirebaseFirestore.instance;
                final oldDocRef = firestore
                    .collection('activities_list')
                    .doc(activityId);
                final newDocRef = firestore
                    .collection('activities_list')
                    .doc(newTitle);

                final oldDocSnapshot = await oldDocRef.get();
                if (oldDocSnapshot.exists) {
                  final data = oldDocSnapshot.data() as Map<String, dynamic>;
                  data['title'] = newTitle;

                  // Set data to new document ID
                  await newDocRef.set(data);

                  // Copy sub-collection 'grades' if any exist
                  final gradesSnapshot = await oldDocRef
                      .collection('grades')
                      .get();
                  for (var gradeDoc in gradesSnapshot.docs) {
                    await newDocRef
                        .collection('grades')
                        .doc(gradeDoc.id)
                        .set(gradeDoc.data());
                  }

                  // Delete old document and its sub-collection contents
                  await oldDocRef.delete();
                }

                if (context.mounted) Navigator.pop(context);
              } else if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activities"),
        backgroundColor: const Color(0xFF673AB7), // Deep Purple 500
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('activities_list')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Error loading data: ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
            ),
            itemCount: docs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return InkWell(
                  onTap: () => _showAddActivityDialog(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(
                        color: const Color(0xFF673AB7),
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: 40,
                          color: Color(0xFF673AB7),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Add New Card",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF673AB7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final doc = docs[index - 1];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Activity';

              return Stack(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivityDetailPage(
                            activityId: doc.id,
                            activityTitle: title,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF673AB7).withOpacity(0.08),
                        border: Border.all(
                          color: const Color(0xFF673AB7).withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.assignment,
                            size: 32,
                            color: Color(0xFF673AB7),
                          ),
                          const Spacer(),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF673AB7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 22,
                      ),
                      onPressed: () => _deleteActivityCard(context, doc.id),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Color(0xFF673AB7),
                        size: 22,
                      ),
                      onPressed: () =>
                          _showUpdateActivityDialog(context, doc.id, title),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showAddActivityDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Activity Card"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Card Title",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final titleText = controller.text.trim();
              if (titleText.isNotEmpty) {
                // Uses the exact text title as the Firestore Document ID
                await FirebaseFirestore.instance
                    .collection('activities_list')
                    .doc(titleText)
                    .set({
                      'title': titleText,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}

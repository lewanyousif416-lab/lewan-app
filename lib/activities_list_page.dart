import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'activity_detail_page.dart';
import 'l10n/app_localizations.dart';

class ActivitiesListPage extends StatelessWidget {
  const ActivitiesListPage({super.key});

  Future<void> _deleteActivityCard(
    BuildContext context,
    String activityId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteActivityCardTitle),
        content: Text(l10n.deleteActivityCardContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.white),
            ),
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.activityCardDeleted)));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.failedToDelete(e.toString()))),
          );
        }
      }
    }
  }

  void _showUpdateActivityDialog(
    BuildContext context,
    String activityId,
    String currentTitle,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.updateActivityCardTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.cardTitleLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && newTitle != currentTitle) {
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

                  await newDocRef.set(data);

                  final gradesSnapshot = await oldDocRef
                      .collection('grades')
                      .get();
                  for (var gradeDoc in gradesSnapshot.docs) {
                    await newDocRef
                        .collection('grades')
                        .doc(gradeDoc.id)
                        .set(gradeDoc.data());
                  }

                  await oldDocRef.delete();
                }

                if (context.mounted) Navigator.pop(context);
              } else if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(l10n.update),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.activitiesTitle),
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
                  l10n.errorLoadingData(snapshot.error.toString()),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (!snapshot.hasData &&
              snapshot.connectionState == ConnectionState.waiting) {
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          size: 40,
                          color: Color(0xFF673AB7),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.addNewCard,
                          style: const TextStyle(
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
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createActivityCardTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.cardTitleLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final titleText = controller.text.trim();
              if (titleText.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('activities_list')
                    .doc(titleText)
                    .set({
                      'title': titleText,
                      'createdAt': DateTime.now().toIso8601String(),
                    });
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }
}

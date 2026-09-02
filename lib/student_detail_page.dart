import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

class StudentDetailPage extends StatelessWidget {
  final String studentName;
  final bool isActive;
  final double score;

  const StudentDetailPage({
    super.key,
    required this.studentName,
    required this.isActive,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(studentName), backgroundColor: Colors.purple),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.purple, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n?.studentName ?? "ناوی قوتابی"}: $studentName',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${l10n?.score ?? "نمرە / درەجە"}: $score',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('بارودۆخ: ', style: TextStyle(fontSize: 18)),
                        Chip(
                          label: Text(
                            isActive
                                ? (l10n?.activeStatus ?? 'چالاک')
                                : (l10n?.inactiveStatus ?? 'ناچالاک'),
                          ),
                          backgroundColor: isActive
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

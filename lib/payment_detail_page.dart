import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_period_grid_page.dart';
import 'l10n/app_localizations.dart';

class PaymentDetailPage extends StatefulWidget {
  final PaymentPeriodType periodType;
  final String periodId;
  final String periodLabel;

  const PaymentDetailPage({
    super.key,
    required this.periodType,
    required this.periodId,
    required this.periodLabel,
  });

  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  String get _collectionName => widget.periodType == PaymentPeriodType.weekly
      ? 'weeklyPayments'
      : 'monthlyPayments';

  DocumentReference get _periodRef => FirebaseFirestore.instance
      .collection(_collectionName)
      .doc(widget.periodId);

  Future<void> _openAddStudentDialog(
    List<QueryDocumentSnapshot> currentRecords,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    // Existing record IDs currently in this period
    final existingIds = currentRecords.map((d) => d.id).toSet();

    QuerySnapshot studentsSnapshot;
    try {
      studentsSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .orderBy('name')
          .get();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.noStudentsFound)));
      return;
    }

    final available = studentsSnapshot.docs
        .where((doc) => !existingIds.contains(doc.id))
        .toList();

    if (!mounted) return;

    if (available.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.allStudentsAlreadyAdded)));
      return;
    }

    final Set<String> selectedIds = {};

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          l10n.addStudentsSheetTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: available.length,
                          itemBuilder: (context, index) {
                            final doc = available[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final name = (data['name'] ?? 'Unknown') as String;
                            final isSelected = selectedIds.contains(doc.id);

                            return CheckboxListTile(
                              secondary: CircleAvatar(
                                backgroundColor: const Color(0xFF673AB7),
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(name),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setModalState(() {
                                  if (value == true) {
                                    selectedIds.add(doc.id);
                                  } else {
                                    selectedIds.remove(doc.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF673AB7),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: selectedIds.isEmpty
                                ? null
                                : () => Navigator.pop(context),
                            child: Text(
                              l10n.addSelected(selectedIds.length),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (selectedIds.isEmpty) return;

    // Immediately add selected students to Firestore
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in available) {
      if (selectedIds.contains(doc.id)) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] ?? 'Unknown') as String;

        final docRef = _periodRef.collection('records').doc(doc.id);
        batch.set(docRef, {
          'name': name,
          'amount': 0,
          'status': 'unpaid',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
    await batch.commit();
  }

  Future<void> _removeStudent(String studentId, String studentName) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeStudentTitle),
        content: Text(
          l10n.removeStudentContent(studentName, widget.periodLabel),
        ),
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

    if (confirm != true) return;

    // Direct deletion from Firestore works completely offline
    await _periodRef.collection('records').doc(studentId).delete();
  }

  Future<void> _updateStudentStatus(String studentId, bool paid) async {
    await _periodRef.collection('records').doc(studentId).set({
      'status': paid ? 'paid' : 'unpaid',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _updateStudentAmount(String studentId, String text) async {
    final amount = double.tryParse(text.trim()) ?? 0;
    await _periodRef.collection('records').doc(studentId).set({
      'amount': amount,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<QuerySnapshot>(
      stream: _periodRef.collection('records').snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.periodLabel),
            backgroundColor: const Color(0xFF673AB7),
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add, color: Colors.white),
                tooltip: l10n.addStudentsButton,
                onPressed: () => _openAddStudentDialog(docs),
              ),
            ],
          ),
          body:
              snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData
              ? const Center(child: CircularProgressIndicator())
              : docs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_add_alt,
                        size: 50,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.noStudentsAddedYet,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _openAddStudentDialog(docs),
                        icon: const Icon(Icons.person_add),
                        label: Text(l10n.addStudentsButton),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final studentId = doc.id;
                    final name = (data['name'] ?? 'Unknown') as String;
                    final amount = (data['amount'] ?? 0).toString();
                    final bool paid = (data['status'] ?? 'unpaid') == 'paid';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _removeStudent(studentId, name),
                                  tooltip: l10n.delete,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: amount == '0' ? '' : amount,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      labelText: l10n.priceLabel,
                                      border: const OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    onChanged: (text) =>
                                        _updateStudentAmount(studentId, text),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () =>
                                      _updateStudentStatus(studentId, !paid),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: paid
                                          ? Colors.green
                                          : Colors.red.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: paid ? Colors.green : Colors.red,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          paid
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          size: 18,
                                          color: paid
                                              ? Colors.white
                                              : Colors.red,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          paid
                                              ? l10n.paidLabel
                                              : l10n.unpaidLabel,
                                          style: TextStyle(
                                            color: paid
                                                ? Colors.white
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

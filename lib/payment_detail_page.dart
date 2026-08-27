import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_period_grid_page.dart';
import 'l10n/app_localizations.dart';

class PaymentDetailPage extends StatefulWidget {
  final PaymentPeriodType periodType;
  final String periodId; // e.g. "2026-W03" or "2026-01"
  final String periodLabel; // e.g. "Week 3" or "January"

  const PaymentDetailPage({
    super.key,
    required this.periodType,
    required this.periodId,
    required this.periodLabel,
  });

  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentEntry {
  final String name;
  final TextEditingController priceController;
  bool paid;

  _PaymentEntry({
    required this.name,
    required this.priceController,
    required this.paid,
  });
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  final Map<String, _PaymentEntry> entries = {};

  bool loading = true;
  bool saving = false;

  String get _collectionName => widget.periodType == PaymentPeriodType.weekly
      ? 'weeklyPayments'
      : 'monthlyPayments';

  DocumentReference get _periodRef => FirebaseFirestore.instance
      .collection(_collectionName)
      .doc(widget.periodId);

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    QuerySnapshot snapshot;
    try {
      snapshot = await _periodRef
          .collection('records')
          .get(const GetOptions(source: Source.cache));
    } catch (_) {
      try {
        snapshot = await _periodRef
            .collection('records')
            .get()
            .timeout(const Duration(milliseconds: 1000));
      } catch (_) {
        if (mounted) setState(() => loading = false);
        return;
      }
    }

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      entries[doc.id] = _PaymentEntry(
        name: (data['name'] ?? 'Unknown') as String,
        priceController: TextEditingController(
          text: (data['amount'] ?? '').toString(),
        ),
        paid: (data['status'] ?? 'unpaid') == 'paid',
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> _openAddStudentDialog() async {
    final l10n = AppLocalizations.of(context)!;
    QuerySnapshot studentsSnapshot;
    try {
      studentsSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .orderBy('name')
          .get(const GetOptions(source: Source.cache));
    } catch (_) {
      try {
        studentsSnapshot = await FirebaseFirestore.instance
            .collection('students')
            .orderBy('name')
            .get()
            .timeout(const Duration(milliseconds: 1000));
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noStudentsFound)),
        );
        return;
      }
    }

    // Only offer students not already added to this period.
    final available = studentsSnapshot.docs
        .where((doc) => !entries.containsKey(doc.id))
        .toList();

    if (!mounted) return;

    if (available.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.allStudentsAlreadyAdded)));
      return;
    }

    // Keep track of selected student document IDs
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
                            // ignore: unnecessary_cast
                            final data = doc.data() as Map<String, dynamic>;
                            final name = (data['name'] ?? 'Unknown') as String;
                            final isSelected = selectedIds.contains(doc.id);

                            return CheckboxListTile(
                              secondary: CircleAvatar(
                                backgroundColor: const Color(0xFF673AB7),
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
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
                                : () {
                                    Navigator.pop(context);
                                  },
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

    // Add all selected students into the entries map
    setState(() {
      for (final doc in available) {
        if (selectedIds.contains(doc.id)) {
          // ignore: unnecessary_cast
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? 'Unknown') as String;

          entries[doc.id] = _PaymentEntry(
            name: name,
            priceController: TextEditingController(),
            paid: false,
          );
        }
      }
    });
  }

  Future<void> _removeStudent(String studentId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeStudentTitle),
        content: Text(
          l10n.removeStudentContent(
            entries[studentId]?.name ?? '',
            widget.periodLabel,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _periodRef.collection('records').doc(studentId).delete();
    } catch (_) {}

    setState(() {
      entries.remove(studentId);
    });
  }

  Future<void> _saveAll() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => saving = true);

    try {
      final batch = FirebaseFirestore.instance.batch();

      for (final entry in entries.entries) {
        final studentId = entry.key;
        final paymentEntry = entry.value;

        final amountText = paymentEntry.priceController.text.trim();
        final amount = double.tryParse(amountText) ?? 0;

        final docRef = _periodRef.collection('records').doc(studentId);

        batch.set(docRef, {
          'name': paymentEntry.name,
          'amount': amount,
          'status': paymentEntry.paid ? 'paid' : 'unpaid',
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      await batch.commit();

      setState(() => saving = false);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.paymentsSaved)));
      }
    } catch (e) {
      setState(() => saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToSave(e.toString()))),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final entry in entries.values) {
      entry.priceController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final studentIds = entries.keys.toList();

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
            onPressed: loading ? null : _openAddStudentDialog,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: studentIds.isEmpty
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
                                onPressed: _openAddStudentDialog,
                                icon: const Icon(Icons.person_add),
                                label: Text(l10n.addStudentsButton),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: studentIds.length,
                          itemBuilder: (context, index) {
                            final studentId = studentIds[index];
                            final entry = entries[studentId]!;

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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            entry.name,
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
                                              _removeStudent(studentId),
                                          tooltip: l10n.delete,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: entry.priceController,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            decoration: InputDecoration(
                                              labelText: l10n.priceLabel,
                                              border:
                                                  const OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              entry.paid = !entry.paid;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: entry.paid
                                                  ? Colors.green
                                                  : Colors.red.withOpacity(
                                                      0.12,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: entry.paid
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  entry.paid
                                                      ? Icons.check_circle
                                                      : Icons.cancel,
                                                  size: 18,
                                                  color: entry.paid
                                                      ? Colors.white
                                                      : Colors.red,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  entry.paid
                                                      ? l10n.paidLabel
                                                      : l10n.unpaidLabel,
                                                  style: TextStyle(
                                                    color: entry.paid
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
                ),
                if (studentIds.isNotEmpty)
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: saving ? null : _saveAll,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF673AB7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save, color: Colors.white),
                          label: Text(
                            saving ? l10n.saving : l10n.savePayments,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

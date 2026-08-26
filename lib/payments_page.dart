import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'l10n/app_localizations.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final TextEditingController amountController = TextEditingController();
  bool isProcessing = false;

  // Helper method to check active Wi-Fi or Mobile Data
  Future<bool> _hasInternetConnection() async {
    final List<ConnectivityResult> results = await Connectivity()
        .checkConnectivity();
    return results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.mobile);
  }

  // Handle Payment or Activation Process
  Future<void> _processPaymentOrActivation(
    String studentId,
    String studentName,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    // 1. Check Internet Connection First
    bool isOnline = await _hasInternetConnection();

    if (!isOnline) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Wi-Fi / Internet Required'),
            content: const Text(
              'Processing payments or activating accounts requires an active internet connection. Please connect to Wi-Fi and try again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // 2. Process Online Payment / Activation
    setState(() => isProcessing = true);

    try {
      final double amount =
          double.tryParse(amountController.text.trim()) ?? 0.0;

      // Online Firestore write / Payment Gateway API call
      await FirebaseFirestore.instance.collection('payments').add({
        'studentId': studentId,
        'studentName': studentName,
        'amount': amount,
        'status': 'completed',
        'createdAt': DateTime.now().toIso8601String(),
      });

      amountController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment/Activation completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paymentsDrawer),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.somethingWentWrong));
          }

          if (!snapshot.hasData &&
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data?.docs ?? [];

          if (students.isEmpty) {
            return Center(child: Text(l10n.noStudentsFound));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final data = student.data() as Map<String, dynamic>;
              final studentName = data['name'] ?? 'Unnamed';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF673AB7),
                    child: Icon(Icons.payment, color: Colors.white),
                  ),
                  title: Text(
                    studentName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    l10n.phoneField(data['phone']?.toString() ?? '-'),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF673AB7),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isProcessing
                        ? null
                        : () => _showPaymentDialog(student.id, studentName),
                    child: const Text('Pay / Activate'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showPaymentDialog(String studentId, String studentName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Process Payment for $studentName'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter Amount',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _processPaymentOrActivation(studentId, studentName);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

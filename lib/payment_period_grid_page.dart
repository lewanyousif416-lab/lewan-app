import 'package:flutter/material.dart';
import 'payment_detail_page.dart';
import 'l10n/app_localizations.dart';

enum PaymentPeriodType { weekly, monthly }

class PaymentPeriodGridPage extends StatelessWidget {
  final PaymentPeriodType periodType;
  static const int year = 2026;

  const PaymentPeriodGridPage({super.key, required this.periodType});

  bool get isWeekly => periodType == PaymentPeriodType.weekly;

  // "periodId" is what gets stored in Firestore (stable, sortable, always
  // English-formatted so the language switch never touches saved data).
  // "periodLabel" is what gets shown on the card / app bar.
  List<Map<String, String>> _periods(AppLocalizations l10n) {
    if (isWeekly) {
      // Weeks 1..52 of the year.
      return List.generate(52, (index) {
        final weekNum = index + 1;
        return {
          "id": "$year-W${weekNum.toString().padLeft(2, '0')}",
          "label": l10n.weekLabel(weekNum),
        };
      });
    } else {
      final months = <String>[
        l10n.monthJanuary,
        l10n.monthFebruary,
        l10n.monthMarch,
        l10n.monthApril,
        l10n.monthMay,
        l10n.monthJune,
        l10n.monthJuly,
        l10n.monthAugust,
        l10n.monthSeptember,
        l10n.monthOctober,
        l10n.monthNovember,
        l10n.monthDecember,
      ];
      return List.generate(12, (index) {
        final monthNum = index + 1;
        return {
          "id": "$year-${monthNum.toString().padLeft(2, '0')}",
          "label": months[index],
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final periods = _periods(l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isWeekly
              ? l10n.weeklyPaymentsTitle("$year")
              : l10n.monthlyPaymentsTitle("$year"),
        ),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),

      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: periods.length,

        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.2,
        ),

        itemBuilder: (context, index) {
          final period = periods[index];

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentDetailPage(
                    periodType: periodType,
                    periodId: period["id"]!,
                    periodLabel: period["label"]!,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF673AB7), Color(0xFF9575CD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isWeekly
                          ? Icons.calendar_view_week
                          : Icons.calendar_month,
                      color: Colors.white,
                      size: 45,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      period["label"]!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$year",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
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

import 'package:flutter/material.dart';
import 'attendance_page.dart';

class AttendanceMonthsPage extends StatelessWidget {
  const AttendanceMonthsPage({Key? key}) : super(key: key);

  final List<String> months = const [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  final List<int> fridayCount = const [
    5, // January
    4, // February
    4, // March
    4, // April
    5, // May
    4, // June
    4, // July
    5, // August
    4, // September
    5, // October
    4, // November
    4, // December
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance - 2026"),
        backgroundColor: const Color(0xFF1B263B),
        centerTitle: true,
      ),

      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: months.length,

        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.2,
        ),

        itemBuilder: (context, index) {
          return InkWell(
            borderRadius: BorderRadius.circular(16),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AttendancePage(
                    month: index + 1,
                    monthName: months[index],
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
                    colors: [Color(0xFF1B263B), Color(0xFF415A77)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 50,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      months[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "2026",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),

                      child: Text(
                        "${fridayCount[index]} Fridays",
                        style: const TextStyle(
                          color: Color(0xFF1B263B),
                          fontWeight: FontWeight.bold,
                        ),
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

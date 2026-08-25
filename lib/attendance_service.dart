import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save Attendance
  Future<void> saveAttendance({
    required String studentId,
    required String studentName,
    required DateTime date,
    required String status,
  }) async {
    String dateId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    await _firestore
        .collection("attendance")
        .doc(dateId)
        .collection(
          "records",
        ) // unified: was "students", now matches AttendancePage
        .doc(studentId)
        .set({
          "studentId": studentId,
          "name": studentName, // unified key name: AttendancePage reads "name"
          "status": status,
          "date": Timestamp.fromDate(date),
          "updatedAt": FieldValue.serverTimestamp(),
        });
  }

  // Read Attendance for One Date
  Future<Map<String, String>> getAttendance(DateTime date) async {
    String dateId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    QuerySnapshot snapshot = await _firestore
        .collection("attendance")
        .doc(dateId)
        .collection("records") // unified: was "students"
        .get();

    Map<String, String> attendance = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      attendance[doc.id] = (data["status"] ?? '') as String;
    }

    return attendance;
  }

  // Update Attendance
  Future<void> updateAttendance({
    required String studentId,
    required DateTime date,
    required String status,
  }) async {
    String dateId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    await _firestore
        .collection("attendance")
        .doc(dateId)
        .collection("records") // unified: was "students"
        .doc(studentId)
        .update({"status": status, "updatedAt": FieldValue.serverTimestamp()});
  }

  // Delete Attendance for a single student on a single date
  Future<void> deleteAttendance({
    required String studentId,
    required DateTime date,
  }) async {
    String dateId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    await _firestore
        .collection("attendance")
        .doc(dateId)
        .collection("records") // unified: was "students"
        .doc(studentId)
        .delete();
  }

  // Delete ALL attendance records for one student, across every date.
  Future<void> deleteAllAttendanceForStudent(String studentId) async {
    final recordsSnapshot = await _firestore
        .collectionGroup('records')
        .where('studentId', isEqualTo: studentId)
        .get();

    final batch = _firestore.batch();

    for (final doc in recordsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Get Students
  Stream<QuerySnapshot> getStudents() {
    return _firestore.collection("students").snapshots();
  }

  // Get Attendance Stream for one date
  Stream<QuerySnapshot> getAttendanceStream(DateTime date) {
    String dateId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    return _firestore
        .collection("attendance")
        .doc(dateId)
        .collection("records") // unified: was "students"
        .snapshots();
  }
}

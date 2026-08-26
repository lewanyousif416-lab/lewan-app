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
        .collection("records")
        .doc(studentId)
        .set({
          "studentId": studentId,
          "name": studentName,
          "status": status,
          "date": Timestamp.fromDate(date),
          "updatedAt": DateTime.now().toIso8601String(),
        });
  }

  // Read Attendance for One Date (Supports Offline Caching)
  Future<Map<String, String>> getAttendance(DateTime date) async {
    String dateId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    QuerySnapshot snapshot;
    try {
      snapshot = await _firestore
          .collection("attendance")
          .doc(dateId)
          .collection("records")
          .get(const GetOptions(source: Source.cache));
    } catch (_) {
      try {
        snapshot = await _firestore
            .collection("attendance")
            .doc(dateId)
            .collection("records")
            .get()
            .timeout(const Duration(milliseconds: 1000));
      } catch (_) {
        return {};
      }
    }

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
        .collection("records")
        .doc(studentId)
        .update({
          "status": status,
          "updatedAt": DateTime.now().toIso8601String(),
        });
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
        .collection("records")
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
        .collection("records")
        .snapshots();
  }
}

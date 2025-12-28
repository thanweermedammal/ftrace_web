import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, int>> calculateDashboardStats() async {
    int totalPurchases = 0;
    int expiredPurchases = 0;
    int expiryThisWeek = 0;

    int totalProcesses = 0;
    int runningProcesses = 0;
    int completedProcesses = 0;

    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));

    // 1️⃣ Get all hotels
    final hotelsSnap = await _db.collection('hotels').get();

    // for (final hotel in hotelsSnap.docs) {
    //
    //   // ================= PURCHASES =================
    //   final purchasesSnap =
    //   await hotel.reference.collection('purchases').get();
    //
    //   totalPurchases += purchasesSnap.size;
    //
    //   // ================= DISH EXPIRY =================
    //   final dishesSnap =
    //   await hotel.reference.collection('dishes').get();
    //
    //   for (final dish in dishesSnap.docs) {
    //     if (!dish.data().containsKey('expiryDate')) continue;
    //
    //     final expiryDate =
    //     (dish['expiryDate'] as Timestamp).toDate();
    //
    //     if (expiryDate.isBefore(now)) {
    //       expiredPurchases++;
    //     } else if (expiryDate.isBefore(weekEnd)) {
    //       expiryThisWeek++;
    //     }
    //   }
    //
    //   // ================= PROCESS =================
    //   final processSnap =
    //   await hotel.reference.collection('processes').get();
    //
    //   for (final process in processSnap.docs) {
    //     totalProcesses++;
    //
    //     final status = process['status'];
    //
    //     if (status == 'running') {
    //       runningProcesses++;
    //     } else if (status == 'completed') {
    //       completedProcesses++;
    //     }
    //   }
    // }

    return {
      'totalPurchases': totalPurchases,
      'expiredPurchases': expiredPurchases,
      'expiryThisWeek': expiryThisWeek,
      'totalProcesses': totalProcesses,
      'runningProcesses': runningProcesses,
      'completedProcesses': completedProcesses,
    };
  }
}

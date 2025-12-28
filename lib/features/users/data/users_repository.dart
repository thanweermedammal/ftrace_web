// user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<UserModel>> fetchUsers({String? role, String? status}) {
    Query query = _db.collection('users');

    if (role != null) {
      query = query.where('role', isEqualTo: role);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map(
          (snap) => snap.docs
          .map((d) => UserModel.fromJson(d.id, d.data() as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> addUser(UserModel user) async {
    await _db.collection('users').add(user.toJson()); // 🔥 Firebase auto ID
  }
}

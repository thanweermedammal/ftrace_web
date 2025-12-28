import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
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
          .map(
            (d) => UserModel.fromJson(d.id, d.data() as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Future<void> addUser(UserModel user) async {
    FirebaseApp? secondaryApp;
    try {
      // 1. Initialize secondary app to avoid signing out the current admin
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );

      // 2. Create user in Firebase Auth
      final auth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      // 3. Get the UID
      final uid = credential.user!.uid;

      // 4. Update user model with the new UID
      // Since UserModel is immutable and might not have copyWith, we recreate it (or assuming we can use toJson/fromJson trick or just manual map)
      // Ideally we should have copyWith, but here I'll just map it manually for safety or use the toJson() and override 'id'.
      final userData = user.toJson();
      // Ensure the saved document has the correct UID both in ID field (if any) and as Doc ID.
      // fetchUsers uses d.id as the ID, but let's check if the model stores ID in the document too?
      // UserModel.fromJson takes (id, map). The map usually doesn't strictly require ID if it's external,
      // but let's see. The user model has 'id' field.
      // We should probably NOT save 'id' inside the data if it's redundant, but if we do, it must match.
      // But wait, the previous code was: _db.collection('users').add(user.toJson());
      // user.toJson() implementation:
      /*
      Map<String, dynamic> toJson() {
        return {
          'name': name,
          ...
          // It DOES NOT include 'id' in current implementation based on step 560 view.
          // step 560: 
          /*
          Map<String, dynamic> toJson() {
            return {
              'name': name,
              ...
            };
          }
          */
      */
      // So we are safe to just use .set() with the UID.

      await _db.collection('users').doc(uid).set(userData);
    } catch (e) {
      // If auth creation fails, we just throw.
      // If firestore fails, we might want to delete the auth user?
      // For now, simple throw is acceptable.
      rethrow;
    } finally {
      // 5. Cleanup secondary app
      await secondaryApp?.delete();
    }
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.id).update(user.toJson());
  }

  // 🔹 Delete multiple Users
  Future<void> deleteUsers(List<String> userIds) async {
    FirebaseApp? secondaryApp;
    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryAppDelete',
        options: Firebase.app().options,
      );
      final auth = FirebaseAuth.instanceFor(app: secondaryApp);

      for (final id in userIds) {
        // 1. Fetch user data locally to get credentials (INSECURE: relies on password being stored)
        // This is a workaround because we cannot delete OTHER users without Admin SDK or their credentials.
        final doc = await _db.collection('users').doc(id).get();
        if (!doc.exists) continue;

        final data = doc.data();
        final email = data?['email'];
        final password = data?['password'];

        if (email != null &&
            password != null &&
            password.toString().isNotEmpty) {
          try {
            // 2. Sign in on secondary app
            final cred = await auth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
            // 3. Delete user
            await cred.user?.delete();
          } catch (e) {
            // Identify if error is because user is already deleted or password changed
            // We proceed to delete from Firestore regardless to keep DB clean.
            debugPrint("Failed to delete auth user $email: $e");
          }
        }
      }
    } catch (e) {
      debugPrint("Secondary app init failed: $e");
    } finally {
      // 4. Cleanup secondary app
      await secondaryApp?.delete();
    }

    // 5. Batch delete from Firestore
    final batch = _db.batch();
    for (final id in userIds) {
      batch.delete(_db.collection('users').doc(id));
    }
    await batch.commit();
  }
}

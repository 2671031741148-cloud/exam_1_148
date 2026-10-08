import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exam_1_148/model/app_user.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _users = FirebaseFirestore.instance.collection('users');

  Stream<User?> get authChanges => _auth.authStateChanges();

  /// ฟัง role ของผู้ใช้ปัจจุบันจาก Firestore (users/{uid})
  Stream<AppUser?> userStream(String uid) => _users.doc(uid).snapshots().map(
        (d) => d.exists ? AppUser.fromMap(d.data()!) : null,
      );

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> signOut() => _auth.signOut();

  /// สร้างบัญชีทดสอบ 2 บัญชี + เอกสารใน collection users (กดครั้งเดียวจากหน้า Login)
  Future<void> seedTestAccounts() async {
    const accounts = [
      {'name': 'Admin Test', 'email': 'admin@test.com', 'role': 'Admin'},
      {'name': 'Operator Test', 'email': 'operator@test.com', 'role': 'Operator'},
    ];
    for (final a in accounts) {
      UserCredential cred;
      try {
        cred = await _auth.createUserWithEmailAndPassword(
            email: a['email']!, password: '123456');
      } on FirebaseAuthException catch (e) {
        if (e.code != 'email-already-in-use') rethrow;
        cred = await _auth.signInWithEmailAndPassword(
            email: a['email']!, password: '123456');
      }
      final uid = cred.user!.uid;
      await _users.doc(uid).set(
          AppUser(uid: uid, name: a['name']!, email: a['email']!, role: a['role']!).toMap());
    }
    await _auth.signOut();
  }
}

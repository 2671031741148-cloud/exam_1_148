import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:exam_1_148/model/app_user.dart';
import 'package:exam_1_148/screen/login_screen.dart';
import 'package:exam_1_148/screen/main_home_screen.dart';
import 'package:exam_1_148/services/auth_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const EcoCarbonApp());
}

class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform => null;
}

class EcoCarbonApp extends StatelessWidget {
  const EcoCarbonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoCarbon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const AuthGate(),
    );
  }
}

/// ยังไม่ล็อกอิน -> LoginScreen / ล็อกอินแล้ว -> อ่าน role จาก Firestore แล้วเข้า MainHomeScreen
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return StreamBuilder<User?>(
      stream: auth.authChanges,
      builder: (context, snap) {
        final user = snap.data;
        if (snap.connectionState == ConnectionState.waiting) return const _Loading();
        if (user == null) return const LoginScreen();
        return StreamBuilder<AppUser?>(
          stream: auth.userStream(user.uid),
          builder: (context, us) {
            if (us.connectionState == ConnectionState.waiting) return const _Loading();
            final appUser = us.data;
            if (appUser == null) {
              return Scaffold(
                body: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('ไม่พบข้อมูลสิทธิ์ผู้ใช้ใน Firestore (users)'),
                    TextButton(onPressed: auth.signOut, child: const Text('ออกจากระบบ')),
                  ]),
                ),
              );
            }
            return MainHomeScreen(currentUser: appUser);
          },
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

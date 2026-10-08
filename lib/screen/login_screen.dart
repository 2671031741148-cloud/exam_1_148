import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:exam_1_148/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _run(Future<void> Function() job, {String? ok}) async {
    setState(() => _loading = true);
    try {
      await job();
      if (ok != null) _msg(ok);
    } on FirebaseAuthException catch (e) {
      _msg('เข้าสู่ระบบไม่สำเร็จ: ${e.code}');
    } catch (e) {
      _msg('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _msg(String m) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(children: [
              const Icon(Icons.eco, size: 64, color: Colors.green),
              const SizedBox(height: 8),
              const Text('EcoCarbon Tracker',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'อีเมล', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'รหัสผ่าน', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : () => _run(() => _auth.signIn(_email.text, _password.text)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: _loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('เข้าสู่ระบบ'),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                ActionChip(
                    label: const Text('กรอก Admin'),
                    onPressed: () {
                      _email.text = 'admin@test.com';
                      _password.text = '123456';
                    }),
                ActionChip(
                    label: const Text('กรอก Operator'),
                    onPressed: () {
                      _email.text = 'operator@test.com';
                      _password.text = '123456';
                    }),
              ]),
              const Divider(height: 32),
              TextButton.icon(
                onPressed: _loading
                    ? null
                    : () => _run(_auth.seedTestAccounts, ok: 'สร้างบัญชีทดสอบเรียบร้อย (รหัสผ่าน 123456)'),
                icon: const Icon(Icons.person_add),
                label: const Text('สร้างบัญชีทดสอบ (ทำครั้งเดียว)'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

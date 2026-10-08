class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // 'Admin' หรือ 'Operator'

  AppUser({required this.uid, required this.name, required this.email, required this.role});

  bool get isAdmin => role == 'Admin';

  Map<String, dynamic> toMap() => {'uid': uid, 'name': name, 'email': email, 'role': role};

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        uid: m['uid'] ?? '',
        name: m['name'] ?? '',
        email: m['email'] ?? '',
        role: m['role'] ?? 'Operator', // ค่าเริ่มต้นปลอดภัยที่สุด
      );
}

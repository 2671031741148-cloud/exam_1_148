import 'package:flutter/material.dart';
import 'package:exam_1_148/model/app_user.dart';
import 'package:exam_1_148/model/carbon_record.dart';
import 'package:exam_1_148/services/auth_service.dart';
import 'package:exam_1_148/services/firestore_service.dart';
 
import 'emission_form_tab.dart';
import 'emission_display_tab.dart';
 
class MainHomeScreen extends StatefulWidget {
  final AppUser currentUser;
  const MainHomeScreen({super.key, required this.currentUser});
 
  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}
 
class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  final _db = FirestoreService();
 
  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
 
  Future<void> _addRecord(CarbonRecord record) async {
    try {
      await _db.create(record);
      setState(() => _currentIndex = 1);
      _toast('บันทึกข้อมูลคาร์บอนสำเร็จ!');
    } catch (e) {
      _toast('บันทึกไม่สำเร็จ: $e');
    }
  }
 
  Future<void> _updateRecord(CarbonRecord record) async {
    if (!widget.currentUser.isAdmin) return _toast('ไม่มีสิทธิ์แก้ไขข้อมูล');
    try {
      await _db.update(record);
      _toast('อัปเดตข้อมูลเรียบร้อยแล้ว');
    } catch (e) {
      _toast('แก้ไขไม่สำเร็จ: $e');
    }
  }
 
  Future<void> _deleteRecord(String id) async {
    if (!widget.currentUser.isAdmin) return _toast('ไม่มีสิทธิ์ลบข้อมูล');
    try {
      await _db.delete(id);
    } catch (e) {
      _toast('ลบไม่สำเร็จ: $e');
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final user = widget.currentUser;
    final pages = <Widget>[
      EmissionFormTab(onSubmit: _addRecord),
      StreamBuilder<List<CarbonRecord>>(
        stream: _db.records(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('โหลดข้อมูลไม่สำเร็จ: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return EmissionDisplayTab(
            records: snap.data!,
            isAdmin: user.isAdmin,
            onEdit: _updateRecord,
            onDelete: _deleteRecord,
          );
        },
      ),
    ];
 
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
            child: const Icon(Icons.eco, color: Colors.green, size: 24),
          ),
          const SizedBox(width: 10),
          const Flexible(
            child: Text('EcoCarbon',
                overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ]),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Center(
            child: Chip(
              avatar: Icon(user.isAdmin ? Icons.admin_panel_settings : Icons.person, size: 18),
              label: Text(user.role, style: const TextStyle(fontSize: 12)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: Colors.green.shade700,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'บันทึกข้อมูล (Form)'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'มอนิเตอร์ (Display)'),
        ],
      ),
    );
  }
}
 
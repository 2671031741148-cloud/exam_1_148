import 'package:flutter/material.dart';
import 'package:exam_1_148/model/carbon_record.dart';


class EmissionDisplayTab extends StatelessWidget {
  final List<CarbonRecord> records;
  final bool isAdmin;
  final Function(CarbonRecord) onEdit;
  final Function(String) onDelete;

  const EmissionDisplayTab({
    super.key,
    required this.records,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  void _showEditDialog(BuildContext context, CarbonRecord record) {
    final tco2eController = TextEditingController(text: record.tco2e.toString());
    final budgetController = TextEditingController(text: record.budget.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('แก้ไขข้อมูล: ${record.costCenterId}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tco2eController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'ปริมาณ tCO2e ใหม่'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: budgetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'งบประมาณชดเชย (THB) ใหม่'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                final newTco2e = double.tryParse(tco2eController.text) ?? record.tco2e;
                final newBudget = double.tryParse(budgetController.text) ?? record.budget;
                
                record.tco2e = newTco2e;
                record.budget = newBudget;
                onEdit(record);
                Navigator.pop(context);
              },
              child: const Text('บันทึกการแก้ไข'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, CarbonRecord record) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ยืนยันการตัดจำหน่าย'),
          content: Text('คุณต้องการลบรายการของแผนก ${record.costCenterId} (${record.emissionSource}) ที่ชดเชยสำเร็จแล้วใช่หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                onDelete(record.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ตัดจำหน่ายรายการสำเร็จแล้ว')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('ยืนยันลบ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(child: Text('ยังไม่มีข้อมูลการปล่อยคาร์บอนในระบบ'));
    }

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              radius: 26,
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '${record.tco2e}\ntCO2e',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                  ),
                ),
              ),
            ),
            title: Text(
              '${record.costCenterId} - ${record.emissionSource}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('ผู้ตรวจสอบ: ${record.auditorEmail}'),
                Text('งบชดเชย: ${record.budget.toStringAsFixed(0)} THB', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
              ],
            ),
            isThreeLine: true,
            // Operator: ซ่อนปุ่ม Edit/Delete (จึงไม่สามารถเปิด AlertDialog ได้)
            trailing: isAdmin
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDialog(context, record),
                        tooltip: 'แก้ไขข้อมูลหลัง Audit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteDialog(context, record),
                        tooltip: 'ตัดจำหน่ายรายการที่ชดเชยแล้ว',
                      ),
                    ],
                  )
                : const Tooltip(
                    message: 'Operator: ดูและเพิ่มข้อมูลได้เท่านั้น',
                    child: Icon(Icons.lock_outline, color: Colors.grey),
                  ),
          ),
        );
      },
    );
  }
}
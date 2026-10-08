import 'package:flutter/material.dart';
import 'package:exam_1_148/model/carbon_record.dart';


class EmissionFormTab extends StatefulWidget {
  final Function(CarbonRecord) onSubmit;

  const EmissionFormTab({super.key, required this.onSubmit});

  @override
  State<EmissionFormTab> createState() => _EmissionFormTabState();
}

class _EmissionFormTabState extends State<EmissionFormTab> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _costCenterController = TextEditingController(text: 'CC-ENG-04');
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tco2eController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  // รายการช้อยส์ตัวเลือกแนะนำสำหรับรหัสศูนย์ต้นทุน (สามารถเลือกหรือพิมพ์ใหม่เองได้)
  final List<String> _costCenterOptions = [
    'CC-ENG-04',
    'CC-LOG-01',
    'CC-HR-02',
    'CC-MKT-03',
    'CC-IT-05',
    'CC-PROD-08',
  ];

  // รายการช้อยส์ตัวเลือกแนะนำสำหรับแหล่งกำเนิดการปล่อย (สามารถเลือกหรือพิมพ์ใหม่เองได้)
  final List<String> _sourceOptions = [
    'การใช้ไฟฟ้า (Electricity)',
    'ยานพาหนะและขนส่ง (Logistics)',
    'กระบวนการผลิต (Production)',
    'การจัดการของเสีย (Waste)',
    'เชื้อเพลิงชีวมวล (Biomass)',
  ];

  @override
  void dispose() {
    _costCenterController.dispose();
    _sourceController.dispose();
    _emailController.dispose();
    _tco2eController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newRecord = CarbonRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        costCenterId: _costCenterController.text.trim(),
        emissionSource: _sourceController.text.trim(),
        auditorEmail: _emailController.text.trim(),
        tco2e: double.parse(_tco2eController.text),
        budget: double.parse(_budgetController.text),
      );
      widget.onSubmit(newRecord);
      _formKey.currentState!.reset();
      _costCenterController.text = 'CC-ENG-04';
      _sourceController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text(
              'บันทึกปริมาณการปล่อยก๊าซเรือนกระจก',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 16),
            
            // 1. Cost Center ID (เลือกจากช้อยส์ หรือพิมพ์ค่าอื่นเองได้)
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return _costCenterOptions;
                }
                return _costCenterOptions.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                _costCenterController.text = selection;
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                if (controller.text.isEmpty && _costCenterController.text.isNotEmpty) {
                  controller.text = _costCenterController.text;
                }
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: (value) {
                    _costCenterController.text = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'รหัสศูนย์ต้นทุน / แผนก (Cost Center ID)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                    helperText: 'เลือกจากรายการหรือพิมพ์รหัสใหม่ได้ทันที',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกรหัสศูนย์ต้นทุน (ห้ามเว้นว่าง)';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // 2. Emission Source (เลือกจากช้อยส์ หรือพิมพ์ค่าอื่นเองได้)
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return _sourceOptions;
                }
                return _sourceOptions.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                _sourceController.text = selection;
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: (value) {
                    _sourceController.text = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'แหล่งกำเนิดการปล่อย (Emission Source)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fireplace),
                    helperText: 'เลือกจากรายการหรือพิมพ์แหล่งกำเนิดใหม่ได้ทันที',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณาระบุแหล่งกำเนิดการปล่อย (ห้ามเว้นว่าง)';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // 3. Auditor Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'อีเมลเจ้าหน้าที่ตรวจสอบสิ่งแวดล้อม (Auditor Email)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอกอีเมลผู้ตรวจสอบ';
                }
                final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegExp.hasMatch(value)) {
                  return 'รูปแบบอีเมลไม่ถูกต้อง';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 4. ปริมาณการปล่อย (tCO2e)
            TextFormField(
              controller: _tco2eController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'ปริมาณการปล่อย (tCO2e)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cloud),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอกปริมาณ tCO2e';
                }
                if (double.tryParse(value) == null) {
                  return 'กรุณากรอกเป็นตัวเลขทศนิยมที่ถูกต้อง';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 5. งบประมาณชดเชย (THB)
            TextFormField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'งบประมาณชดเชยที่จัดสรร (Carbon Offset Budget - THB)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monetization_on),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอกงบประมาณชดเชย';
                }
                if (double.tryParse(value) == null) {
                  return 'กรุณากรอกเป็นตัวเลขที่ถูกต้อง';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _submitForm,
              icon: const Icon(Icons.save),
              label: const Text('บันทึกข้อมูลคาร์บอน'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_1_148/model/carbon_record.dart';

class FirestoreService {
  final _col = FirebaseFirestore.instance.collection('carbon_records');

  Stream<List<CarbonRecord>> records() => _col.snapshots().map(
        (s) => s.docs.map((d) => CarbonRecord.fromMap(d.id, d.data())).toList(),
      );

  Future<void> create(CarbonRecord r) => _col.add(r.toMap());
  Future<void> update(CarbonRecord r) => _col.doc(r.id).update(r.toMap());
  Future<void> delete(String id) => _col.doc(id).delete();
}

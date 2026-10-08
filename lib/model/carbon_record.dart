class CarbonRecord {
  String id;
  String costCenterId;
  String emissionSource;
  String auditorEmail;
  double tco2e;
  double budget;

  CarbonRecord({
    required this.id,
    required this.costCenterId,
    required this.emissionSource,
    required this.auditorEmail,
    required this.tco2e,
    required this.budget,
  });

  Map<String, dynamic> toMap() => {
        'costCenterId': costCenterId,
        'emissionSource': emissionSource,
        'auditorEmail': auditorEmail,
        'tco2e': tco2e,
        'budget': budget,
      };

  factory CarbonRecord.fromMap(String id, Map<String, dynamic> m) => CarbonRecord(
        id: id,
        costCenterId: m['costCenterId'] ?? '',
        emissionSource: m['emissionSource'] ?? '',
        auditorEmail: m['auditorEmail'] ?? '',
        tco2e: (m['tco2e'] ?? 0).toDouble(),
        budget: (m['budget'] ?? 0).toDouble(),
      );
}

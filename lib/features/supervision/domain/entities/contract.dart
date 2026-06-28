class Contract {
  final int id;
  final int associationId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final int maxZones;
  final int maxMicrocontrollers;
  final double totalAmount;
  final String currency;
  final String paymentFrequency;
  final bool isSuspended;

  Contract({
    required this.id,
    required this.associationId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.maxZones,
    required this.maxMicrocontrollers,
    required this.totalAmount,
    required this.currency,
    required this.paymentFrequency,
    required this.isSuspended,
  });

  factory Contract.fromMap(Map<String, dynamic> map) {
    return Contract(
      id: map['id'] as int? ?? 0,
      associationId: map['associationId'] as int? ?? 0,
      startDate: DateTime.tryParse(map['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(map['endDate'] ?? '') ?? DateTime.now(),
      status: map['status'] as String? ?? 'Unknown',
      maxZones: map['maxZones'] as int? ?? 0,
      maxMicrocontrollers: map['maxMicrocontrollers'] as int? ?? 0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'USD',
      paymentFrequency: map['paymentFrequency'] as String? ?? 'Monthly',
      isSuspended: map['isSuspended'] as bool? ?? false,
    );
  }

  bool get isActive => status.toLowerCase() == 'active' && !isSuspended;
}
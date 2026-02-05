class PaymentSchedule {
  final int id;
  final int installmentNumber;
  final String description;
  final double amount;
  final String? dueDate;
  final String status; // 'PENDING', 'PAID', 'OVERDUE'
  final double paidAmount;
  final String? paidDate;
  final List<PaymentTransaction> transactions;

  PaymentSchedule({
    required this.id,
    required this.installmentNumber,
    required this.description,
    required this.amount,
    this.dueDate,
    required this.status,
    required this.paidAmount,
    this.paidDate,
    this.transactions = const [],
  });

  factory PaymentSchedule.fromJson(Map<String, dynamic> json) {
    return PaymentSchedule(
      id: json['id'] as int,
      installmentNumber: json['installmentNumber'] ?? json['installment_number'] as int,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDate: json['dueDate'] ?? json['due_date'] as String?,
      status: json['status'] as String,
      paidAmount: (json['paidAmount'] ?? json['paid_amount'] ?? 0).toDouble(),
      paidDate: json['paidDate'] ?? json['paid_date'] as String?,
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((t) => PaymentTransaction.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get isPaid => status == 'PAID';
  bool get isPending => status == 'PENDING';
  bool get isOverdue => status == 'OVERDUE';
  
  double get remainingAmount => amount - paidAmount;
}

class PaymentTransaction {
  final int id;
  final double amount;
  final String? paymentMethod; // 'BANK_TRANSFER', 'UPI', 'CHEQUE', 'CASH'
  final String? referenceNumber;
  final String paymentDate;
  final String? receiptNumber;
  final String status;
  final double tdsPercentage;
  final double tdsAmount;
  final double netAmount;

  PaymentTransaction({
    required this.id,
    required this.amount,
    this.paymentMethod,
    this.referenceNumber,
    required this.paymentDate,
    this.receiptNumber,
    required this.status,
    required this.tdsPercentage,
    required this.tdsAmount,
    required this.netAmount,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] ?? json['payment_method'] as String?,
      referenceNumber: json['referenceNumber'] ?? json['reference_number'] as String?,
      paymentDate: json['paymentDate'] ?? json['payment_date'] as String,
      receiptNumber: json['receiptNumber'] ?? json['receipt_number'] as String?,
      status: json['status'] as String,
      tdsPercentage: (json['tdsPercentage'] ?? json['tds_percentage'] ?? 0).toDouble(),
      tdsAmount: (json['tdsAmount'] ?? json['tds_amount'] ?? 0).toDouble(),
      netAmount: (json['netAmount'] ?? json['net_amount'] as num).toDouble(),
    );
  }
}

// Payment summary for dashboard display
class PaymentSummary {
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  
  PaymentSummary({
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
  });
  
  double get progress => totalAmount > 0 ? paidAmount / totalAmount : 0.0;
}

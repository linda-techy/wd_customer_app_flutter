import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'auth_service.dart';
import '../models/project_module_models.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class CustomerPaymentStage {
  final int id;
  final int stageNumber;
  final String stageName;
  final double stagePercentage;
  final double stageAmountExGst;
  final double gstAmount;
  final double stageAmountInclGst;
  final double appliedCreditAmount;
  final double netPayableAmount;
  final double paidAmount;
  final String status;
  final DateTime? dueDate;
  final String? milestoneDescription;
  final DateTime? paidAt;

  const CustomerPaymentStage({
    required this.id,
    required this.stageNumber,
    required this.stageName,
    required this.stagePercentage,
    required this.stageAmountExGst,
    required this.gstAmount,
    required this.stageAmountInclGst,
    required this.appliedCreditAmount,
    required this.netPayableAmount,
    required this.paidAmount,
    required this.status,
    this.dueDate,
    this.milestoneDescription,
    this.paidAt,
  });

  factory CustomerPaymentStage.fromJson(Map<String, dynamic> j) =>
      CustomerPaymentStage(
        id: j['id'] ?? 0,
        stageNumber: j['stageNumber'] ?? 0,
        stageName: j['stageName'] ?? '',
        stagePercentage: _d(j['stagePercentage']),
        stageAmountExGst: _d(j['stageAmountExGst']),
        gstAmount: _d(j['gstAmount']),
        stageAmountInclGst: _d(j['stageAmountInclGst']),
        appliedCreditAmount: _d(j['appliedCreditAmount']),
        netPayableAmount: _d(j['netPayableAmount']),
        paidAmount: _d(j['paidAmount']),
        status: j['status'] ?? 'UPCOMING',
        dueDate: _dt(j['dueDate']),
        milestoneDescription: j['milestoneDescription'],
        paidAt: _dt(j['paidAt']),
      );
}

class PaymentScheduleResult {
  final List<CustomerPaymentStage> stages;
  final double totalContractValue;
  final double totalPaid;
  final double totalOutstanding;
  final int stageCount;

  const PaymentScheduleResult({
    required this.stages,
    required this.totalContractValue,
    required this.totalPaid,
    required this.totalOutstanding,
    required this.stageCount,
  });
}

class CustomerChangeOrder {
  final int id;
  final String referenceNumber;
  final String coType;
  final String status;
  final String title;
  final String? description;
  final String? justification;
  final double netAmountExGst;
  final double gstAmount;
  final double netAmountInclGst;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final DateTime? createdAt;

  const CustomerChangeOrder({
    required this.id,
    required this.referenceNumber,
    required this.coType,
    required this.status,
    required this.title,
    this.description,
    this.justification,
    required this.netAmountExGst,
    required this.gstAmount,
    required this.netAmountInclGst,
    this.submittedAt,
    this.approvedAt,
    this.rejectedAt,
    this.rejectionReason,
    this.createdAt,
  });

  factory CustomerChangeOrder.fromJson(Map<String, dynamic> j) =>
      CustomerChangeOrder(
        id: j['id'] ?? 0,
        referenceNumber: j['referenceNumber'] ?? '',
        coType: j['coType'] ?? '',
        status: j['status'] ?? '',
        title: j['title'] ?? '',
        description: j['description'],
        justification: j['justification'],
        netAmountExGst: _d(j['netAmountExGst']),
        gstAmount: _d(j['gstAmount']),
        netAmountInclGst: _d(j['netAmountInclGst']),
        submittedAt: _dt(j['submittedAt']),
        approvedAt: _dt(j['approvedAt']),
        rejectedAt: _dt(j['rejectedAt']),
        rejectionReason: j['rejectionReason'],
        createdAt: _dt(j['createdAt']),
      );

  bool get isReduction =>
      coType.contains('REDUCTION') || coType.contains('DEC');
  bool get isPendingReview => status == 'CUSTOMER_REVIEW';
}

// ─── Service ─────────────────────────────────────────────────────────────────

class CustomerBoqService {
  final Dio _dio;

  CustomerBoqService({required String baseUrl, required String token})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: ApiConfig.getAuthHeaders(token),
          connectTimeout: ApiConfig.connectionTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
        ));

  static Future<CustomerBoqService> create() async {
    final token = await AuthService.getAccessToken() ?? '';
    return CustomerBoqService(
        baseUrl: ApiConfig.baseUrl, token: token);
  }

  Future<PaymentScheduleResult> getPaymentSchedule(
      String projectUuid) async {
    final res =
        await _dio.get('/api/projects/$projectUuid/boq/payment-schedule');
    _check(res.data, 'Failed to load payment schedule');
    final data = res.data as Map<String, dynamic>;
    final stages = (data['stages'] as List)
        .map((j) => CustomerPaymentStage.fromJson(j as Map<String, dynamic>))
        .toList();
    final summary = data['summary'] as Map<String, dynamic>;
    return PaymentScheduleResult(
      stages: stages,
      totalContractValue: _d(summary['totalContractValue']),
      totalPaid: _d(summary['totalPaid']),
      totalOutstanding: _d(summary['totalOutstanding']),
      stageCount: (summary['stageCount'] as num?)?.toInt() ?? stages.length,
    );
  }

  Future<List<CustomerChangeOrder>> getChangeOrders(
      String projectUuid) async {
    final res =
        await _dio.get('/api/projects/$projectUuid/boq/change-orders');
    _check(res.data, 'Failed to load change orders');
    return ((res.data['changeOrders'] ?? []) as List)
        .map((j) => CustomerChangeOrder.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<CustomerChangeOrder>> getPendingReview(
      String projectUuid) async {
    final res = await _dio
        .get('/api/projects/$projectUuid/boq/change-orders/pending-review');
    _check(res.data, 'Failed to load pending change orders');
    return ((res.data['changeOrders'] ?? []) as List)
        .map((j) => CustomerChangeOrder.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<CustomerChangeOrder> approve(
      String projectUuid, int coId) async {
    final res = await _dio
        .patch('/api/projects/$projectUuid/boq/change-orders/$coId/approve');
    _check(res.data, 'Failed to approve change order');
    return CustomerChangeOrder.fromJson(
        res.data['changeOrder'] as Map<String, dynamic>);
  }

  Future<CustomerChangeOrder> reject(
      String projectUuid, int coId, String reason) async {
    final res = await _dio.patch(
        '/api/projects/$projectUuid/boq/change-orders/$coId/reject',
        data: {'reason': reason});
    _check(res.data, 'Failed to reject change order');
    return CustomerChangeOrder.fromJson(
        res.data['changeOrder'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>?> getFinancialStages(String projectUuid) async {
    try {
      final res =
          await _dio.get('/api/projects/$projectUuid/financial/stages');
      return res.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getFinancialVOs(String projectUuid) async {
    try {
      final res = await _dio
          .get('/api/projects/$projectUuid/financial/variation-orders');
      return res.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getFinancialDeductions(
      String projectUuid) async {
    try {
      final res =
          await _dio.get('/api/projects/$projectUuid/financial/deductions');
      return res.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getFinancialFinalAccount(
      String projectUuid) async {
    try {
      final res =
          await _dio.get('/api/projects/$projectUuid/financial/final-account');
      return res.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<List<BoqInvoice>> getBoqInvoices(String projectUuid) async {
    final res = await _dio
        .get('/api/projects/$projectUuid/financial/boq-invoices');
    _check(res.data, 'Failed to load BOQ invoices');
    return ((res.data['invoices'] ?? []) as List)
        .map((j) => BoqInvoice.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  void _check(dynamic data, String fallback) {
    if (data is Map && data['success'] == false) {
      throw Exception(data['message'] ?? fallback);
    }
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

double _d(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

DateTime? _dt(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

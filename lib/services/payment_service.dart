import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/payment_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  final Dio _dio;

  PaymentService({Dio? dio}) : _dio = dio ?? Dio();

  /// Get all payment schedules for the current customer's projects
  Future<List<PaymentSchedule>> getCustomerPayments({
    int? projectId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      
      if (projectId != null) {
        queryParams['projectId'] = projectId;
      }

      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/customer/payments',
        queryParameters: queryParams,
        options: Options(
          headers: await _getAuthHeaders(),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null && data['content'] != null) {
          return (data['content'] as List)
              .map((json) => PaymentSchedule.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      // Use logger in production instead of print
      rethrow;
    }
  }

  /// Get a specific payment schedule by ID
  Future<PaymentSchedule?> getPaymentScheduleById(int id) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/customer/payments/$id',
        options: Options(
          headers: await _getAuthHeaders(),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null) {
          return PaymentSchedule.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      // Use logger in production instead of print
      rethrow;
    }
  }

  /// Calculate payment summary from list of schedules
  PaymentSummary calculateSummary(List<PaymentSchedule> schedules) {
    double totalAmount = 0.0;
    double paidAmount = 0.0;

    for (var schedule in schedules) {
      totalAmount += schedule.amount;
      paidAmount += schedule.paidAmount;
    }

    return PaymentSummary(
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      dueAmount: totalAmount - paidAmount,
    );
  }

  /// Get authentication headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}

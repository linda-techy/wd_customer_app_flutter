import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/lead_models.dart';
import 'auth_service.dart';

class LeadService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: ApiConfig.connectionTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
  ));

  static Future<List<CustomerLead>> getMyLeads() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return [];

      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/leads/my',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => CustomerLead.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getMyReferrals() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return [];
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/leads/my-referrals',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<CustomerLead?> getLeadDetail(int id) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return null;

      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/leads/my/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        return CustomerLead.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> submitEnquiry(NewEnquiryRequest request) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return false;

      final response = await _dio.post(
        '${ApiConfig.baseUrl}/api/leads/enquiry',
        data: request.toJson(),
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}

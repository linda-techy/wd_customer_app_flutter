import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/support_models.dart';
import '../services/auth_service.dart';

class SupportService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: ApiConfig.connectionTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
    headers: ApiConfig.defaultHeaders,
  ));

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await AuthService.getAccessToken();
    return {...ApiConfig.defaultHeaders, 'Authorization': 'Bearer $token'};
  }

  static Future<SupportTicket?> createTicket({
    required String subject,
    required String description,
    String category = 'GENERAL',
    String priority = 'MEDIUM',
    int? projectId,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final body = <String, dynamic>{
        'subject': subject,
        'description': description,
        'category': category,
        'priority': priority,
        if (projectId != null) 'projectId': projectId,
      };
      final response = await _dio.post(
        ApiConfig.supportTicketsEndpoint,
        data: body,
        options: Options(headers: headers),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return SupportTicket.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> getMyTickets({
    int page = 0,
    int size = 10,
    String? status,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final params = <String, dynamic>{'page': page, 'size': size};
      if (status != null && status.isNotEmpty) params['status'] = status;

      final response = await _dio.get(
        ApiConfig.supportTicketsEndpoint,
        queryParameters: params,
        options: Options(headers: headers),
      );
      final data = response.data;

      final List<SupportTicket> content = [];
      if (data is Map && data['content'] is List) {
        for (final item in data['content'] as List) {
          content.add(SupportTicket.fromJson(item as Map<String, dynamic>));
        }
      }

      return {
        'content': content,
        'totalElements': (data is Map ? data['totalElements'] ?? 0 : 0),
        'totalPages': (data is Map ? data['totalPages'] ?? 0 : 0),
      };
    } catch (_) {
      return {
        'content': <SupportTicket>[],
        'totalElements': 0,
        'totalPages': 0
      };
    }
  }

  static Future<SupportTicket?> getTicketDetail(int ticketId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${ApiConfig.supportTicketsEndpoint}/$ticketId',
        options: Options(headers: headers),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return SupportTicket.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<TicketReply?> addReply(
    int ticketId,
    String message, {
    String? attachmentUrl,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final body = <String, dynamic>{
        'message': message,
        if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
      };
      final response = await _dio.post(
        '${ApiConfig.supportTicketsEndpoint}/$ticketId/replies',
        data: body,
        options: Options(headers: headers),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return TicketReply.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> closeTicket(int ticketId) async {
    try {
      final headers = await _getAuthHeaders();
      await _dio.patch(
        '${ApiConfig.supportTicketsEndpoint}/$ticketId/close',
        options: Options(headers: headers),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

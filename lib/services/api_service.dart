import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://amada-api-server-iq.fly.dev";

  static Future<List<Map<String, dynamic>>> getDeliveryOrders() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/delivery/orders')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> pickupOrder(String id) async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/api/delivery/orders/$id/pickup')).timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deliverOrder(String id) async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/api/delivery/orders/$id/deliver')).timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/incident_response_model.dart';

class ApiService {
  // Point this to your backend URL
  static const String baseUrl = "http://10.0.2.2:8000";

  Future<IncidentResponse> analyzeIncident(String message, String language, String location) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "message": message,
          "language": language,
          "location": location,
        }),
      );

      if (response.statusCode == 200) {
        return IncidentResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }
}
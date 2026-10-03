import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/incident_response_model.dart';

class ApiService {
  // Change this to Safi's live backend URL later when ready
  static const String baseUrl = "https://api.maamlanext.pk";
  static const bool useMock = true; // Toggle true so you can code without backend

  Future<IncidentResponse> analyzeIncident(String message, String language, String location) async {
    if (useMock) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network latency

      String lowerMsg = message.toLowerCase();

      // Mock response for missing person / gumshuda
      if (lowerMsg.contains('missing') || lowerMsg.contains('behen') || lowerMsg.contains('bhai') || lowerMsg.contains('gum') || lowerMsg.contains('bacha')) {
        return IncidentResponse.fromJson({
          "situation": "Missing Person",
          "jurisdiction": "Sindh",
          "summary": "A person has gone missing. Immediate reporting to the local police station is critical, and waiting 24 hours is a myth.",
          "follow_up_questions": [
            "What is the age and physical description of the missing person?",
            "When and where were they last seen?"
          ],
          "actions": [
            {
              "title": "File a Missing Person Report (FIR)",
              "description": "Visit the nearest police station immediately. Police are legally required to register a report for a missing person without delay.",
              "priority": "immediate"
            },
            {
              "title": "Contact CPLC 24/7 Helpline",
              "description": "Call CPLC at 1102 or visit their office to log the missing person details for wider coordination.",
              "priority": "immediate"
            }
          ],
          "sources": [
            {
              "title": "Missing Persons Procedure",
              "organization": "Citizens Police Liaison Committee (CPLC)",
              "url": "https://www.cplc.org.pk"
            }
          ],
          "disclaimer": "MaamlaNext provides procedural guidance based on official sources."
        });
      }

      // Default / Mobile Snatching Mock Response
      return IncidentResponse.fromJson({
        "situation": "Mobile snatching",
        "jurisdiction": "Sindh",
        "summary": "Your mobile phone was snatched. Immediate action involves blocking your SIM, IMEI, and filing an e-FIR.",
        "follow_up_questions": [
          "What is the IMEI number of your phone?"
        ],
        "actions": [
          {
            "title": "Block SIM card immediately",
            "description": "Call your mobile network operator (Jazz, Telenor, Zong, Ufone) to block your SIM to prevent misuse.",
            "priority": "immediate"
          },
          {
            "title": "Block IMEI via PTA",
            "description": "Block your device IMEI through the PTA online portal or by calling 0800-25625.",
            "priority": "immediate"
          },
          {
            "title": "File an e-FIR / Police Report",
            "description": "Visit the local police station having jurisdiction or use the Sindh Police Online Complaint Cell.",
            "priority": "normal"
          }
        ],
        "sources": [
          {
            "title": "Standard Operating Procedure for Mobile Theft",
            "organization": "Citizens Police Liaison Committee (CPLC Sindh)",
            "url": "https://www.cplc.org.pk"
          },
          {
            "title": "Device Blocking Guidelines",
            "organization": "Pakistan Telecommunication Authority (PTA)",
            "url": "https://www.pta.gov.pk"
          }
        ],
        "disclaimer": "MaamlaNext provides procedural guidance based on official sources and does not constitute formal legal representation."
      });
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message, "language": language, "location": location}),
      );

      if (response.statusCode == 200) {
        return IncidentResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to analyze incident: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }
}
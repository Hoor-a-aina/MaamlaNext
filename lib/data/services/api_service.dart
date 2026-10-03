import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/incident_response_model.dart';

class ApiService {
  static const String baseUrl = "https://api.maamlanext.pk";
  static const bool useMock = true;

  // Simple helper to detect language based on character set / keywords
  String _detectLanguage(String text) {
    // Check for Urdu Arabic script unicode range
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) {
      return 'urdu';
    }

    // Check for common Roman Urdu / conversational markers
    String lower = text.toLowerCase();
    if (lower.contains('mera') || lower.contains('meri') || lower.contains('hain') ||
        lower.contains('hogya') || lower.contains('kya') || lower.contains('hai') ||
        lower.contains('nhi') || lower.contains('bhai') || lower.contains('behen')) {
      return 'roman_urdu';
    }

    return 'english';
  }

  Future<IncidentResponse> analyzeIncident(String message, String language, String location) async {
    if (useMock) {
      await Future.delayed(const Duration(seconds: 1));

      // Auto-detect language from input message if default/unspecified
      String detectedLang = _detectLanguage(message);
      String lowerMsg = message.toLowerCase();

      // 1. Urdu Script Response
      if (detectedLang == 'urdu') {
        return IncidentResponse.fromJson({
          "situation": "موبائل چھیننا (Mobile Snatching)",
          "jurisdiction": "سندھ (Sindh)",
          "summary": "آپ کا موبائل فون چھین لیا گیا ہے۔ فوری اقدام میں سم بلاک کرنا، IMEI بلاک کرنا اور ای ایف آئی آر درج کرنا شامل ہے۔",
          "follow_up_questions": ["کیا آپ کے پاس فون کا IMEI نمبر ہے؟"],
          "actions": [
            {
              "title": "فوری طور پر سم بلاک کریں",
              "description": "اپنے موبائل آپریٹر (جاز، ٹیلینور، زونگ، یفون) کو کال کر کے سم بلاک کریں۔",
              "priority": "immediate"
            },
            {
              "title": "PTA کے ذریعے IMEI بلاک کریں",
              "description": "پی ٹی اے پورٹل یا 0800-25625 پر کال کر کے ڈیوائس بلاک کروائیں۔",
              "priority": "immediate"
            }
          ],
          "sources": [
            {
              "title": "موبائل چوری کے لیے معیاری طریقہ کار",
              "organization": "سی پی ایل سی سندھ (CPLC Sindh)",
              "url": "https://www.cplc.org.pk"
            }
          ],
          "disclaimer": "معاملہ نیکسٹ سرکاری ذرائع کی بنیاد پر طریقہ کار کی رہنمائی فراہم کرتا ہے۔"
        });
      }

      // 2. Roman Urdu Response
      if (detectedLang == 'roman_urdu') {
        if (lowerMsg.contains('missing') || lowerMsg.contains('behen') || lowerMsg.contains('bhai') || lowerMsg.contains('gum') || lowerMsg.contains('nhi mil')) {
          return IncidentResponse.fromJson({
            "situation": "Missing Person (Gumshuda Afraad)",
            "jurisdiction": "Sindh",
            "summary": "Koi qareebi gum hogya hai. Foran qareebi police station ya CPLC se rabta karein. 24 ghante ka intezaار karna galat hai.",
            "follow_up_questions": ["Gumshuda shakhs ki age aur physical description kiya hai?"],
            "actions": [
              {
                "title": "Police Station ya CPLC mein report darj karein",
                "description": "Foran qareebi police station jayein ya CPLC helpline 1102 par call karein.",
                "priority": "immediate"
              }
            ],
            "sources": [
              {
                "title": "Missing Persons SOP",
                "organization": "Citizens Police Liaison Committee (CPLC)",
                "url": "https://www.cplc.org.pk"
              }
            ],
            "disclaimer": "MaamlaNext sarkari zaraye ke mutabiq rehnumai faraham karta hai."
          });
        }

        // Default Roman Urdu (Mobile Snatching / General)
        return IncidentResponse.fromJson({
          "situation": "Mobile Snatching / Chori",
          "jurisdiction": "Sindh",
          "summary": "Aap ka mobile phone chori ya snatch hogya hai. Foran apni SIM aur IMEI block karwayein aur e-FIR darj karein.",
          "follow_up_questions": ["Kya aap ke paas phone ka IMEI number mojood hai?"],
          "actions": [
            {
              "title": "Foran SIM block karwayein",
              "description": "Apni mobile network company (Jazz, Zong, Telenor, Ufone) ko call kar ke SIM block karein.",
              "priority": "immediate"
            },
            {
              "title": "PTA ke zariye IMEI block karein",
              "description": "PTA portal ya helpline 0800-25625 par call kar ke device block karwayein.",
              "priority": "immediate"
            },
            {
              "title": "e-FIR ya Police Complaint darj karein",
              "description": "Sindh Police Online Complaint Cell ya qareebi police station jayein.",
              "priority": "normal"
            }
          ],
          "sources": [
            {
              "title": "Standard Operating Procedure for Mobile Theft",
              "organization": "CPLC Sindh",
              "url": "https://www.cplc.org.pk"
            },
            {
              "title": "Device Blocking Guidelines",
              "organization": "Pakistan Telecommunication Authority (PTA)",
              "url": "https://www.pta.gov.pk"
            }
          ],
          "disclaimer": "MaamlaNext official sources ke mutabiq procedural guidance deta hai."
        });
      }

      // 3. Default English Response
      return IncidentResponse.fromJson({
        "situation": "Mobile snatching",
        "jurisdiction": "Sindh",
        "summary": "Your mobile phone was snatched. Immediate action involves blocking your SIM, IMEI, and filing an e-FIR.",
        "follow_up_questions": ["What is the IMEI number of your phone?"],
        "actions": [
          {
            "title": "Block SIM card immediately",
            "description": "Call your mobile network operator to block your SIM.",
            "priority": "immediate"
          },
          {
            "title": "Block IMEI via PTA",
            "description": "Block your device IMEI through the PTA online portal or call 0800-25625.",
            "priority": "immediate"
          }
        ],
        "sources": [
          {
            "title": "Standard Operating Procedure for Mobile Theft",
            "organization": "CPLC Sindh",
            "url": "https://www.cplc.org.pk"
          }
        ],
        "disclaimer": "MaamlaNext provides procedural guidance based on official sources."
      });
    }

    // Real backend request
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
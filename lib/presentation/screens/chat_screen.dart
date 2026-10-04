import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/incident_response_model.dart';
import '../../data/services/api_service.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
  });

  final ValueChanged<ThemeMode> onThemeChanged;
  final ThemeMode currentThemeMode;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  final List<String> _quickPrompts = [
    "📱 Mera mobile snatch hogya",
    "👤 Cyber fraud",
    "🚨 Emergency: Phone snatched",
  ];

  // Helper to detect if text contains native Urdu/Arabic script characters
  bool _isUrduScript(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  // Helper to check if text is primarily English
  bool _isEnglish(String text) {
    return RegExp(r'^[a-zA-Z0-9\s\p{P}]+$').hasMatch(text);
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Dynamically determine language based on user's script/input
    String detectedLanguage = "roman_urdu"; // default fallback
    if (_isUrduScript(text)) {
      detectedLanguage = "urdu";
    } else if (_isEnglish(text)) {
      detectedLanguage = "english";
    }

    setState(() {
      _messages.add({"isUser": true, "message": text});
      _isLoading = true;
    });

    _controller.clear();

    try {
      // Pass the dynamically detected language instead of a hardcoded string
      IncidentResponse response = await _apiService.analyzeIncident(text, detectedLanguage, "Sindh");
      setState(() {
        _isLoading = false;
        _messages.add({
          "isUser": false,
          "message": response.summary,
          "responseData": response,
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add({
          "isUser": false,
          "message": "Error connecting to service. Details: $e",
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = widget.currentThemeMode == ThemeMode.dark ||
        (widget.currentThemeMode == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.tealMintGradient,
          ),
          child: AppBar(
            title: const Text("MaamlaNext", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round, size: 20, color: Colors.black87),
                onPressed: () {
                  widget.onThemeChanged(isDark ? ThemeMode.light : ThemeMode.dark);
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: const BoxDecoration(
                        gradient: AppTheme.tealMintGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.security_rounded, size: 48, color: Colors.black87),
                    ),
                    const SizedBox(height: 18),
                    const Text("How can MaamlaNext assist you?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      "Instant legal guidance & emergency SOPs for Pakistan.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return ChatBubble(
                  isUser: msg["isUser"],
                  message: msg["message"],
                  responseData: msg["responseData"],
                  onQuestionTap: (question) {
                    // Automatically send the tapped follow-up question as a new user message
                    _sendMessage(question);
                  },
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5)),
                  const SizedBox(width: 12),
                  Text("Consulting official SOPs & generating guidance...", style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
                ],
              ),
            ),

          // Clean Horizontal Quick Action Chips (Optimized for all age groups)
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: _quickPrompts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: theme.colorScheme.surface,
                    label: Text(_quickPrompts[index], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.4), width: 1.2),
                    ),
                    onPressed: () => _sendMessage(_quickPrompts[index]),
                  ),
                );
              },
            ),
          ),

          // Polished Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: theme.colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: "Type incident in English or Roman Urdu...",
                      hintStyle: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.tealMintGradient,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.black87, size: 20),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
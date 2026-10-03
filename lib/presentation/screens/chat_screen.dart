import 'package:flutter/material.dart';
import '../../data/models/incident_response_model.dart';
import '../../data/services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;

  const ChatScreen({Key? key, required this.onThemeChanged, required this.currentThemeMode}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();

    try {
      IncidentResponse response = await _apiService.analyzeIncident(text, "roman_urdu", "Karachi, Sindh");
      setState(() {
        _messages.add(ChatMessage(isUser: false, response: response));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: "Error connecting to service. Please try again.", isUser: false));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MaamlaNext"),
        actions: [
          IconButton(
            icon: Icon(widget.currentThemeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              widget.onThemeChanged(
                widget.currentThemeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg.isUser) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg.text, style: const TextStyle(color: Colors.white)),
                    ),
                  );
                } else {
                  if (msg.response != null) {
                    return _buildStructuredResponseCard(msg.response!);
                  } else {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg.text),
                      ),
                    );
                  }
                }
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Describe what happened (e.g. 'mera mobile snatch hogya')...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStructuredResponseCard(IncidentResponse res) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Chip(label: Text(res.situation), backgroundColor: Colors.blue.shade50),
              const SizedBox(width: 8),
              Chip(label: Text(res.jurisdiction), backgroundColor: Colors.grey.shade100),
            ],
          ),
          const SizedBox(height: 8),
          Text(res.summary, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const Divider(height: 24),
          const Text("Recommended Actions:", style: TextStyle(fontWeight: FontWeight.bold)),
          ...res.actions.map((action) => Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text(action.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(action.description, style: const TextStyle(fontSize: 13)),
            ),
          )),
          const Divider(height: 24),
          const Text("Verified Sources:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ...res.sources.map((src) => Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text("• ${src.title} (${src.organization})", style: const TextStyle(fontSize: 12, color: Colors.blue)),
          )),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final IncidentResponse? response;
  ChatMessage({this.text = "", required this.isUser, this.response});
}
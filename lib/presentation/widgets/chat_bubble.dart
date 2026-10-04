import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/incident_response_model.dart';
import 'citation_card.dart';

class ChatBubble extends StatelessWidget {
  final bool isUser;
  final String message;
  final IncidentResponse? responseData;

  const ChatBubble({
    super.key,
    required this.isUser,
    required this.message,
    this.responseData,
  });

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied response to clipboard!'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: isUser ? null : Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (!isUser) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _copyToClipboard(context, message),
                    child: Icon(Icons.copy, size: 16, color: theme.colorScheme.secondary),
                  ),
                ],
              ],
            ),
            if (responseData != null) ...[
              const Divider(height: 20),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      "Situation: ${responseData!.situation}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text("Recommended Actions:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              ...responseData!.actions.map((action) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        "${action.title}: ${action.description}",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),
              if (responseData!.sources.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text("Verified Sources:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                ...responseData!.sources.map((source) => CitationCard(source: source)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/incident_response_model.dart';
import 'citation_card.dart';

class ChatBubble extends StatelessWidget {
  final bool isUser;
  final String message;
  final IncidentResponse? responseData;
  final Function(String)? onQuestionTap;

  const ChatBubble({
    super.key,
    required this.isUser,
    required this.message,
    this.responseData,
    this.onQuestionTap,
  });

  void _copyToClipboard(BuildContext context) {
    String textToCopy = message;
    if (responseData != null) {
      textToCopy = "Situation: ${responseData!.situation}\n\n"
          "Summary: ${responseData!.summary}\n\n"
          "Recommended Actions:\n" +
          responseData!.actions.asMap().entries.map((e) => "${e.key + 1}. ${e.value.title}: ${e.value.description}").join("\n") +
          "\n\nDisclaimer: ${responseData!.disclaimer}";
    }

    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Full guidance copied to clipboard', style: TextStyle(fontSize: 13)),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(18),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.90),
        decoration: BoxDecoration(
          color: isUser ? (isDark ? AppTheme.tealLight : null) : theme.colorScheme.surface,
          gradient: isUser && !isDark ? AppTheme.tealMintGradient : null,
          borderRadius: BorderRadius.circular(16),
          border: isUser
              ? null
              : Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                      color: isUser
                          ? (isDark ? Colors.white : Colors.black87)
                          : theme.colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: isUser ? FontWeight.w600 : FontWeight.normal,
                      height: 1.4,
                    ),
                  ),
                ),
                if (!isUser) ...[
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => _copyToClipboard(context),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(Icons.copy_rounded, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  ),
                ],
              ],
            ),

            if (responseData != null) ...[
              const SizedBox(height: 16),
              Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1), height: 1),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        responseData!.situation,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (responseData!.followUpQuestions.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.help_outline_rounded, size: 16, color: Colors.amber),
                    SizedBox(width: 6),
                    Text(
                      "Required Clarifications / Questions:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...responseData!.followUpQuestions.map((question) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onQuestionTap != null ? () => onQuestionTap!(question) : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                question,
                                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface, height: 1.3),
                              ),
                            ),
                            if (onQuestionTap != null) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.amber),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
              ],

              const SizedBox(height: 14),
              const Text(
                "Recommended Actions:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.3),
              ),
              const SizedBox(height: 10),

              ...responseData!.actions.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final action = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "$index",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.9), height: 1.4),
                            children: [
                              TextSpan(
                                text: "${action.title}: ",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: action.description,
                                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              if (responseData!.sources.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  "Verified Sources & SOPs:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                ...responseData!.sources.map((source) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: CitationCard(source: source),
                )),
              ],

              if (responseData!.disclaimer.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  responseData!.disclaimer,
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
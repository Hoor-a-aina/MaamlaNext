class IncidentResponse {
  final String situation;
  final String jurisdiction;
  final String summary;
  final List<String> followUpQuestions;
  final List<ActionItem> actions;
  final List<SourceItem> sources;
  final String disclaimer;

  IncidentResponse({
    required this.situation,
    required this.jurisdiction,
    required this.summary,
    required this.followUpQuestions,
    required this.actions,
    required this.sources,
    required this.disclaimer,
  });

  factory IncidentResponse.fromJson(Map<String, dynamic> json) {
    return IncidentResponse(
      situation: json['situation'] ?? '',
      jurisdiction: json['jurisdiction'] ?? '',
      summary: json['summary'] ?? '',
      followUpQuestions: List<String>.from(json['follow_up_questions'] ?? []),
      actions: (json['actions'] as List? ?? []).map((x) => ActionItem.fromJson(x)).toList(),
      sources: (json['sources'] as List? ?? []).map((x) => SourceItem.fromJson(x)).toList(),
      disclaimer: json['disclaimer'] ?? '',
    );
  }
}

class ActionItem {
  final String title;
  final String description;
  final String priority;
  ActionItem({required this.title, required this.description, required this.priority});
  factory ActionItem.fromJson(Map<String, dynamic> json) => ActionItem(
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    priority: json['priority'] ?? 'normal',
  );
}

class SourceItem {
  final String title;
  final String organization;
  final String url;
  SourceItem({required this.title, required this.organization, required this.url});
  factory SourceItem.fromJson(Map<String, dynamic> json) => SourceItem(
    title: json['title'] ?? '',
    organization: json['organization'] ?? '',
    url: json['url'] ?? '',
  );
}
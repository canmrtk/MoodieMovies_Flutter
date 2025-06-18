class ForumPostCreate {
  final String title;
  final String tag;
  final String context;

  ForumPostCreate({required this.title, required this.tag, required this.context});

  Map<String, dynamic> toJson() => {
        'title': title,
        'tag': tag,
        'context': context,
      };
} 
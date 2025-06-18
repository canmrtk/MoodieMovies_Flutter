class ForumCommentCreate {
  final String content;
  ForumCommentCreate(this.content);
  Map<String, dynamic> toJson() => {'comment': content};
} 
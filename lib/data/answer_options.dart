class AnswerOption {
  final String id;
  final String label;
  final int point;
  final int color;
  const AnswerOption(this.id, this.label, this.point, this.color);
}

const List<AnswerOption> answerOptions = [
  AnswerOption('0000-000001-ANS','Kesinlikle Katılmıyorum.',1,0xFFFF0000),
  AnswerOption('0000-000002-ANS','Katılmıyorum',2,0xFFE0B000),
  AnswerOption('0000-000003-ANS','Nötr',3,0xFFBFBFBF),
  AnswerOption('0000-000004-ANS','Katılıyorum',4,0xFF26B34A),
  AnswerOption('0000-000005-ANS','Kesinlikle Katılıyorum',5,0xFF00FCD1),
]; 
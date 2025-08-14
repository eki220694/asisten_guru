class Option {
  int? id;
  int questionId;
  String optionText;
  bool isCorrect;

  Option({
    this.id,
    required this.questionId,
    required this.optionText,
    required this.isCorrect,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionId': questionId,
      'optionText': optionText,
      'isCorrect': isCorrect ? 1 : 0,
    };
  }

  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(
      id: map['id'],
      questionId: map['questionId'],
      optionText: map['optionText'],
      isCorrect: map['isCorrect'] == 1 ? true : false,
    );
  }
}

class Question {
  int? id;
  int quizId;
  String questionText;
  String questionType; // e.g., 'multiple_choice', 'essay'
  String? correctAnswer;

  Question({
    this.id,
    required this.quizId,
    required this.questionText,
    required this.questionType,
    this.correctAnswer,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quizId': quizId,
      'questionText': questionText,
      'questionType': questionType,
      'correctAnswer': correctAnswer,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      quizId: map['quizId'],
      questionText: map['questionText'],
      questionType: map['questionType'],
      correctAnswer: map['correctAnswer'],
    );
  }
}

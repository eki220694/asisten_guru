class QuestionAiRequest {
  final String subject;
  final String grade;
  final String material;
  final int numberOfQuestions;
  final String questionType; // 'multiple_choice', 'essay', atau 'mixed'
  final String? difficulty; // 'easy', 'medium', 'hard'

  QuestionAiRequest({
    required this.subject,
    required this.grade,
    required this.material,
    required this.numberOfQuestions,
    required this.questionType,
    this.difficulty,
  });
}
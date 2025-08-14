class GeneratedQuestionOption {
  final String text;
  final bool isCorrect;

  GeneratedQuestionOption({
    required this.text,
    required this.isCorrect,
  });
}

class GeneratedQuestion {
  final String questionText;
  final String type; // 'multiple_choice' or 'essay'
  final List<GeneratedQuestionOption>? options; // For multiple choice questions
  final String? answer; // For essay questions

  GeneratedQuestion({
    required this.questionText,
    required this.type,
    this.options,
    this.answer,
  });
}
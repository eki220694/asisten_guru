class RppAiRequest {
  final String subject;
  final String grade;
  final String topic;
  final String learningObjectives;
  final String? duration;

  RppAiRequest({
    required this.subject,
    required this.grade,
    required this.topic,
    required this.learningObjectives,
    this.duration,
  });
}
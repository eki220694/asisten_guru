class Quiz {
  int? id;
  int subjectId;
  String title;

  Quiz({this.id, required this.subjectId, required this.title});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'title': title,
    };
  }

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'],
      subjectId: map['subjectId'],
      title: map['title'],
    );
  }
}

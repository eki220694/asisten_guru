class Rpp {
  int? id;
  int subjectId;
  String title;
  String? objectives;
  String? materials;
  String? activities;
  String? assessment;
  String? content; // Kolom baru untuk konten Markdown

  Rpp({
    this.id,
    required this.subjectId,
    required this.title,
    this.objectives,
    this.materials,
    this.activities,
    this.assessment,
    this.content, // Tambahkan di konstruktor
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'title': title,
      'objectives': objectives,
      'materials': materials,
      'activities': activities,
      'assessment': assessment,
      'content': content, // Tambahkan ke map
    };
  }

  factory Rpp.fromMap(Map<String, dynamic> map) {
    return Rpp(
      id: map['id'],
      subjectId: map['subjectId'],
      title: map['title'],
      objectives: map['objectives'],
      materials: map['materials'],
      activities: map['activities'],
      assessment: map['assessment'],
      content: map['content'], // Ambil dari map
    );
  }
}
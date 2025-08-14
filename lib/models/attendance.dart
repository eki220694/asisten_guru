class Attendance {
  int? id;
  int studentId;
  int classId;
  int? subjectId;
  String date; // Format: YYYY-MM-DD
  String status; // e.g., 'Hadir', 'Sakit', 'Izin', 'Alpa'

  Attendance({
    this.id,
    required this.studentId,
    required this.classId,
    this.subjectId,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'classId': classId,
      'subjectId': subjectId,
      'date': date,
      'status': status,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      studentId: map['studentId'],
      classId: map['classId'],
      subjectId: map['subjectId'],
      date: map['date'],
      status: map['status'],
    );
  }
}
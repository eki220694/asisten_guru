class Student {
  int? id;
  String? nis; // Nomor Induk Siswa
  String name;
  int? classId;

  Student({this.id, this.nis, required this.name, this.classId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nis': nis,
      'name': name,
      'classId': classId,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      nis: map['nis'],
      name: map['name'],
      classId: map['classId'],
    );
  }
}
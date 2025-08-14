import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/class.dart';
import '../models/subject.dart';
import '../models/rpp.dart';
import '../models/quiz.dart';
import '../models/question.dart';
import '../models/option.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'teacher_assistant.db');
    return await openDatabase(
      path,
      version: 7, // <-- Version updated to 7
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE classes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE subjects(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE rpp(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subjectId INTEGER NOT NULL,
        title TEXT NOT NULL,
        objectives TEXT,
        materials TEXT,
        activities TEXT,
        assessment TEXT,
        content TEXT, -- Kolom baru ditambahkan
        FOREIGN KEY (subjectId) REFERENCES subjects(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE students(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nis TEXT,
        name TEXT NOT NULL,
        classId INTEGER,
        FOREIGN KEY (classId) REFERENCES classes(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        classId INTEGER NOT NULL,
        subjectId INTEGER NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (studentId) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY (classId) REFERENCES classes(id) ON DELETE CASCADE,
        FOREIGN KEY (subjectId) REFERENCES subjects(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE quizzes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subjectId INTEGER NOT NULL,
        title TEXT NOT NULL,
        FOREIGN KEY (subjectId) REFERENCES subjects(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE questions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quizId INTEGER NOT NULL,
        questionText TEXT NOT NULL,
        questionType TEXT NOT NULL, -- e.g., 'multiple_choice', 'essay'
        correctAnswer TEXT, -- For essay or direct answer
        FOREIGN KEY (quizId) REFERENCES quizzes(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE options(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        questionId INTEGER NOT NULL,
        optionText TEXT NOT NULL,
        isCorrect INTEGER NOT NULL, -- 0 for false, 1 for true
        FOREIGN KEY (questionId) REFERENCES questions(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Migration from version 2 to 3
      // ... (kode migrasi yang ada tetap sama)
    }
    if (oldVersion < 4) {
      // ... (kode migrasi yang ada tetap sama)
    }
    if (oldVersion < 5) {
      // ... (kode migrasi yang ada tetap sama)
    }
    if (oldVersion < 6) {
      // ... (kode migrasi yang ada tetap sama)
    }
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE rpp ADD COLUMN content TEXT');
    }
  }

  // --- Class Methods ---
  Future<int> insertClass(Class cls) async {
    Database db = await database;
    return await db.insert('classes', cls.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Class>> getClasses() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('classes', orderBy: 'name');
    return List.generate(maps.length, (i) => Class.fromMap(maps[i]));
  }

  Future<int> updateClass(Class cls) async {
    Database db = await database;
    return await db.update('classes', cls.toMap(), where: 'id = ?', whereArgs: [cls.id]);
  }

  Future<int> deleteClass(int id) async {
    Database db = await database;
    return await db.delete('classes', where: 'id = ?', whereArgs: [id]);
  }

  // --- Subject Methods ---
  Future<int> insertSubject(Subject subject) async {
    Database db = await database;
    return await db.insert('subjects', subject.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Subject>> getSubjects() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('subjects', orderBy: 'name');
    return List.generate(maps.length, (i) => Subject.fromMap(maps[i]));
  }

  Future<int> updateSubject(Subject subject) async {
    Database db = await database;
    return await db.update('subjects', subject.toMap(), where: 'id = ?', whereArgs: [subject.id]);
  }

  Future<int> deleteSubject(int id) async {
    Database db = await database;
    return await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }

  // --- RPP Methods ---
  Future<int> insertRpp(Rpp rpp) async {
    Database db = await database;
    return await db.insert('rpp', rpp.toMap());
  }

  Future<List<Rpp>> getRpps() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('rpp');
    return List.generate(maps.length, (i) => Rpp.fromMap(maps[i]));
  }

  Future<List<Rpp>> getRppsBySubject(int subjectId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'rpp',
      where: 'subjectId = ?',
      whereArgs: [subjectId],
    );
    return List.generate(maps.length, (i) => Rpp.fromMap(maps[i]));
  }

  Future<int> updateRpp(Rpp rpp) async {
    Database db = await database;
    return await db.update('rpp', rpp.toMap(), where: 'id = ?', whereArgs: [rpp.id]);
  }

  Future<int> deleteRpp(int id) async {
    Database db = await database;
    return await db.delete('rpp', where: 'id = ?', whereArgs: [id]);
  }

  // --- Quiz Methods ---
  Future<int> insertQuiz(Quiz quiz) async {
    Database db = await database;
    return await db.insert('quizzes', quiz.toMap());
  }

  Future<List<Quiz>> getQuizzes() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('quizzes');
    return List.generate(maps.length, (i) => Quiz.fromMap(maps[i]));
  }

  Future<List<Quiz>> getQuizzesBySubject(int subjectId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'quizzes',
      where: 'subjectId = ?',
      whereArgs: [subjectId],
    );
    return List.generate(maps.length, (i) => Quiz.fromMap(maps[i]));
  }

  Future<int> updateQuiz(Quiz quiz) async {
    Database db = await database;
    return await db.update('quizzes', quiz.toMap(), where: 'id = ?', whereArgs: [quiz.id]);
  }

  Future<int> deleteQuiz(int id) async {
    Database db = await database;
    return await db.delete('quizzes', where: 'id = ?', whereArgs: [id]);
  }

  // --- Question Methods ---
  Future<int> insertQuestion(Question question) async {
    Database db = await database;
    return await db.insert('questions', question.toMap());
  }

  Future<List<Question>> getQuestionsByQuiz(int quizId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'quizId = ?',
      whereArgs: [quizId],
    );
    return List.generate(maps.length, (i) => Question.fromMap(maps[i]));
  }

  Future<int> updateQuestion(Question question) async {
    Database db = await database;
    return await db.update('questions', question.toMap(), where: 'id = ?', whereArgs: [question.id]);
  }

  Future<int> deleteQuestion(int id) async {
    Database db = await database;
    return await db.delete('questions', where: 'id = ?', whereArgs: [id]);
  }

  // --- Option Methods ---
  Future<int> insertOption(Option option) async {
    Database db = await database;
    return await db.insert('options', option.toMap());
  }

  Future<List<Option>> getOptionsByQuestion(int questionId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'options',
      where: 'questionId = ?',
      whereArgs: [questionId],
    );
    return List.generate(maps.length, (i) => Option.fromMap(maps[i]));
  }

  Future<int> updateOption(Option option) async {
    Database db = await database;
    return await db.update('options', option.toMap(), where: 'id = ?', whereArgs: [option.id]);
  }

  Future<int> deleteOption(int id) async {
    Database db = await database;
    return await db.delete('options', where: 'id = ?', whereArgs: [id]);
  }

  // --- Student Methods ---
  Future<int> insertStudent(Student student) async {
    Database db = await database;
    return await db.insert('students', student.toMap());
  }

  Future<List<Student>> getStudents() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('students');
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  Future<List<Student>> getStudentsByClass(int classId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'classId = ?',
      whereArgs: [classId],
    );
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  Future<int> updateStudent(Student student) async {
    Database db = await database;
    return await db.update('students', student.toMap(), where: 'id = ?', whereArgs: [student.id]);
  }

  Future<int> deleteStudent(int id) async {
    Database db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // --- Attendance Methods ---
  Future<int> insertAttendance(Attendance attendance) async {
    Database db = await database;
    return await db.insert('attendance', attendance.toMap());
  }

  Future<List<Attendance>> getAttendanceByDateClassAndSubject(String date, int classId, int subjectId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: 'date = ? AND classId = ? AND subjectId = ?',
      whereArgs: [date, classId, subjectId],
    );
    return List.generate(maps.length, (i) => Attendance.fromMap(maps[i]));
  }

  Future<int> updateAttendance(Attendance attendance) async {
    Database db = await database;
    return await db.update('attendance', attendance.toMap(), where: 'id = ?', whereArgs: [attendance.id]);
  }

  Future<List<Attendance>> getAttendanceByStudentId(int studentId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Attendance.fromMap(maps[i]));
  }

  Future<List<Attendance>> getAllAttendance() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('attendance');
    return List.generate(maps.length, (i) => Attendance.fromMap(maps[i]));
  }

  Future<int> deleteAttendance(int id) async {
    Database db = await database;
    return await db.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }
}
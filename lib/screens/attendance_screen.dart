
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/class.dart';
import '../models/subject.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<Class> _availableClasses = [];
  List<Subject> _availableSubjects = [];
  List<Student> _studentsInClass = [];
  Map<int, String> _attendanceStatus = {}; // studentId -> status
  Map<int, int?> _existingAttendanceIds = {}; // studentId -> attendanceId

  int? _selectedClassId;
  int? _selectedSubjectId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() { _isLoading = true; });
    final classes = await _dbHelper.getClasses();
    final subjects = await _dbHelper.getSubjects();
    setState(() {
      _availableClasses = classes;
      _availableSubjects = subjects;
      if (_availableClasses.isNotEmpty) {
        _selectedClassId = _availableClasses.first.id;
      }
      if (_availableSubjects.isNotEmpty) {
        _selectedSubjectId = _availableSubjects.first.id;
      }
    });
    await _loadStudentsAndAttendance();
    setState(() { _isLoading = false; });
  }

  Future<void> _loadStudentsAndAttendance() async {
    if (_selectedClassId == null || _selectedSubjectId == null) return;
    setState(() { _isLoading = true; });

    final allStudents = await _dbHelper.getStudents();
    final filteredStudents = allStudents.where((s) => s.classId == _selectedClassId).toList();

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final attendanceRecords = await _dbHelper.getAttendanceByDateClassAndSubject(formattedDate, _selectedClassId!, _selectedSubjectId!);

    setState(() {
      _studentsInClass = filteredStudents;
      _attendanceStatus.clear();
      _existingAttendanceIds.clear();
      for (var record in attendanceRecords) {
        _attendanceStatus[record.studentId] = record.status;
        _existingAttendanceIds[record.studentId] = record.id;
      }
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadStudentsAndAttendance();
    }
  }

  void _markAllAs(String status) {
    setState(() {
      for (var student in _studentsInClass) {
        _attendanceStatus[student.id!] = status;
      }
    });
  }

  Future<void> _saveAttendance() async {
    if (_selectedClassId == null || _selectedSubjectId == null || _studentsInClass.isEmpty) return;

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final batch = (await _dbHelper.database).batch();
    int operations = 0;

    for (var student in _studentsInClass) {
      final status = _attendanceStatus[student.id] ?? 'Hadir'; // Default to Hadir
      final existingId = _existingAttendanceIds[student.id];

      final attendance = Attendance(
        id: existingId,
        studentId: student.id!,
        classId: _selectedClassId!,
        subjectId: _selectedSubjectId!,
        date: formattedDate,
        status: status,
      );

      if (existingId != null) {
        batch.update('attendance', attendance.toMap(), where: 'id = ?', whereArgs: [existingId]);
        operations++;
      } else {
        batch.insert('attendance', attendance.toMap());
        operations++;
      }
    }

    if (operations > 0) {
      await batch.commit(noResult: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Absensi berhasil disimpan!')),
      );
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada perubahan untuk disimpan.')),
      );
    }
    
    await _loadStudentsAndAttendance(); // Refresh data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildControls(),
          _buildQuickActions(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedClassId == null
                    ? const Center(child: Text('Silakan buat kelas terlebih dahulu.'))
                    : _studentsInClass.isEmpty
                        ? const Center(child: Text('Tidak ada siswa di kelas ini.'))
                        : _buildStudentList(),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedClassId,
                  hint: const Text('Pilih Kelas'),
                  decoration: const InputDecoration(labelText: 'Pilih Kelas'),
                  items: _availableClasses.map<DropdownMenuItem<int>>((Class cls) {
                    return DropdownMenuItem<int>(value: cls.id, child: Text(cls.name));
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedClassId = newValue;
                    });
                    _loadStudentsAndAttendance();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedSubjectId,
                  hint: const Text('Pilih Mapel'),
                  decoration: const InputDecoration(labelText: 'Pilih Mapel'),
                  items: _availableSubjects.map<DropdownMenuItem<int>>((Subject subject) {
                    return DropdownMenuItem<int>(value: subject.id, child: Text(subject.name));
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedSubjectId = newValue;
                    });
                    _loadStudentsAndAttendance();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _selectDate(context),
              icon: const Icon(Icons.calendar_today),
              label: Text(DateFormat('dd-MM-yyyy').format(_selectedDate)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(onPressed: () => _markAllAs('Hadir'), child: const Text('Semua Hadir')),
          ElevatedButton(onPressed: () => _markAllAs('Alpa'), child: const Text('Semua Alpa')),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    return ListView.builder(
      itemCount: _studentsInClass.length,
      itemBuilder: (context, index) {
        final student = _studentsInClass[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          elevation: 2.0,
          child: ListTile(
            title: Text(student.name),
            subtitle: Text('NIS: ${student.nis ?? '-'}'),
            trailing: DropdownButton<String>(
              value: _attendanceStatus[student.id] ?? 'Hadir',
              onChanged: (String? newValue) {
                setState(() {
                  _attendanceStatus[student.id!] = newValue!;
                });
              },
              items: <String>['Hadir', 'Sakit', 'Izin', 'Alpa']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _saveAttendance,
          child: const Text('Simpan Absensi'),
        ),
      ),
    );
  }
}

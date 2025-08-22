import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../database/database_helper.dart';
import '../models/attendance.dart';
import '../models/class.dart';
import '../models/student.dart';
import '../models/subject.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final int? studentId;

  const AttendanceHistoryScreen({super.key, this.studentId});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Attendance> _allRecords = [];
  List<Attendance> _filteredRecords = [];
  List<Class> _allClasses = [];
  List<Student> _allStudents = [];
  List<Subject> _allSubjects = [];
  Student? _student;

  int? _selectedClassId;
  DateTimeRange? _selectedDateRange;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final records = await (widget.studentId == null
        ? _dbHelper.getAllAttendance()
        : _dbHelper.getAttendanceByStudentId(widget.studentId!));
    final classes = await _dbHelper.getClasses();
    final students = await _dbHelper.getStudents();
    final subjects = await _dbHelper.getSubjects();

    Student? student;
    if (widget.studentId != null) {
      student = students.firstWhereOrNull((s) => s.id == widget.studentId);
    }

    setState(() {
      _allRecords = records;
      _allClasses = classes;
      _allStudents = students;
      _allSubjects = subjects;
      _student = student;
      _filteredRecords = _allRecords;
      _isLoading = false;
    });
  }

  void _filterData() {
    setState(() {
      _filteredRecords = _allRecords.where((record) {
        final classMatch =
            _selectedClassId == null || record.classId == _selectedClassId;
        final dateMatch =
            _selectedDateRange == null ||
            (DateTime.parse(record.date).isAfter(
                  _selectedDateRange!.start.subtract(const Duration(days: 1)),
                ) &&
                DateTime.parse(record.date).isBefore(
                  _selectedDateRange!.end.add(const Duration(days: 1)),
                ));
        return classMatch && dateMatch;
      }).toList();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _filterData();
    }
  }

  String _getStudentName(int studentId) {
    return _allStudents.firstWhereOrNull((s) => s.id == studentId)?.name ??
        'Siswa tidak ditemukan';
  }

  String _getClassName(int classId) {
    return _allClasses.firstWhereOrNull((c) => c.id == classId)?.name ??
        'Kelas tidak ditemukan';
  }

  String _getSubjectName(int? subjectId) {
    if (subjectId == null) return 'Tanpa Mapel';
    return _allSubjects.firstWhereOrNull((s) => s.id == subjectId)?.name ??
        'Mapel tidak ditemukan';
  }

  Map<String, int> _calculateSummary() {
    final summary = {'Hadir': 0, 'Sakit': 0, 'Izin': 0, 'Alpa': 0};
    for (var record in _filteredRecords) {
      summary[record.status] = (summary[record.status] ?? 0) + 1;
    }
    return summary;
  }

  void _editAttendance(Attendance record) {
    showDialog(
      context: context,
      builder: (context) {
        String currentStatus = record.status;
        return AlertDialog(
          title: Text('Edit Absensi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Siswa: ${_getStudentName(record.studentId)}'),
              Text(
                'Tanggal: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(record.date))}',
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: currentStatus,
                items: ['Hadir', 'Sakit', 'Izin', 'Alpa'].map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (value) {
                  if (value != null) currentStatus = value;
                },
                // ignore: deprecated_member_use
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Simpan context dalam variabel lokal
                final dialogContext = context;
                final updatedRecord = Attendance(
                  id: record.id,
                  studentId: record.studentId,
                  classId: record.classId,
                  subjectId: record.subjectId,
                  date: record.date,
                  status: currentStatus,
                );
                await _dbHelper.updateAttendance(updatedRecord);
                if (!mounted) return;
                await _loadData();
                if (!mounted) return;
                // Gunakan Future.microtask untuk memastikan context masih valid
                Future.microtask(() {
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                });
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = _calculateSummary();
    final groupedRecords = groupBy(_filteredRecords, (Attendance r) => r.date);
    final sortedDates = groupedRecords.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _student != null
              ? 'Riwayat Absensi: ${_student!.name}'
              : 'Riwayat Absensi',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (widget.studentId == null) _buildFilterControls(),
                _buildSummary(summary),
                Expanded(
                  child: _filteredRecords.isEmpty
                      ? const Center(
                          child: Text('Tidak ada riwayat absensi yang cocok.'),
                        )
                      : _buildGroupedList(sortedDates, groupedRecords),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: _selectedClassId,
              hint: const Text('Semua Kelas'),
              decoration: const InputDecoration(labelText: 'Filter Kelas'),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('Semua Kelas'),
                ),
                ..._allClasses.map(
                  (cls) =>
                      DropdownMenuItem(value: cls.id, child: Text(cls.name)),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedClassId = value;
                });
                _filterData();
              },
              // ignore: deprecated_member_use
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _selectDateRange(context),
              icon: const Icon(Icons.date_range),
              label: Text(
                _selectedDateRange == null
                    ? 'Semua Tanggal'
                    : '${DateFormat('dd/MM/yy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yy').format(_selectedDateRange!.end)}',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(Map<String, int> summary) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: summary.entries.map((entry) {
            return Column(
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(entry.value.toString()),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGroupedList(
    List<String> sortedDates,
    Map<String, List<Attendance>> groupedRecords,
  ) {
    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final recordsOnDate = groupedRecords[date]!;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ExpansionTile(
            title: Text(
              DateFormat('EEEE, dd MMMM yyyy').format(DateTime.parse(date)),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            initiallyExpanded: true,
            children: recordsOnDate.map((record) {
              return ListTile(
                title: Text(_getStudentName(record.studentId)),
                subtitle: Text(
                  '${_getClassName(record.classId)} - ${_getSubjectName(record.subjectId)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      record.status,
                      style: TextStyle(
                        color: _getStatusColor(record.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onPressed: () => _editAttendance(record),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Hadir':
        return Colors.green;
      case 'Sakit':
        return Colors.orange;
      case 'Izin':
        return Colors.blue;
      case 'Alpa':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}

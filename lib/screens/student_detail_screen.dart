import 'package:asisten_guru/screens/attendance_history_screen.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/student.dart';
import '../models/class.dart';

class StudentDetailScreen extends StatefulWidget {
  final Student? student;
  final int? classId;

  const StudentDetailScreen({super.key, this.student, this.classId});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late String _name;
  String? _nis;
  int? _selectedClassId;

  late Future<List<Class>> _classesFuture;

  @override
  void initState() {
    super.initState();
    _name = widget.student?.name ?? '';
    _nis = widget.student?.nis;
    _selectedClassId = widget.student?.classId ?? widget.classId;
    _classesFuture = _dbHelper.getClasses();
  }

  Future<void> _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final student = Student(
        id: widget.student?.id,
        nis: _nis,
        name: _name,
        classId: _selectedClassId,
      );

      if (widget.student == null) {
        await _dbHelper.insertStudent(student);
      } else {
        await _dbHelper.updateStudent(student);
      }

      if (!mounted) return;
      Navigator.pop(context, true); // Return true to indicate a change was made
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'Tambah Siswa' : 'Edit Siswa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _nis,
                decoration: const InputDecoration(
                  labelText: 'NIS (Nomor Induk Siswa)',
                ),
                onSaved: (value) => _nis = value,
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Class>>(
                future: _classesFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var classes = snapshot.data!;
                  var validSelectedId =
                      _selectedClassId != null &&
                          classes.any((c) => c.id == _selectedClassId)
                      ? _selectedClassId
                      : null;

                  return DropdownButtonFormField<int>(
                    initialValue: validSelectedId,
                    decoration: const InputDecoration(labelText: 'Kelas'),
                    items: classes.map((cls) {
                      return DropdownMenuItem<int>(
                        value: cls.id,
                        child: Text(cls.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClassId = value;
                      });
                    },
                    validator: (value) => value == null ? 'Pilih kelas' : null,
                    // ignore: deprecated_member_use
                  );
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveStudent,
                child: const Text('Simpan'),
              ),
              if (widget.student != null)
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.history),
                    label: const Text('Lihat Riwayat Absensi'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceHistoryScreen(
                            studentId: widget.student!.id!,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

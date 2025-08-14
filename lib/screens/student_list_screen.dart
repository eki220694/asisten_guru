import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../database/database_helper.dart';
import '../models/student.dart';
import '../models/class.dart';
import 'student_detail_screen.dart';

class StudentListScreen extends StatefulWidget {
  final int? classId;

  const StudentListScreen({super.key, this.classId});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();
  
  List<Student> _allStudents = [];
  List<Class> _allClasses = [];
  List<Student> _filteredStudents = [];
  String? _className;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterStudents);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final students = await (widget.classId == null 
        ? _dbHelper.getStudents() 
        : _dbHelper.getStudentsByClass(widget.classId!));
    final classes = await _dbHelper.getClasses();
    
    String? className;
    if (widget.classId != null) {
      final aClass = classes.firstWhereOrNull((c) => c.id == widget.classId);
      if (aClass != null) {
        className = aClass.name;
      }
    }

    setState(() {
      _allStudents = students;
      _allClasses = classes;
      _filteredStudents = students;
      _className = className;
    });
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        final nameMatch = student.name.toLowerCase().contains(query);
        final nisMatch = student.nis?.toLowerCase().contains(query) ?? false;
        return nameMatch || nisMatch;
      }).toList();
    });
  }

  void _navigateAndRefresh(BuildContext context, Widget screen) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _deleteStudent(Student student) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Siswa?'),
          content: Text('Anda yakin ingin menghapus data siswa bernama ${student.name}? Semua data absensi yang terkait juga akan dihapus.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await _dbHelper.deleteStudent(student.id!);
                if (!mounted) return;
                _loadData();
                if (!mounted) return;
                // Simpan context dalam variabel lokal
                final dialogContext = context;
                // Gunakan Future.microtask untuk memastikan context masih valid
                Future.microtask(() {
                  if (dialogContext.mounted) {
                    Navigator.maybePop(dialogContext);
                    if (dialogContext.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text('Siswa ${student.name} dihapus')),
                      );
                    }
                  }
                });
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedStudents = groupBy(_filteredStudents, (Student s) => s.classId);

    return Scaffold(
      appBar: _className != null ? AppBar(title: Text('Siswa Kelas: $_className')) : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Siswa (Nama atau NIS)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _allStudents.isEmpty
                ? const Center(child: Text('Belum ada data siswa. Tekan + untuk menambah.'))
                : ListView.builder(
                    itemCount: _allClasses.length,
                    itemBuilder: (context, index) {
                      final cls = _allClasses[index];
                      final studentsInClass = groupedStudents[cls.id] ?? [];

                      if (studentsInClass.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ExpansionTile(
                          title: Text(cls.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          initiallyExpanded: true,
                          children: studentsInClass.map((student) {
                            return ListTile(
                              title: Text(student.name),
                              subtitle: Text('NIS: ${student.nis ?? '-'}'),
                              onTap: () => _navigateAndRefresh(context, StudentDetailScreen(student: student)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _deleteStudent(student),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(context, StudentDetailScreen(classId: widget.classId)),
        child: const Icon(Icons.add),
      ),
    );
  }
}

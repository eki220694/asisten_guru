import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/subject.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Subject>> _subjectList;

  @override
  void initState() {
    super.initState();
    _updateSubjectList();
  }

  void _updateSubjectList() {
    setState(() {
      _subjectList = _dbHelper.getSubjects();
    });
  }

  void _showSubjectDialog({Subject? subject}) {
    final nameController = TextEditingController(text: subject?.name ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(subject == null ? 'Tambah Mata Pelajaran' : 'Edit Mata Pelajaran'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nama Mata Pelajaran'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final newSubject = Subject(id: subject?.id, name: name);
                  if (subject == null) {
                    await _dbHelper.insertSubject(newSubject);
                  } else {
                    await _dbHelper.updateSubject(newSubject);
                  }
                  _updateSubjectList();
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSubject(int id) async {
    // Optional: Add check if subject is used in any RPP/Soal before deleting
    // For now, we allow direct deletion.
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Mata Pelajaran?'),
          content: const Text('Anda yakin ingin menghapus mata pelajaran ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await _dbHelper.deleteSubject(id);
                _updateSubjectList();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mata pelajaran dihapus')),
                );
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
    return Scaffold(
      body: FutureBuilder<List<Subject>>(
        future: _subjectList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada mata pelajaran. Tekan + untuk menambah.'));
          }

          final subjects = snapshot.data!;
          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(subject.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showSubjectDialog(subject: subject),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSubject(subject.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSubjectDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
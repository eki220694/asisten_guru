import 'package:asisten_guru/screens/student_list_screen.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/class.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Class>> _classList;

  @override
  void initState() {
    super.initState();
    _updateClassList();
  }

  void _updateClassList() {
    setState(() {
      _classList = _dbHelper.getClasses();
    });
  }

  void _showClassDialog({Class? cls}) {
    final nameController = TextEditingController(text: cls?.name ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(cls == null ? 'Tambah Kelas' : 'Edit Kelas'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nama Kelas'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Simpan context dalam variabel lokal
                final dialogContext = context;
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final newClass = Class(id: cls?.id, name: name);
                  if (cls == null) {
                    await _dbHelper.insertClass(newClass);
                  } else {
                    await _dbHelper.updateClass(newClass);
                  }
                  if (!mounted) return;
                  _updateClassList();
                  if (!mounted) return;
                  // Gunakan Future.microtask untuk memastikan context masih valid
                  Future.microtask(() {
                    if (dialogContext.mounted) {
                      Navigator.maybePop(dialogContext);
                    }
                  });
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _deleteClass(int id) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Kelas?'),
          content: const Text('Menghapus kelas juga akan menghapus semua data absensi terkait. Data siswa yang ada di kelas ini tidak akan terhapus, tetapi relasi kelasnya akan dihilangkan. Anda yakin?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                // Simpan context dalam variabel lokal
                final dialogContext = context;
                await _dbHelper.deleteClass(id);
                if (!mounted) return;
                _updateClassList();
                if (!mounted) return;
                // Gunakan Future.microtask untuk memastikan context masih valid
                Future.microtask(() {
                  if (dialogContext.mounted) {
                    Navigator.maybePop(dialogContext);
                    if (dialogContext.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Kelas dihapus')),
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
    return Scaffold(
      body: FutureBuilder<List<Class>>(
        future: _classList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada kelas. Tekan + untuk menambah.'));
          }

          final classes = snapshot.data!;
          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final cls = classes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(cls.name),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentListScreen(classId: cls.id!),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showClassDialog(cls: cls),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteClass(cls.id!),
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
        onPressed: () => _showClassDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
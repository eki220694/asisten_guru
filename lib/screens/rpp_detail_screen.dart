import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../database/database_helper.dart';
import '../models/rpp.dart';
import '../models/subject.dart';

class RppDetailScreen extends StatefulWidget {
  final Rpp? rpp;

  const RppDetailScreen({super.key, this.rpp});

  @override
  State<RppDetailScreen> createState() => _RppDetailScreenState();
}

class _RppDetailScreenState extends State<RppDetailScreen> {
  String? _content; // Kolom untuk konten Markdown
  bool _isAiGenerated = false;

  @override
  void initState() {
    super.initState();
    _content = widget.rpp?.content;
    _isAiGenerated = _content != null && _content!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // Jika ini adalah RPP yang ada dan memiliki konten (dari AI),
    // tampilkan layar pratinjau Markdown, bukan form.
    if (widget.rpp != null && _isAiGenerated) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.rpp!.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigasi ke layar edit yang sebenarnya
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => RppEditScreen(rpp: widget.rpp),
                  ),
                ).then((value) {
                  // Simpan context dalam variabel lokal
                  final screenContext = context;
                  // Gunakan Future.microtask untuk memastikan context masih valid
                  Future.microtask(() {
                    if (screenContext.mounted && value == true) {
                      Navigator.pop(screenContext, true); // Refresh list
                    }
                  });
                });
              },
            ),
          ],
        ),
        body: Markdown(
          data: _content!,
          padding: const EdgeInsets.all(16.0),
          selectable: true,
        ),
      );
    }

    // Jika ini RPP baru atau RPP manual lama, tampilkan form.
    return RppEditScreen(rpp: widget.rpp);
  }
}

// Widget baru yang hanya berisi Form untuk menghindari duplikasi kode
class RppEditScreen extends StatefulWidget {
  final Rpp? rpp;

  const RppEditScreen({super.key, this.rpp});

  @override
  RppEditScreenState createState() => RppEditScreenState();
}

class RppEditScreenState extends State<RppEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _objectivesController;
  late TextEditingController _materialsController;
  late TextEditingController _activitiesController;
  late TextEditingController _assessmentController;

  int? _selectedSubjectId;
  late Future<List<Subject>> _subjectsFuture;
  bool _isAiGenerated = false;

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = widget.rpp?.subjectId;
    _isAiGenerated = widget.rpp?.content != null && widget.rpp!.content!.isNotEmpty;

    _titleController = TextEditingController(text: widget.rpp?.title ?? '');
    _contentController = TextEditingController(text: widget.rpp?.content ?? '');
    _objectivesController = TextEditingController(text: widget.rpp?.objectives ?? '');
    _materialsController = TextEditingController(text: widget.rpp?.materials ?? '');
    _activitiesController = TextEditingController(text: widget.rpp?.activities ?? '');
    _assessmentController = TextEditingController(text: widget.rpp?.assessment ?? '');

    _subjectsFuture = _dbHelper.getSubjects();
  }

  Future<void> _saveRpp() async {
    if (_formKey.currentState!.validate()) {
      final rpp = Rpp(
        id: widget.rpp?.id,
        subjectId: _selectedSubjectId!,
        title: _titleController.text,
        content: _isAiGenerated ? _contentController.text : null,
        objectives: _isAiGenerated ? null : _objectivesController.text,
        materials: _isAiGenerated ? null : _materialsController.text,
        activities: _isAiGenerated ? null : _activitiesController.text,
        assessment: _isAiGenerated ? null : _assessmentController.text,
      );

      if (widget.rpp == null) {
        await _dbHelper.insertRpp(rpp);
      } else {
        await _dbHelper.updateRpp(rpp);
      }

      if (!mounted) return;
      // Pop dua kali untuk kembali ke daftar RPP
      // Gunakan Future.microtask untuk memastikan context masih valid
      Future.microtask(() {
        if (mounted) {
          Navigator.pop(context, true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rpp == null ? 'Tambah RPP' : 'Edit RPP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRpp,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              FutureBuilder<List<Subject>>(
                future: _subjectsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var subjects = snapshot.data!;
                  var validSelectedId = _selectedSubjectId != null && subjects.any((s) => s.id == _selectedSubjectId) ? _selectedSubjectId : null;

                  return DropdownButtonFormField<int>(
                    value: validSelectedId,
                    decoration: const InputDecoration(labelText: 'Mata Pelajaran'),
                    items: subjects.map((subject) {
                      return DropdownMenuItem<int>(
                        value: subject.id,
                        child: Text(subject.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSubjectId = value;
                      });
                    },
                    validator: (value) => value == null ? 'Pilih mata pelajaran' : null,
                    // ignore: deprecated_member_use
                  );
                },
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul RPP'),
                validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              if (_isAiGenerated)
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Konten RPP (Markdown)'),
                  maxLines: 20,
                  validator: (value) => value!.isEmpty ? 'Konten tidak boleh kosong' : null,
                )
              else ...[
                TextFormField(
                  controller: _objectivesController,
                  decoration: const InputDecoration(labelText: 'Tujuan Pembelajaran'),
                  maxLines: 3,
                ),
                TextFormField(
                  controller: _materialsController,
                  decoration: const InputDecoration(labelText: 'Materi Pembelajaran'),
                  maxLines: 5,
                ),
                TextFormField(
                  controller: _activitiesController,
                  decoration: const InputDecoration(labelText: 'Kegiatan Pembelajaran'),
                  maxLines: 5,
                ),
                TextFormField(
                  controller: _assessmentController,
                  decoration: const InputDecoration(labelText: 'Penilaian'),
                  maxLines: 3,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
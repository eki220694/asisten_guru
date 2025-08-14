import 'package:asisten_guru/models/rpp_ai_request.dart';
import 'package:asisten_guru/screens/rpp_ai_result_screen.dart';
import 'package:flutter/material.dart';

class RppAiInputScreen extends StatefulWidget {
  const RppAiInputScreen({Key? key}) : super(key: key);

  @override
  _RppAiInputScreenState createState() => _RppAiInputScreenState();
}

class _RppAiInputScreenState extends State<RppAiInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _gradeController = TextEditingController();
  final _durationController = TextEditingController(); // Controller untuk durasi
  final _topicController = TextEditingController();
  final _learningObjectivesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat RPP dengan AI'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Mata Pelajaran',
                  hintText: 'Contoh: Informatika',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mata pelajaran tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gradeController,
                decoration: const InputDecoration(
                  labelText: 'Kelas / Fase',
                  hintText: 'Contoh: SD Kelas 4',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kelas tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController, // Menggunakan controller durasi
                decoration: const InputDecoration(
                  labelText: 'Alokasi Waktu (Opsional)',
                  hintText: 'Contoh: 2 Pertemuan (4 JP @ 35 Menit)',
                  border: OutlineInputBorder(),
                ),
                // Tidak ada validator karena opsional
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _topicController,
                decoration: const InputDecoration(
                  labelText: 'Topik / Materi Pokok',
                  hintText: 'Contoh: Mengenal Kecerdasan Artifisial',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Topik tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _learningObjectivesController,
                decoration: const InputDecoration(
                  labelText: 'Tujuan Pembelajaran Utama',
                  hintText: 'Siswa mampu memahami konsep dasar kecerdasan artifisial...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tujuan pembelajaran tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final request = RppAiRequest(
                      subject: _subjectController.text,
                      grade: _gradeController.text,
                      topic: _topicController.text,
                      learningObjectives: _learningObjectivesController.text,
                      duration: _durationController.text, // Menambahkan durasi
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RppAiResultScreen(request: request),
                      ),
                    );
                  }
                },
                child: const Text('Buat RPP Sekarang'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
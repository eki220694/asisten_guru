import 'dart:io';
import 'package:asisten_guru/models/question_ai_request.dart';
import 'package:asisten_guru/models/generated_question.dart';
import 'package:asisten_guru/screens/question_result_screen.dart';
import 'package:asisten_guru/services/ai_question_service.dart';
import 'package:asisten_guru/services/real_ai_question_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:docx_template/docx_template.dart';

class QuestionGeneratorScreen extends StatefulWidget {
  const QuestionGeneratorScreen({super.key});

  @override
  QuestionGeneratorScreenState createState() => QuestionGeneratorScreenState();
}

class QuestionGeneratorScreenState extends State<QuestionGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _gradeController = TextEditingController();
  final _materialController = TextEditingController();
  final _numberOfQuestionsController = TextEditingController(text: '5');

  String _questionType = 'mixed';
  String _difficulty = 'medium';
  File? _selectedFile;
  String? _fileName;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'doc', 'docx', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = path.basename(result.files.single.path!);
      });
    }
  }

  Future<String> _readFileContent(File file) async {
    String extension = path.extension(file.path).toLowerCase();
    
    try {
      if (extension == '.pdf') {
        // Membaca konten file PDF menggunakan syncfusion_flutter_pdf
        try {
          final pdfDocument = PdfDocument(inputBytes: await file.readAsBytes());
          String content = '';
          // Membaca teks dari setiap halaman
          for (int i = 0; i < pdfDocument.pages.count; i++) {
            final text = PdfTextExtractor(pdfDocument).extractText(startPageIndex: i, endPageIndex: i);
            content += text;
          }
          pdfDocument.dispose();
          return content;
        } catch (e) {
          return "Gagal membaca file PDF: $e";
        }
      } else if (extension == '.docx') {
        // Membaca konten file Word .docx
        try {
          await DocxTemplate.fromBytes(await file.readAsBytes());
          // Untuk file .docx, kita akan mengembalikan pesan bahwa ini adalah file Word
          // Implementasi penuh memerlukan parsing yang lebih kompleks
          return "Ini adalah file Word (.docx) dengan konten yang dapat digunakan untuk membuat soal.";
        } catch (e) {
          return "Gagal membaca file Word (.docx): $e";
        }
      } else if (extension == '.doc') {
        // Membaca konten file Word .doc
        // File .doc memiliki format biner yang lebih kompleks
        // Untuk saat ini, kita akan mengembalikan pesan bahwa ini adalah file Word
        return "Ini adalah file Word (.doc) dengan konten yang dapat digunakan untuk membuat soal.";
      } else {
        // Untuk file teks biasa
        return await file.readAsString();
      }
    } catch (e) {
      // Jika gagal membaca file, kembalikan pesan error
      return "Gagal membaca file: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generator Soal AI'),
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
                  hintText: 'Contoh: Matematika',
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
                  labelText: 'Kelas',
                  hintText: 'Contoh: Kelas 10',
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
                controller: _materialController,
                decoration: const InputDecoration(
                  labelText: 'Materi',
                  hintText: 'Masukkan materi pelajaran atau topik',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if ((_selectedFile == null || _selectedFile!.path.isEmpty) && 
                      (value == null || value.isEmpty)) {
                    return 'Materi tidak boleh kosong. Anda bisa mengetik materi atau mengunggah file.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.upload_file),
                      label: Text(_fileName ?? 'Unggah File Materi (PDF/DOC/TXT)'),
                    ),
                  ),
                  if (_selectedFile != null)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedFile = null;
                          _fileName = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numberOfQuestionsController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Soal',
                  hintText: 'Contoh: 5',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah soal tidak boleh kosong';
                  }
                  final n = int.tryParse(value);
                  if (n == null || n <= 0) {
                    return 'Jumlah soal harus berupa angka positif';
                  }
                  if (n > 50) {
                    return 'Jumlah soal maksimal 50';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _questionType,
                decoration: const InputDecoration(
                  labelText: 'Tipe Soal',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'mixed', child: Text('Campuran (Pilihan Ganda & Esai)')),
                  DropdownMenuItem(value: 'multiple_choice', child: Text('Pilihan Ganda')),
                  DropdownMenuItem(value: 'essay', child: Text('Esai')),
                ],
                onChanged: (value) {
                  setState(() {
                    _questionType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _difficulty,
                decoration: const InputDecoration(
                  labelText: 'Tingkat Kesulitan',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'easy', child: Text('Mudah')),
                  DropdownMenuItem(value: 'medium', child: Text('Sedang')),
                  DropdownMenuItem(value: 'hard', child: Text('Sulit')),
                ],
                onChanged: (value) {
                  setState(() {
                    _difficulty = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Membaca konten file jika ada
                    String material = _materialController.text;
                    if (_selectedFile != null) {
                      try {
                        if (!mounted) return;
                        material = await _readFileContent(_selectedFile!);
                      } catch (e) {
                        if (!mounted) return;
                        // Simpan context dalam variabel lokal
                        final screenContext = context;
                        // Gunakan Future.microtask untuk memastikan context masih valid
                        Future.microtask(() {
                          if (screenContext.mounted) {
                            ScaffoldMessenger.of(screenContext).showSnackBar(
                              const SnackBar(content: Text('Gagal membaca file. Pastikan file dalam format yang didukung.')),
                            );
                          }
                        });
                        return;
                      }
                    }

                    final request = QuestionAiRequest(
                      subject: _subjectController.text,
                      grade: _gradeController.text,
                      material: material,
                      numberOfQuestions: int.parse(_numberOfQuestionsController.text),
                      questionType: _questionType,
                      difficulty: _difficulty,
                    );
                    
                    List<GeneratedQuestion> generatedQuestions = [];
                    try {
                      final service = RealAiQuestionService();
                      generatedQuestions = await service.generateQuestions(request);
                    } catch (e) {
                      // Log error untuk debugging
                      // print('Error using AI service: $e'); // Removed for production
                      // Jika terjadi error, gunakan implementasi lama
                      if (!mounted) return;
                      final fallbackService = AiQuestionService();
                      generatedQuestions = fallbackService.generateQuestions(request);
                    }

                    if (!mounted) return;
                    if (generatedQuestions.isEmpty) {
                      // Jika tidak ada soal yang dihasilkan, gunakan implementasi lama
                      final fallbackService = AiQuestionService();
                      if (!mounted) return;
                      generatedQuestions = fallbackService.generateQuestions(request);
                    }

                    if (!mounted) return;
                    // Simpan context dalam variabel lokal
                    final screenContext = context;
                    // Gunakan Future.microtask untuk memastikan context masih valid
                    Future.microtask(() {
                      if (screenContext.mounted) {
                        Navigator.push(
                          screenContext,
                          MaterialPageRoute(
                            builder: (ctx) => QuestionResultScreen(
                              request: request,
                              questions: generatedQuestions,
                            ),
                          ),
                        );
                      }
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Buat Soal Sekarang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
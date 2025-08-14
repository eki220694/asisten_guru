import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/quiz.dart';
import '../models/subject.dart';
import '../models/question.dart';
import 'question_detail_screen.dart';

class QuizDetailScreen extends StatefulWidget {
  final Quiz? quiz;

  const QuizDetailScreen({super.key, this.quiz});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late String _title;
  int? _selectedSubjectId;
  List<Question> _questions = [];

  late Future<List<Subject>> _subjectsFuture;

  @override
  void initState() {
    super.initState();
    _title = widget.quiz?.title ?? '';
    _selectedSubjectId = widget.quiz?.subjectId;
    _subjectsFuture = _dbHelper.getSubjects();
    if (widget.quiz != null) {
      _loadQuestions();
    }
  }

  Future<void> _loadQuestions() async {
    _questions = await _dbHelper.getQuestionsByQuiz(widget.quiz!.id!);
    setState(() {});
  }

  Future<void> _saveQuiz() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final quiz = Quiz(
        id: widget.quiz?.id,
        subjectId: _selectedSubjectId!,
        title: _title,
      );

      if (widget.quiz == null) {
        await _dbHelper.insertQuiz(quiz);
      } else {
        await _dbHelper.updateQuiz(quiz);
      }

      Navigator.pop(context, true);
    }
  }

  void _navigateAndRefreshQuestion(BuildContext context, Question? question) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuestionDetailScreen(quizId: widget.quiz!.id!, question: question)),
    );

    if (result == true) {
      _loadQuestions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz == null ? 'Tambah Kuis' : 'Edit Kuis'),
        actions: [
          if (widget.quiz != null)
            IconButton(
              icon: const Icon(Icons.preview),
              onPressed: () {
                // Navigasi ke layar pratinjau kuis
                // Implementasi pratinjau bisa ditambahkan di sini
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    decoration: const InputDecoration(
                      labelText: 'Mata Pelajaran',
                      border: OutlineInputBorder(),
                    ),
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
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Judul Kuis',
                  hintText: 'Masukkan judul kuis',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveQuiz,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Kuis'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              if (widget.quiz != null) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pertanyaan:', style: Theme.of(context).textTheme.headlineSmall),
                    Text('${_questions.length} soal', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _questions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.question_mark, size: 48, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text('Belum ada pertanyaan'),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Tambah Pertanyaan'),
                                onPressed: () => _navigateAndRefreshQuestion(context, null),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _questions.length,
                          itemBuilder: (context, index) {
                            final question = _questions[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(question.questionText),
                                subtitle: Text(
                                  question.questionType == 'multiple_choice' 
                                    ? 'Pilihan Ganda' 
                                    : 'Esai',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onTap: () => _navigateAndRefreshQuestion(context, question),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () async {
                                    await _dbHelper.deleteQuestion(question.id!);
                                    _loadQuestions();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Pertanyaan'),
                    onPressed: () => _navigateAndRefreshQuestion(context, null),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
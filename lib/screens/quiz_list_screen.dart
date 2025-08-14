import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../database/database_helper.dart';
import '../models/quiz.dart';
import '../models/subject.dart';
import 'quiz_detail_screen.dart';
import 'question_generator_screen.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late Future<List<Quiz>> _quizFuture;
  late Future<List<Subject>> _subjectFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _quizFuture = _dbHelper.getQuizzes();
      _subjectFuture = _dbHelper.getSubjects();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([_quizFuture, _subjectFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data![0].isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.quiz, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada Kuis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tekan tombol + untuk menambah kuis baru'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateAndRefresh(context, const QuizDetailScreen()),
                    icon: const Icon(Icons.add),
                    label: const Text('Buat Kuis Pertama'),
                  ),
                ],
              ),
            );
          }

          final quizzes = snapshot.data![0] as List<Quiz>;
          final subjects = snapshot.data![1] as List<Subject>;
          final groupedQuizzes = groupBy(quizzes, (Quiz quiz) => quiz.subjectId);

          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              final quizzesInSubject = groupedQuizzes[subject.id] ?? [];

              if (quizzesInSubject.isEmpty) {
                return const SizedBox.shrink();
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      const Icon(Icons.subject, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      Text(
                        subject.name, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                      ),
                      const Spacer(),
                      Chip(
                        label: Text('${quizzesInSubject.length} kuis'),
                        backgroundColor: Colors.deepPurple.withOpacity(0.1),
                        labelStyle: const TextStyle(color: Colors.deepPurple),
                      ),
                    ],
                  ),
                  initiallyExpanded: true,
                  children: quizzesInSubject.map((quiz) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(quiz.title),
                        subtitle: Text('${quiz.id}'), // ID kuis untuk referensi
                        onTap: () => _navigateAndRefresh(context, QuizDetailScreen(quiz: quiz)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () async {
                            // Konfirmasi sebelum hapus
                            final confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus Kuis'),
                                content: const Text('Apakah Anda yakin ingin menghapus kuis ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirm == true) {
                              await _dbHelper.deleteQuiz(quiz.id!);
                              _loadData();
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => _navigateAndRefresh(context, const QuizDetailScreen()),
            icon: const Icon(Icons.add),
            label: const Text('Kuis Baru'),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () => _navigateAndRefresh(context, const QuestionGeneratorScreen()),
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('Generator Soal AI'),
          ),
        ],
      ),
    );
  }
}
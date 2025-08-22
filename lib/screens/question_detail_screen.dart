import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/question.dart';
import '../models/option.dart';

class QuestionDetailScreen extends StatefulWidget {
  final int quizId;
  final Question? question;

  const QuestionDetailScreen({super.key, required this.quizId, this.question});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late String _questionText;
  late String _questionType;
  String? _correctAnswer;
  List<Option> _options = [];
  String _difficulty = 'medium'; // Tingkat kesulitan soal
  String _category = ''; // Kategori soal

  @override
  void initState() {
    super.initState();
    _questionText = widget.question?.questionText ?? '';
    _questionType = widget.question?.questionType ?? 'multiple_choice';
    _correctAnswer = widget.question?.correctAnswer;
    _difficulty = widget.question?.correctAnswer?.split('|').length == 2
        ? widget.question!.correctAnswer!.split('|')[1]
        : 'medium';
    _category = widget.question?.correctAnswer?.split('|').length == 2
        ? widget.question!.correctAnswer!.split('|')[0]
        : '';

    if (widget.question != null) {
      _loadOptions();
    }
  }

  Future<void> _loadOptions() async {
    _options = await _dbHelper.getOptionsByQuestion(widget.question!.id!);
    setState(() {});
  }

  Future<void> _saveQuestion() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Format correctAnswer untuk menyimpan kategori dan tingkat kesulitan
      String formattedCorrectAnswer = _questionType == 'multiple_choice'
          ? '$_category|$_difficulty'
          : (_correctAnswer ?? '');

      final question = Question(
        id: widget.question?.id,
        quizId: widget.quizId,
        questionText: _questionText,
        questionType: _questionType,
        correctAnswer: formattedCorrectAnswer,
      );

      int questionId;
      if (widget.question == null) {
        questionId = await _dbHelper.insertQuestion(question);
      } else {
        questionId = widget.question!.id!;
        await _dbHelper.updateQuestion(question);
      }

      // Save options for multiple choice questions
      if (_questionType == 'multiple_choice') {
        for (var option in _options) {
          option.questionId = questionId;
          if (option.id == null) {
            await _dbHelper.insertOption(option);
          } else {
            await _dbHelper.updateOption(option);
          }
        }
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  void _addOption() {
    setState(() {
      _options.add(Option(questionId: 0, optionText: '', isCorrect: false));
    });
  }

  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.question == null ? 'Tambah Pertanyaan' : 'Edit Pertanyaan',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Bantuan'),
                    content: const Text(
                      '1. Isi teks pertanyaan dengan jelas.\n'
                      '2. Pilih tipe pertanyaan (Pilihan Ganda atau Esai).\n'
                      '3. Untuk pilihan ganda, tambahkan minimal 2 pilihan jawaban dan tandai satu sebagai benar.\n'
                      '4. Untuk esai, isi jawaban yang benar.\n'
                      '5. Tentukan tingkat kesulitan dan kategori soal (opsional).',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Tutup'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _questionText,
                decoration: const InputDecoration(
                  labelText: 'Teks Pertanyaan',
                  hintText: 'Masukkan pertanyaan dengan jelas',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty
                    ? 'Teks pertanyaan tidak boleh kosong'
                    : null,
                onSaved: (value) => _questionText = value!,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _questionType,
                decoration: const InputDecoration(
                  labelText: 'Tipe Pertanyaan',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'multiple_choice',
                    child: Text('Pilihan Ganda'),
                  ),
                  DropdownMenuItem(value: 'essay', child: Text('Esai')),
                ],
                onChanged: (value) {
                  setState(() {
                    _questionType = value!;
                    if (_questionType == 'essay') {
                      _options.clear(); // Clear options if changing to essay
                    }
                  });
                },
                onSaved: (value) => _questionType = value ?? 'multiple_choice',
                // ignore: deprecated_member_use
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Kategori (Opsional)',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) => _category = value ?? '',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _difficulty,
                      decoration: const InputDecoration(
                        labelText: 'Tingkat Kesulitan',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'easy', child: Text('Mudah')),
                        DropdownMenuItem(
                          value: 'medium',
                          child: Text('Sedang'),
                        ),
                        DropdownMenuItem(value: 'hard', child: Text('Sulit')),
                      ],
                      onChanged: (value) =>
                          setState(() => _difficulty = value!),
                      onSaved: (value) => _difficulty = value ?? 'medium',
                      // ignore: deprecated_member_use
                    ),
                  ),
                ],
              ),
              if (_questionType == 'essay') ...[
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _correctAnswer,
                  decoration: const InputDecoration(
                    labelText: 'Jawaban Benar',
                    hintText: 'Masukkan jawaban yang benar',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      _questionType == 'essay' &&
                          (value == null || value.isEmpty)
                      ? 'Jawaban benar tidak boleh kosong untuk soal esai'
                      : null,
                  onSaved: (value) => _correctAnswer = value,
                ),
              ],
              if (_questionType == 'multiple_choice') ...[
                const SizedBox(height: 20),
                Text(
                  'Pilihan Jawaban:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _options.length,
                  itemBuilder: (context, index) {
                    final option = _options[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: option.optionText,
                                decoration: InputDecoration(
                                  labelText: 'Pilihan ${index + 1}',
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (value) =>
                                    _questionType == 'multiple_choice' &&
                                        (value == null || value.isEmpty)
                                    ? 'Pilihan tidak boleh kosong'
                                    : null,
                                onChanged: (value) => option.optionText = value,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                const Text('Benar?'),
                                Checkbox(
                                  value: option.isCorrect,
                                  onChanged: (value) {
                                    setState(() {
                                      // Only one option can be correct for multiple choice
                                      for (var o in _options) {
                                        o.isCorrect = false;
                                      }
                                      option.isCorrect = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _removeOption(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Tambah Pilihan'),
                    onPressed: _addOption,
                  ),
                ),
                const SizedBox(height: 16),
                // Validasi bahwa setidaknya satu pilihan ditandai sebagai benar
                if (_options.isEmpty ||
                    !_options.any((option) => option.isCorrect))
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Harap tandai salah satu pilihan sebagai jawaban yang benar',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveQuestion,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Pertanyaan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
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

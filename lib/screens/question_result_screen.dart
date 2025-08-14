import 'dart:io';
import 'package:asisten_guru/models/question_ai_request.dart';
import 'package:asisten_guru/models/generated_question.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:collection/collection.dart';
import 'package:pdf/widgets.dart' as pw;

class QuestionResultScreen extends StatefulWidget {
  final QuestionAiRequest request;
  final List<GeneratedQuestion> questions;

  const QuestionResultScreen({
    Key? key,
    required this.request,
    required this.questions,
  }) : super(key: key);

  @override
  _QuestionResultScreenState createState() => _QuestionResultScreenState();
}

class _QuestionResultScreenState extends State<QuestionResultScreen> {
  late String _questionsContent;

  @override
  void initState() {
    super.initState();
    _questionsContent = _formatQuestionsForDisplay();
  }

  String _formatQuestionsForDisplay() {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('# Soal ${widget.request.subject} - ${widget.request.grade}');
    buffer.writeln('**Materi:** ${widget.request.material}');
    buffer.writeln('**Jumlah Soal:** ${widget.request.numberOfQuestions}');
    buffer.writeln('**Tipe Soal:** ${_formatQuestionType(widget.request.questionType)}');
    buffer.writeln('**Tingkat Kesulitan:** ${_formatDifficulty(widget.request.difficulty ?? 'medium')}');
    buffer.writeln('');
    buffer.writeln('---');
    buffer.writeln('');

    // Soal
    for (int i = 0; i < widget.questions.length; i++) {
      final question = widget.questions[i];
      buffer.writeln('**${i + 1}. ${question.questionText}** (${_formatQuestionType(question.type)})');
      
      if (question.type == 'multiple_choice' && question.options != null) {
        // Urutkan opsi berdasarkan teks untuk konsistensi
        final sortedOptions = List<GeneratedQuestionOption>.from(question.options!);
        for (int j = 0; j < sortedOptions.length; j++) {
          buffer.writeln('${String.fromCharCode(97 + j)}. ${sortedOptions[j].text}');
        }
      }
      
      if (question.type == 'essay' && question.answer != null) {
        buffer.writeln('');
        buffer.writeln('*Jawaban contoh:* ${question.answer}');
      }
      
      buffer.writeln('');
    }

    return buffer.toString();
  }

  String _formatQuestionType(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Pilihan Ganda';
      case 'essay':
        return 'Esai';
      case 'mixed':
        return 'Campuran';
      default:
        return type;
    }
  }

  String _formatDifficulty(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 'Mudah';
      case 'medium':
        return 'Sedang';
      case 'hard':
        return 'Sulit';
      default:
        return difficulty;
    }
  }

  Future<void> _copyQuestions() async {
    final plainText = _formatQuestionsAsPlainText();
    await Clipboard.setData(ClipboardData(text: plainText));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Soal telah disalin ke clipboard')),
      );
    }
  }

  String _formatQuestionsAsPlainText() {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Soal ${widget.request.subject} - ${widget.request.grade}');
    buffer.writeln('Materi: ${widget.request.material}');
    buffer.writeln('Jumlah Soal: ${widget.request.numberOfQuestions}');
    buffer.writeln('Tipe Soal: ${_formatQuestionType(widget.request.questionType)}');
    buffer.writeln('Tingkat Kesulitan: ${_formatDifficulty(widget.request.difficulty ?? 'medium')}');
    buffer.writeln('');

    // Soal
    for (int i = 0; i < widget.questions.length; i++) {
      final question = widget.questions[i];
      buffer.writeln('${i + 1}. ${question.questionText} (${_formatQuestionType(question.type)})');
      
      if (question.type == 'multiple_choice' && question.options != null) {
        // Urutkan opsi berdasarkan teks untuk konsistensi
        final sortedOptions = List<GeneratedQuestionOption>.from(question.options!);
        for (int j = 0; j < sortedOptions.length; j++) {
          buffer.writeln('   ${String.fromCharCode(97 + j)}. ${sortedOptions[j].text}');
        }
      }
      
      if (question.type == 'essay' && question.answer != null) {
        buffer.writeln('   Jawaban contoh: ${question.answer}');
      }
      
      buffer.writeln('');
    }

    return buffer.toString();
  }

  Future<void> _exportToWord() async {
    try {
      final docContent = _generateWordDocument();
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/soal_${widget.request.subject}_${DateTime.now().millisecondsSinceEpoch}.doc';
      final file = File(filePath);
      await file.writeAsString(docContent, encoding: utf8);

      // Perlu menyimpan file terlebih dahulu sebelum sharing
      await SharePlus.instance.share(
        text: 'Berikut adalah file soal yang dihasilkan. File tersedia di: $filePath',
        subject: 'Soal ${widget.request.subject} - ${widget.request.grade}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengekspor ke Word: $e')),
        );
      }
    }
  }

  String _generateWordDocument() {
    final buffer = StringBuffer();
    
    // Header Word Document
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html>');
    buffer.writeln('<head>');
    buffer.writeln('<meta charset="UTF-8">');
    buffer.writeln('<title>Soal ${widget.request.subject} - ${widget.request.grade}</title>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');
    
    // Title
    buffer.writeln('<h1>Soal ${widget.request.subject} - ${widget.request.grade}</h1>');
    
    // Info
    buffer.writeln('<p><strong>Materi:</strong> ${widget.request.material}</p>');
    buffer.writeln('<p><strong>Jumlah Soal:</strong> ${widget.request.numberOfQuestions}</p>');
    buffer.writeln('<p><strong>Tipe Soal:</strong> ${_formatQuestionType(widget.request.questionType)}</p>');
    buffer.writeln('<p><strong>Tingkat Kesulitan:</strong> ${_formatDifficulty(widget.request.difficulty ?? 'medium')}</p>');
    
    buffer.writeln('<br>');
    
    // Questions
    for (int i = 0; i < widget.questions.length; i++) {
      final question = widget.questions[i];
      buffer.writeln('<p><strong>${i + 1}. ${question.questionText}</strong> (${_formatQuestionType(question.type)})</p>');
      
      if (question.type == 'multiple_choice' && question.options != null) {
        buffer.writeln('<ol type="a">');
        // Urutkan opsi berdasarkan teks untuk konsistensi
        final sortedOptions = List<GeneratedQuestionOption>.from(question.options!);
        for (int j = 0; j < sortedOptions.length; j++) {
          buffer.writeln('<li>${sortedOptions[j].text}</li>');
        }
        buffer.writeln('</ol>');
      }
      
      if (question.type == 'essay' && question.answer != null) {
        buffer.writeln('<p><strong>Jawaban contoh:</strong> ${question.answer}</p>');
      }
      
      buffer.writeln('<br>');
    }
    
    buffer.writeln('</body>');
    buffer.writeln('</html>');
    
    return buffer.toString();
  }

  Future<void> _exportToPdf() async {
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'Soal ${widget.request.subject} - ${widget.request.grade}',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Materi: ${widget.request.material}'),
                pw.Text('Jumlah Soal: ${widget.request.numberOfQuestions}'),
                pw.Text('Tipe Soal: ${_formatQuestionType(widget.request.questionType)}'),
                pw.Text('Tingkat Kesulitan: ${_formatDifficulty(widget.request.difficulty ?? 'medium')}'),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
                ...widget.questions.mapIndexed((index, question) {
                  List<pw.Widget> questionWidgets = [
                    pw.Text(
                      '${index + 1}. ${question.questionText} (${_formatQuestionType(question.type)})',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 10),
                  ];
                  
                  if (question.type == 'multiple_choice' && question.options != null) {
                    // Urutkan opsi berdasarkan teks untuk konsistensi
                    final sortedOptions = List<GeneratedQuestionOption>.from(question.options!);
                    for (int j = 0; j < sortedOptions.length; j++) {
                      questionWidgets.add(
                        pw.Text('${String.fromCharCode(97 + j)}. ${sortedOptions[j].text}'),
                      );
                    }
                  }
                  
                  if (question.type == 'essay' && question.answer != null) {
                    questionWidgets.add(
                      pw.Text('Jawaban contoh: ${question.answer}', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
                    );
                  }
                  
                  questionWidgets.add(pw.SizedBox(height: 20));
                  
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: questionWidgets,
                  );
                }).toList(),
              ],
            );
          },
        ),
      );
      
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/soal_${widget.request.subject}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      
      await file.writeAsBytes(await pdf.save());
      
      // Perlu menyimpan file terlebih dahulu sebelum sharing
      await SharePlus.instance.share(
        text: 'Berikut adalah file soal yang dihasilkan. File tersedia di: $filePath',
        subject: 'Soal ${widget.request.subject} - ${widget.request.grade}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengekspor ke PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Generator Soal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Salin Soal',
            onPressed: _copyQuestions,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            tooltip: 'Unduh',
            onSelected: (String result) {
              if (result == 'word') {
                _exportToWord();
              } else if (result == 'pdf') {
                _exportToPdf();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'word',
                child: Text('Unduh sebagai Word'),
              ),
              const PopupMenuItem<String>(
                value: 'pdf',
                child: Text('Unduh sebagai PDF'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: MarkdownBody(
          data: _questionsContent,
          styleSheet: MarkdownStyleSheet(
            h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            p: const TextStyle(fontSize: 16),
            strong: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
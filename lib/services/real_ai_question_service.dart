import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:asisten_guru/models/question_ai_request.dart';
import 'package:asisten_guru/models/generated_question.dart';
import 'package:asisten_guru/services/ai_question_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class RealAiQuestionService {
  // API key dari environment variable (lebih aman)
  String get _apiKey {
    // Untuk pengembangan lokal, bisa menggunakan environment variable
    // Untuk produksi, sebaiknya gunakan secret management
    if (kIsWeb) {
      // Untuk web, kita tidak bisa menggunakan environment variable dengan aman
      // API key harus diatur di sisi client atau gunakan proxy server
      return '';
    } else {
      // Untuk mobile/desktop, ambil dari environment variable
      return Platform.environment['OPENAI_API_KEY'] ?? '';
    }
  }
  
  // Endpoint API (contoh untuk OpenAI)
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  
  Future<List<GeneratedQuestion>> generateQuestions(QuestionAiRequest request) async {
    // Cek apakah API key tersedia
    if (_apiKey.isEmpty) {
      return _fallbackToOldImplementation(request);
    }
    
    try {
      // Membuat prompt untuk AI berdasarkan permintaan pengguna
      final prompt = _buildPrompt(request);
      
      // Mengirim permintaan ke API AI dengan timeout
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo', // atau model lain yang Anda gunakan
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
        }),
      ).timeout(Duration(seconds: 30)); // Timeout setelah 30 detik
      
      if (response.statusCode == 200) {
        // Mem-parsing respons dari AI
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];
        
        // Mengonversi respons AI ke objek GeneratedQuestion
        return _parseAiResponse(aiResponse, request.numberOfQuestions);
      } else {
        // Jika API gagal, kembali ke implementasi lama
        return _fallbackToOldImplementation(request);
      }
    } catch (e) {
      // Jika terjadi error (termasuk timeout), kembali ke implementasi lama
      return _fallbackToOldImplementation(request);
    }
  }
  
  String _buildPrompt(QuestionAiRequest request) {
    return '''
Berdasarkan materi berikut:
"${request.material}"

Buatlah ${request.numberOfQuestions} soal ${request.questionType == 'multiple_choice' ? 'pilihan ganda' : request.questionType == 'essay' ? 'esai' : 'campuran'} 
untuk mata pelajaran ${request.subject} kelas ${request.grade} 
dengan tingkat kesulitan ${_difficultyToIndonesian(request.difficulty ?? 'medium')}.

Petunjuk:
1. Soal harus relevan dengan materi yang diberikan
2. Untuk soal pilihan ganda, berikan 4 opsi dengan 1 jawaban yang benar
3. Untuk soal esai, berikan panduan jawaban yang diharapkan
4. Gunakan bahasa Indonesia yang baik dan benar

Format untuk soal pilihan ganda:
1. [Soal]
A. [Opsi A]
B. [Opsi B]
C. [Opsi C]
D. [Opsi D]
Jawaban yang benar: [Huruf opsi yang benar]

Format untuk soal esai:
1. [Soal]
Jawaban: [Jawaban yang diharapkan]

Materi: ${request.material}
''';
  }
  
  String _difficultyToIndonesian(String difficulty) {
    switch (difficulty) {
      case 'easy': return 'mudah';
      case 'medium': return 'sedang';
      case 'hard': return 'sulit';
      default: return 'sedang';
    }
  }
  
  List<GeneratedQuestion> _parseAiResponse(String response, int expectedCount) {
    // Implementasi parsing respons AI ke objek GeneratedQuestion
    // Ini adalah implementasi yang lebih robust, bisa menangani berbagai format respons AI
    
    List<GeneratedQuestion> questions = [];
    
    // Mencoba memisahkan respons berdasarkan pola umum
    List<String> questionBlocks = [];
    
    // Coba beberapa pola pemisahan
    if (response.contains(RegExp(r'\n\d+\.'))) {
      questionBlocks = response.split(RegExp(r'\n\d+\.'));
    } else if (response.contains(RegExp(r'\d+\.'))) {
      questionBlocks = response.split(RegExp(r'\d+\.'));
    } else {
      // Jika tidak ada pola yang cocok, anggap seluruh respons sebagai satu blok
      questionBlocks = ['', response];
    }
    
    for (int i = 1; i < questionBlocks.length && questions.length < expectedCount; i++) {
      final block = questionBlocks[i].trim();
      if (block.isEmpty) continue;
      
      // Menentukan tipe soal berdasarkan keberadaan opsi pilihan
      if (block.contains(RegExp(r'[A-Da-d]\s*\.')) || block.contains(RegExp(r'[A-Da-d]\.'))) {
        // Soal pilihan ganda
        try {
          final questionData = _parseMultipleChoiceQuestion(block, questions.length + 1);
          if (questionData != null) {
            questions.add(questionData);
          }
        } catch (e) {
          // Jika parsing gagal, lewati soal ini
          continue;
        }
      } else {
        // Soal esai
        try {
          final questionData = _parseEssayQuestion(block, questions.length + 1);
          if (questionData != null) {
            questions.add(questionData);
          }
        } catch (e) {
          // Jika parsing gagal, lewati soal ini
          continue;
        }
      }
    }
    
    return questions;
  }
  
  GeneratedQuestion? _parseMultipleChoiceQuestion(String block, int number) {
    // Memisahkan bagian soal dan jawaban
    final lines = block.split('\n');
    if (lines.isEmpty) return null;
    
    String questionText = '';
    List<GeneratedQuestionOption> options = [];
    String? correctAnswer;
    
    // Mencari baris dengan jawaban yang benar
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.toLowerCase().startsWith('jawaban yang benar:') || 
          line.toLowerCase().startsWith('jawaban:')) {
        correctAnswer = line.split(':').last.trim();
        // Ambil hanya huruf pertama jika berupa kalimat
        if (correctAnswer.length > 1) {
          final match = RegExp(r'[A-Da-d]').firstMatch(correctAnswer);
          if (match != null) {
            correctAnswer = match.group(0)?.toUpperCase();
          }
        } else {
          correctAnswer = correctAnswer.toUpperCase();
        }
        break;
      }
    }
    
    // Mengumpulkan opsi jawaban
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;
      
      // Cek apakah ini baris soal (sebelum opsi)
      if (trimmedLine.startsWith(RegExp(r'^[A-Da-d][\.\)]')) && trimmedLine.length > 2) {
        final letter = trimmedLine.substring(0, 1).toUpperCase();
        final optionText = trimmedLine.substring(2).trim();
        final isCorrect = correctAnswer == letter;
        
        options.add(GeneratedQuestionOption(
          text: optionText,
          isCorrect: isCorrect,
        ));
      } else if (!trimmedLine.toLowerCase().startsWith('jawaban') && 
                 !trimmedLine.contains(RegExp(r'[A-Da-d][\.\)]'))) {
        // Ini kemungkinan bagian dari soal
        if (questionText.isEmpty) {
          questionText = trimmedLine;
        }
      }
    }
    
    // Jika tidak ada opsi yang ditemukan, coba pendekatan alternatif
    if (options.isEmpty) {
      // Coba ekstrak soal dan opsi dengan cara lain
      final parts = block.split(RegExp(r'\n\s*[A-Da-d][\.\)]', caseSensitive: false));
      if (parts.isNotEmpty) {
        questionText = parts[0].trim();
        
        // Ekstrak opsi dari bagian lainnya
        final optionMatches = RegExp(r'[A-Da-d][\.\)]\s*(.+)', caseSensitive: false).allMatches(block);
        for (var match in optionMatches) {
          final letter = match.group(0)!.substring(0, 1).toUpperCase();
          final optionText = match.group(1)!.trim();
          final isCorrect = correctAnswer == letter;
          
          options.add(GeneratedQuestionOption(
            text: optionText,
            isCorrect: isCorrect,
          ));
        }
      }
    }
    
    // Pastikan kita memiliki setidaknya 2 opsi
    if (options.length < 2) return null;
    
    return GeneratedQuestion(
      questionText: '$number. $questionText',
      type: 'multiple_choice',
      options: options,
    );
  }
  
  GeneratedQuestion? _parseEssayQuestion(String block, int number) {
    // Memisahkan soal dan jawaban
    final parts = block.split(RegExp(r'\n\s*jawaban(?:\s+yang\s+benar)?:', caseSensitive: false));
    
    if (parts.isEmpty) return null;
    
    final questionText = parts[0].trim();
    final answer = parts.length > 1 ? parts[1].trim() : '';
    
    if (questionText.isEmpty) return null;
    
    return GeneratedQuestion(
      questionText: '$number. $questionText',
      type: 'essay',
      answer: answer.isNotEmpty ? answer : null,
    );
  }
  
  List<GeneratedQuestion> _fallbackToOldImplementation(QuestionAiRequest request) {
    // Implementasi fallback ke layanan AI lama
    final fallbackService = AiQuestionService();
    try {
      return fallbackService.generateQuestions(request);
    } catch (e) {
      // Jika layanan lama juga gagal, kembalikan daftar kosong
      return [];
    }
  }
}
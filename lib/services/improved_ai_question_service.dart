import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:asisten_guru/models/question_ai_request.dart';
import 'package:asisten_guru/models/generated_question.dart';

class ImprovedAiQuestionService {
  final String apiKey;
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';
  
  ImprovedAiQuestionService(this.apiKey);
  
  Future<List<GeneratedQuestion>> generateQuestions(QuestionAiRequest request) async {
    if (apiKey.isEmpty) {
      throw Exception('API key tidak ditemukan. Silakan atur API key OpenAI.');
    }
    
    try {
      final prompt = _buildImprovedPrompt(request);
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''
Anda adalah ahli pembuat soal pendidikan yang sangat berpengalaman. 
Tugas Anda adalah membuat soal berkualitas tinggi dengan format yang sangat presisi.
Ikuti instruksi format dengan sangat ketat tanpa pengecualian.
'''
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': _getTemperature(request.difficulty ?? 'medium'),
          'max_tokens': 2000,
        }),
      ).timeout(Duration(seconds: 45));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];
        return _parseImprovedAiResponse(aiResponse);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('AI service error: ${errorData['error']['message']}');
      }
    } catch (e) {
      throw Exception('Gagal menghubungi AI service: ${e.toString()}');
    }
  }
  
  String _buildImprovedPrompt(QuestionAiRequest request) {
    final questionTypeDescription = _getQuestionTypeDescription(request.questionType);
    final difficultyDescription = _getDifficultyDescription(request.difficulty ?? 'medium');
    
    return '''
BUATLAH SOAL DENGAN FORMAT YANG SANGAT PRESISI SESUAI INSTRUKSI BERIKUT:

MATERI PEMBELAJARAN:
"${request.material}"

INFORMASI SOAL:
- Mata Pelajaran: ${request.subject}
- Kelas: ${request.grade}
- Jumlah Soal: ${request.numberOfQuestions}
- Tipe Soal: $questionTypeDescription
- Tingkat Kesulitan: $difficultyDescription

FORMAT WAJIB UNTUK SETIAP SOAL:

UNTUK SOAL PILIHAN GANDA:
===
SOAL [nomor]:
[Teks soal]

A. [Opsi A]
B. [Opsi B]
C. [Opsi C]
D. [Opsi D]

JAWABAN YANG BENAR: [A/B/C/D]
===

UNTUK SOAL ESSAI:
===
SOAL [nomor]:
[Teks soal]

JAWABAN YANG DIHARAPKAN:
[Jawaban singkat dan padat]
===

CONTOH FORMAT YANG BENAR:

SOAL 1:
Apa ibu kota Indonesia?

A. Jakarta
B. Surabaya
C. Bandung
D. Medan

JAWABAN YANG BENAR: A

SOAL 2:
Jelaskan pentingnya menjaga kebersihan lingkungan.

JAWABAN YANG DIHARAPKAN:
Kebersihan lingkungan penting untuk kesehatan, kenyamanan, dan keindahan tempat tinggal kita.

PETUNJUK PENTING:
1. BUATLAH SOAL YANG RELEVAN DENGAN MATERI
2. PASTIKAN FORMAT SETIAP SOAL SESUAI CONTOH
3. GUNAKAN BAHASA INDONESIA YANG BAKU DAN JELAS
4. JANGAN MENAMBAHKAN TEKS TAMBAHAN SELAIN FORMAT YANG DIMINTA
5. JANGAN MENGGUNAKAN MARKDOWN ATAU FORMAT KHUSUS LAINNYA
''';
  }
  
  String _getQuestionTypeDescription(String questionType) {
    switch (questionType) {
      case 'multiple_choice': return 'Pilihan Ganda';
      case 'essay': return 'Essai/Uraian';
      case 'mixed': return 'Campuran (Pilihan Ganda dan Essai)';
      default: return 'Campuran';
    }
  }
  
  String _getDifficultyDescription(String difficulty) {
    switch (difficulty) {
      case 'easy': return 'Mudah';
      case 'medium': return 'Sedang';
      case 'hard': return 'Sulit';
      default: return 'Sedang';
    }
  }
  
  double _getTemperature(String difficulty) {
    switch (difficulty) {
      case 'easy': return 0.3;
      case 'medium': return 0.5;
      case 'hard': return 0.7;
      default: return 0.5;
    }
  }
  
  List<GeneratedQuestion> _parseImprovedAiResponse(String response) {
    final questions = <GeneratedQuestion>[];
    
    // Pisahkan respons menjadi blok-blok soal
    final questionBlocks = _splitIntoQuestionBlocks(response);
    
    for (final block in questionBlocks) {
      try {
        final question = _parseQuestionBlock(block);
        if (question != null) {
          questions.add(question);
        }
      } catch (e) {
        // Lewati soal yang tidak bisa diparsing
        continue;
      }
    }
    
    return questions;
  }
  
  List<String> _splitIntoQuestionBlocks(String response) {
    final blocks = <String>[];
    final lines = LineSplitter.split(response).toList();
    
    List<String> currentBlock = [];
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // Deteksi awal soal baru
      if (trimmedLine.startsWith('SOAL ') && trimmedLine.contains(':')) {
        // Simpan blok sebelumnya jika ada
        if (currentBlock.isNotEmpty) {
          blocks.add(currentBlock.join('\n'));
          currentBlock.clear();
        }
        currentBlock.add(trimmedLine);
      } else if (trimmedLine.isNotEmpty) {
        currentBlock.add(trimmedLine);
      }
    }
    
    // Simpan blok terakhir
    if (currentBlock.isNotEmpty) {
      blocks.add(currentBlock.join('\n'));
    }
    
    return blocks;
  }
  
  GeneratedQuestion? _parseQuestionBlock(String block) {
    final lines = LineSplitter.split(block).toList();
    if (lines.isEmpty) return null;
    
    // Tentukan tipe soal berdasarkan keberadaan opsi
    final hasOptions = lines.any((line) => 
      line.trim().startsWith(RegExp(r'^[A-Da-d][\.:]')));
    
    if (hasOptions) {
      return _parseMultipleChoiceQuestion(lines);
    } else {
      return _parseEssayQuestion(lines);
    }
  }
  
  GeneratedQuestion? _parseMultipleChoiceQuestion(List<String> lines) {
    String questionText = '';
    final options = <GeneratedQuestionOption>[];
    String? correctAnswerLetter;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;
      
      // Ekstrak teks soal
      if (trimmedLine.startsWith('SOAL ') && trimmedLine.contains(':')) {
        questionText = trimmedLine.split(':').skip(1).join(':').trim();
        continue;
      }
      
      // Ekstrak opsi jawaban
      if (trimmedLine.startsWith(RegExp(r'^[A-Da-d][\.:]'))) {
        final match = RegExp(r'^([A-Da-d])[\.:]\s*(.+)$').firstMatch(trimmedLine);
        if (match != null) {
          final optionText = match.group(2)!.trim();
          options.add(GeneratedQuestionOption(
            text: optionText,
            isCorrect: false, // Akan diatur nanti
          ));
        }
        continue;
      }
      
      // Ekstrak jawaban yang benar
      if (trimmedLine.startsWith('JAWABAN YANG BENAR:')) {
        final answerPart = trimmedLine.replaceFirst('JAWABAN YANG BENAR:', '').trim();
        if (answerPart.length == 1) {
          correctAnswerLetter = answerPart.toUpperCase();
        } else {
          // Coba ekstrak huruf dari teks
          final letterMatch = RegExp(r'[A-Da-d]').firstMatch(answerPart);
          if (letterMatch != null) {
            correctAnswerLetter = letterMatch.group(0)!.toUpperCase();
          }
        }
        continue;
      }
    }
    
    // Tandai opsi yang benar
    if (correctAnswerLetter != null) {
      for (var i = 0; i < options.length; i++) {
        // Periksa apakah huruf opsi cocok dengan jawaban yang benar
        if (String.fromCharCode(65 + i) == correctAnswerLetter) {
          options[i] = GeneratedQuestionOption(
            text: options[i].text,
            isCorrect: true,
          );
        }
      }
    }
    
    // Jika tidak ada opsi yang ditandai sebagai benar, tandai yang pertama sebagai benar
    if (options.isNotEmpty && !options.any((option) => option.isCorrect)) {
      options[0] = GeneratedQuestionOption(
        text: options[0].text,
        isCorrect: true,
      );
    }
    
    if (questionText.isEmpty || options.length < 2) return null;
    
    return GeneratedQuestion(
      questionText: questionText,
      type: 'multiple_choice',
      options: options,
    );
  }
  
  GeneratedQuestion? _parseEssayQuestion(List<String> lines) {
    String questionText = '';
    String expectedAnswer = '';
    
    bool collectingAnswer = false;
    final questionLines = <String>[];
    final answerLines = <String>[];
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;
      
      if (trimmedLine.startsWith('SOAL ') && trimmedLine.contains(':')) {
        questionText = trimmedLine.split(':').skip(1).join(':').trim();
        continue;
      }
      
      if (trimmedLine.startsWith('JAWABAN YANG DIHARAPKAN:')) {
        collectingAnswer = true;
        final answerPart = trimmedLine.replaceFirst('JAWABAN YANG DIHARAPKAN:', '').trim();
        if (answerPart.isNotEmpty) {
          answerLines.add(answerPart);
        }
        continue;
      }
      
      if (collectingAnswer) {
        answerLines.add(trimmedLine);
      } else if (questionText.isNotEmpty) {
        // Lanjutan dari soal
        questionLines.add(trimmedLine);
      }
    }
    
    if (questionText.isEmpty) return null;
    
    // Gabungkan teks soal jika ada lanjutan
    if (questionLines.isNotEmpty) {
      questionText += '\n${questionLines.join('\n')}';
    }
    
    expectedAnswer = answerLines.join('\n').trim();
    
    return GeneratedQuestion(
      questionText: questionText,
      type: 'essay',
      answer: expectedAnswer.isNotEmpty ? expectedAnswer : null,
    );
  }
}
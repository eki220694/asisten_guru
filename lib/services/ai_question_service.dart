import 'dart:math';
import 'package:asisten_guru/models/question_ai_request.dart';
import 'package:asisten_guru/models/generated_question.dart';

class AiQuestionService {
  final Random _random = Random();
  
  List<GeneratedQuestion> generateQuestions(QuestionAiRequest request) {
    List<GeneratedQuestion> questions = [];
    
    // Menentukan jumlah soal untuk setiap tipe berdasarkan pilihan pengguna
    int multipleChoiceCount = 0;
    int essayCount = 0;
    
    if (request.questionType == 'multiple_choice') {
      multipleChoiceCount = request.numberOfQuestions;
    } else if (request.questionType == 'essay') {
      essayCount = request.numberOfQuestions;
    } else {
      // Untuk tipe campuran, kita akan membuat 60% pilihan ganda dan 40% esai
      multipleChoiceCount = (request.numberOfQuestions * 0.6).round();
      essayCount = request.numberOfQuestions - multipleChoiceCount;
    }
    
    // Generate soal pilihan ganda
    for (int i = 0; i < multipleChoiceCount; i++) {
      questions.add(_generateMultipleChoiceQuestion(request, i + 1));
    }
    
    // Generate soal esai
    for (int i = 0; i < essayCount; i++) {
      questions.add(_generateEssayQuestion(request, i + 1));
    }
    
    return questions;
  }
  
  GeneratedQuestion _generateMultipleChoiceQuestion(QuestionAiRequest request, int number) {
    // Menentukan tingkat kesulitan
    String difficulty = request.difficulty ?? 'medium';
    
    // Membuat soal berdasarkan tingkat kesulitan dan materi
    String questionText = "";
    List<GeneratedQuestionOption> options = [];
    
    // Memecah materi menjadi kata-kata untuk digunakan dalam soal
    List<String> materialWords = request.material.split(RegExp(r'[^a-zA-Z0-9]'));
    materialWords.removeWhere((element) => element.isEmpty);
    
    String mainTopic = materialWords.isNotEmpty ? materialWords.first : request.material;
    if (materialWords.length > 1) {
      mainTopic = materialWords.take(min(3, materialWords.length)).join(' ');
    }
    
    switch (difficulty) {
      case 'easy':
        // Soal mudah tentang konsep dasar
        List<String> easyQuestions = [
          "Apa yang dimaksud dengan '$mainTopic' dalam konteks ${request.subject}?",
          "Apa fungsi utama dari '$mainTopic' dalam ${request.subject}?",
          "Manakah yang merupakan ciri utama dari '$mainTopic'?",
          "Apa definisi dasar dari '$mainTopic'?",
        ];
        
        questionText = easyQuestions[_random.nextInt(easyQuestions.length)];
        
        List<List<GeneratedQuestionOption>> easyOptions = [
          [
            GeneratedQuestionOption(text: "Konsep dasar yang menjelaskan prinsip kerja $mainTopic", isCorrect: true),
            GeneratedQuestionOption(text: "Sebuah teori kompleks yang sulit dipahami", isCorrect: false),
            GeneratedQuestionOption(text: "Alat untuk mengukur suatu fenomena", isCorrect: false),
            GeneratedQuestionOption(text: "Sebuah metode pengajaran kuno", isCorrect: false),
          ],
          [
            GeneratedQuestionOption(text: "Untuk memahami dan menerapkan prinsip-prinsip $mainTopic", isCorrect: true),
            GeneratedQuestionOption(text: "Untuk menghafalkan fakta-fakta tanpa pemahaman", isCorrect: false),
            GeneratedQuestionOption(text: "Untuk mengabaikan prinsip ilmiah", isCorrect: false),
            GeneratedQuestionOption(text: "Untuk membuat teori yang rumit", isCorrect: false),
          ],
          [
            GeneratedQuestionOption(text: "Memiliki prinsip dasar yang dapat diterapkan", isCorrect: true),
            GeneratedQuestionOption(text: "Sulit dipahami oleh pemula", isCorrect: false),
            GeneratedQuestionOption(text: "Hanya digunakan dalam penelitian", isCorrect: false),
            GeneratedQuestionOption(text: "Tidak memiliki aplikasi praktis", isCorrect: false),
          ],
          [
            GeneratedQuestionOption(text: "Penjelasan singkat tentang konsep $mainTopic", isCorrect: true),
            GeneratedQuestionOption(text: "Sebuah rumus matematika kompleks", isCorrect: false),
            GeneratedQuestionOption(text: "Sebuah alat ukur", isCorrect: false),
            GeneratedQuestionOption(text: "Sebuah metode pengajaran", isCorrect: false),
          ],
        ];
        
        options = easyOptions[_random.nextInt(easyOptions.length)];
        break;
        
      case 'medium':
        // Soal sedang tentang aplikasi dan hubungan
        List<String> mediumQuestions = [
          "Bagaimana '$mainTopic' dapat diterapkan dalam kehidupan sehari-hari?",
          "Jelaskan hubungan antara '$mainTopic' dan penerapannya dalam ${request.subject}.",
          "Apa manfaat mempelajari '$mainTopic' dalam konteks ${request.grade}?",
          "Bagaimana '$mainTopic' berkontribusi pada pemahaman konsep ${request.subject}?",
        ];
        
        questionText = mediumQuestions[_random.nextInt(mediumQuestions.length)];
        
        List<List<GeneratedQuestionOption>> mediumOptions = [
          [
            GeneratedQuestionOption(text: "Memiliki aplikasi langsung dalam teknologi dan solusi sehari-hari", isCorrect: true),
            GeneratedQuestionOption(text: "Hanya relevan dalam konteks akademis", isCorrect: false),
            GeneratedQuestionOption(text: "Tidak memiliki aplikasi praktis", isCorrect: false),
            GeneratedQuestionOption(text: "Hanya digunakan dalam penelitian ilmiah", isCorrect: false),
          ],
          [
            GeneratedQuestionOption(text: "Materi ini menjadi dasar untuk memahami konsep lebih kompleks", isCorrect: true),
            GeneratedQuestionOption(text: "Materi ini tidak memiliki keterkaitan dengan penerapan", isCorrect: false),
            GeneratedQuestionOption(text: "Materi ini hanya digunakan untuk ujian", isCorrect: false),
            GeneratedQuestionOption(text: "Materi ini bersifat abstrak tanpa aplikasi", isCorrect: false),
          ],
          [
            GeneratedQuestionOption(text: "Memberikan fondasi penting untuk memahami konsep lanjutan", isCorrect: true),
            GeneratedQuestionOption(text: "Tidak memberikan nilai tambah dalam pembelajaran", isCorrect: false),
            GeneratedQuestionOption(text: "Hanya merupakan materi tambahan", isCorrect: false),
            GeneratedQuestionOption(text: "Sulit dipahami sehingga tidak bermanfaat", isCorrect: false),
          ],
          [
            GeneratedQuestionOption(text: "Dengan memahami $mainTopic, siswa dapat menguasai konsep inti ${request.subject}", isCorrect: true),
            GeneratedQuestionOption(text: "Materi ini tidak berkontribusi pada pemahaman keseluruhan", isCorrect: false),
            GeneratedQuestionOption(text: "Hanya menghambat proses pembelajaran", isCorrect: false),
            GeneratedQuestionOption(text: "Menyulitkan pemahaman konsep lainnya", isCorrect: false),
          ],
        ];
        
        options = mediumOptions[_random.nextInt(mediumOptions.length)];
        break;
        
      case 'hard':
        // Soal sulit tentang analisis dan evaluasi
        List<String> hardQuestions = [
          "Analisis dampak jangka panjang dari penerapan konsep '$mainTopic' dalam bidang ${request.subject}.",
          "Evaluasi implikasi dari penggunaan '$mainTopic' terhadap pengembangan teknologi di masa depan.",
          "Bandingkan pendekatan '$mainTopic' dengan metode alternatif dalam menyelesaikan masalah ${request.subject}.",
          "Kritik kelemahan dari penerapan '$mainTopic' dalam konteks ${request.subject} dan usulkan perbaikan.",
        ];
        
        questionText = hardQuestions[_random.nextInt(hardQuestions.length)];
        
        List<List<GeneratedQuestionOption>> hardOptions = [
          [
            GeneratedQuestionOption(text: "Dapat mengubah paradigma pemahaman kita terhadap fenomena terkait dan membuka peluang inovasi", isCorrect: true),
            GeneratedQuestionOption(text: "Tidak memberikan kontribusi signifikan terhadap pengembangan ilmu", isCorrect: false),
            GeneratedQuestionOption(text: "Hanya relevan dalam konteks teoritis", isCorrect: false),
            GeneratedQuestionOption(text: "Menyebabkan stagnasi dalam penelitian", isCorrect: false),
          ],
          [
            GeneratedQuestionOption(text: "Memberikan landasan untuk pengembangan teknologi yang lebih maju dan efisien", isCorrect: true),
            GeneratedQuestionOption(text: "Menghambat perkembangan teknologi karena kompleksitasnya", isCorrect: false),
            GeneratedQuestionOption(text: "Tidak memiliki dampak terhadap pengembangan teknologi", isCorrect: false),
            GeneratedQuestionOption(text: "Hanya relevan dalam jangka pendek", isCorrect: false),
          ],
          [
            GeneratedQuestionOption(text: "$mainTopic menawarkan pendekatan yang efektif, namun metode alternatif mungkin lebih sesuai untuk kasus tertentu", isCorrect: true),
            GeneratedQuestionOption(text: "Metode alternatif selalu lebih baik daripada $mainTopic", isCorrect: false),
            GeneratedQuestionOption(text: "$mainTopic adalah satu-satunya pendekatan yang valid", isCorrect: false),
            GeneratedQuestionOption(text: "Tidak ada perbedaan signifikan antara pendekatan", isCorrect: false),
          ],
          [
            GeneratedQuestionOption(text: "Meskipun $mainTopic memiliki kelemahan, perbaikan dapat dilakukan melalui optimasi dan penyesuaian konteks", isCorrect: true),
            GeneratedQuestionOption(text: "$mainTopic tidak memiliki kelemahan yang signifikan", isCorrect: false),
            GeneratedQuestionOption(text: "$mainTopic sebaiknya diabaikan karena kelemahannya", isCorrect: false),
            GeneratedQuestionOption(text: "Tidak ada solusi untuk kelemahan yang ada", isCorrect: false),
          ],
        ];
        
        options = hardOptions[_random.nextInt(hardOptions.length)];
        break;
        
      default:
        questionText = "Apa itu $mainTopic dalam ${request.subject}?";
        options = [
          GeneratedQuestionOption(text: "Sebuah konsep penting dalam ${request.subject} yang menjelaskan tentang...", isCorrect: true),
          GeneratedQuestionOption(text: "Sebuah teori yang sudah usang", isCorrect: false),
          GeneratedQuestionOption(text: "Sebuah metode pengajaran", isCorrect: false),
          GeneratedQuestionOption(text: "Sebuah alat ukur", isCorrect: false),
        ];
    }
    
    // Acak urutan opsi jawaban
    options.shuffle(_random);
    
    // Pastikan satu opsi ditandai sebagai benar
    bool hasCorrectOption = options.any((option) => option.isCorrect);
    if (!hasCorrectOption && options.isNotEmpty) {
      // Jika tidak ada opsi yang benar, tandai yang pertama sebagai benar
      options[0] = GeneratedQuestionOption(
        text: options[0].text,
        isCorrect: true,
      );
    }
    
    return GeneratedQuestion(
      questionText: "$number. $questionText",
      type: 'multiple_choice',
      options: options,
    );
  }
  
  GeneratedQuestion _generateEssayQuestion(QuestionAiRequest request, int number) {
    // Menentukan tingkat kesulitan
    String difficulty = request.difficulty ?? 'medium';
    
    // Membuat soal berdasarkan tingkat kesulitan
    String questionText = "";
    String answer = "";
    
    // Memecah materi menjadi kata-kata untuk digunakan dalam soal
    List<String> materialWords = request.material.split(RegExp(r'[^a-zA-Z0-9]'));
    materialWords.removeWhere((element) => element.isEmpty);
    
    String mainTopic = materialWords.isNotEmpty ? materialWords.first : request.material;
    if (materialWords.length > 1) {
      mainTopic = materialWords.take(min(3, materialWords.length)).join(' ');
    }
    
    switch (difficulty) {
      case 'easy':
        List<String> easyQuestions = [
          "Jelaskan secara singkat apa itu '$mainTopic' dalam konteks ${request.subject}.",
          "Apa fungsi dasar dari '$mainTopic' dalam ${request.subject}?",
          "Sebutkan dan jelaskan secara singkat dua ciri utama '$mainTopic'.",
        ];
        
        questionText = easyQuestions[_random.nextInt(easyQuestions.length)];
        answer = "$mainTopic adalah konsep penting dalam ${request.subject} yang menjelaskan tentang prinsip dasar...\n\nFungsi utamanya adalah...\n\nDua ciri utamanya meliputi: 1) ... 2) ...";
        break;
        
      case 'medium':
        List<String> mediumQuestions = [
          "Diskusikan bagaimana '$mainTopic' dapat diterapkan dalam kehidupan sehari-hari di lingkungan sekolah.",
          "Jelaskan hubungan antara '$mainTopic' dengan konsep lain dalam ${request.subject}.",
          "Apa manfaat mempelajari '$mainTopic' bagi siswa ${request.grade}?",
        ];
        
        questionText = mediumQuestions[_random.nextInt(mediumQuestions.length)];
        answer = "Penerapan $mainTopic dalam kehidupan sehari-hari dapat dilihat dari berbagai aspek...\n\nHubungan dengan konsep lain dalam ${request.subject} meliputi...\n\nManfaat bagi siswa ${request.grade} antara lain...";
        break;
        
      case 'hard':
        List<String> hardQuestions = [
          "Evaluasi implikasi jangka panjang dari penggunaan '$mainTopic' dalam pengembangan ${request.subject}.",
          "Analisis kelebihan dan kekurangan dari penerapan '$mainTopic' dalam konteks ${request.subject}.",
          "Bandingkan pendekatan '$mainTopic' dengan metode alternatif dalam menyelesaikan masalah ${request.subject}.",
        ];
        
        questionText = hardQuestions[_random.nextInt(hardQuestions.length)];
        answer = "Implikasi jangka panjang dari penggunaan $mainTopic dalam pengembangan ${request.subject} sangat signifikan...\n\nKelebihan meliputi: 1) ... 2) ...\nKekurangan meliputi: 1) ... 2) ...\n\nDibandingkan dengan metode alternatif, $mainTopic memiliki keunggulan dalam...";
        break;
        
      default:
        List<String> defaultQuestions = [
          "Jelaskan konsep '$mainTopic' dalam ${request.subject}.",
          "Apa pentingnya mempelajari '$mainTopic' dalam ${request.subject}?",
        ];
        
        questionText = defaultQuestions[_random.nextInt(defaultQuestions.length)];
        answer = "$mainTopic dalam konteks ${request.subject} memiliki beberapa aspek penting...";
    }
    
    return GeneratedQuestion(
      questionText: "$number. $questionText",
      type: 'essay',
      answer: answer,
    );
  }
}
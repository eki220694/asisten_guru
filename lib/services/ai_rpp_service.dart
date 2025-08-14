import 'package:asisten_guru/models/rpp_ai_request.dart';

class AiRppService {
  String generateRpp(RppAiRequest request) {
    final objectives = _parseObjectives(request.learningObjectives);
    if (objectives.isEmpty) {
      objectives.add("Siswa mampu memahami konsep dasar tentang ${request.topic}");
    }

    List<String> rppDocuments = [];
    for (int i = 0; i < objectives.length; i++) {
      final rpp = _generateSingleRpp(request, objectives[i], i + 1, objectives.length);
      rppDocuments.add(rpp);
    }
    // Perbaikan: Menggunakan pemisah yang lebih jelas dan rapi
    return rppDocuments.join('<br><hr style="border-top: 2px solid #ccc;"><br>');
  }

    String _generateSingleRpp(RppAiRequest request, String objective, int rppNumber, int totalRpps) {
    final learningModel = _selectLearningModel([objective]);
    final pancasilaProfile = _generatePancasilaProfile(request.subject, [objective], learningModel);
    final digitalUtil = _generateDigitalUtilization(request.topic);
    final learningMaterials = "<p>1. Ruang lingkup ${request.topic}<br>2. Konsep esensial terkait ${request.topic}<br>3. Prinsip dan pendekatan terkait ${request.topic}</p>";
    
    final preliminaryActivities = _buildPreliminaryActivities(objective);
    final coreActivities = _buildCoreActivities(request.topic, learningModel);
    final closingActivities = _buildClosingActivities();
    
    // Perbaikan: Meneruskan rppNumber untuk memastikan aktivitas LKPD bervariasi
    final lkpdContent = _generateDynamicLkpd(request.topic, [objective], rppNumber);
    final signatureBlock = _generateSignatureBlock();

    // Perbaikan Total: Mengganti semua tabel layout dengan tag <p> dan <strong>
    return """
<div>
    <h3>RENCANA PELAKSANAAN PEMBELAJARAN (RPP) ${totalRpps > 1 ? '$rppNumber' : ''}</h3>
    <br>
    <p><strong>Satuan Pendidikan</strong>: (Disesuaikan)</p>
    <p><strong>Nama Guru</strong>: (Disesuaikan)</p>
    <p><strong>Mata Pelajaran/Fase</strong>: ${request.subject} / ${request.grade}</p>
    <p><strong>Semester</strong>: (Disesuaikan)</p>
    <p><strong>Tahun Pelajaran</strong>: (Disesuaikan)</p>

    <h4>A. KOMPONEN INTI</h4>
    <hr>
    <p><strong>Profil Pelajar Pancasila</strong>: $pancasilaProfile</p>
    <p><strong>Tujuan Pembelajaran</strong>: $objective</p>
    <div><strong>Materi Pembelajaran</strong>: $learningMaterials</div>

    <h4>B. PRAKTIK PEDAGOGIS</h4>
    <hr>
    <p><strong>Model</strong>: $learningModel</p>
    <p><strong>Strategi</strong>: Pendekatan Saintifik, Kontekstual</p>
    <p><strong>Metode</strong>: Diskusi Kelompok, Unjuk Kerja, Penugasan</p>
    <p><strong>Pemanfaatan Digital</strong>: $digitalUtil</p>

    <h4>C. LANGKAH-LANGKAH PEMBELAJARAN</h4>
    <hr>
    <p><strong>1. Kegiatan Pendahuluan</strong></p>
    $preliminaryActivities
    <p><strong>2. Kegiatan Inti</strong></p>
    $coreActivities
    <p><strong>3. Kegiatan Penutup</strong></p>
    $closingActivities
    
    <br>
    $signatureBlock
    $lkpdContent
</div>
""";
  }

  List<String> _parseObjectives(String? objectives) {
    if (objectives == null || objectives.trim().isEmpty) return [];
    return objectives.split('\n').where((s) => s.trim().isNotEmpty).map((s) => s.trim().replaceAll(RegExp(r'^[\-*]\s*'), '')).toList();
  }

  String _selectLearningModel(List<String> objectives) {
    final s = objectives.join(' ').toLowerCase();
    if (s.contains('membuat') || s.contains('merancang') || s.contains('menghasilkan')) return 'Project-Based Learning (PjBL)';
    if (s.contains('menganalisis') || s.contains('memecahkan') || s.contains('studi kasus')) return 'Problem-Based Learning (PBL)';
    return 'Discovery Learning';
  }

  String _generatePancasilaProfile(String subject, List<String> objectives, String model) {
    Set<String> p = {'Mandiri'};
    final s = '${objectives.join(' ')} $model'.toLowerCase();
    if (s.contains('analisis') || s.contains('evaluasi') || s.contains('kritis')) p.add('Bernalar Kritis');
    if (s.contains('membuat') || s.contains('merancang') || s.contains('karya')) p.add('Kreatif');
    if (s.contains('kelompok') || s.contains('kolaborasi') || s.contains('project')) p.add('Gotong Royong');
    if (subject.toLowerCase().contains('sejarah') || subject.toLowerCase().contains('sosiologi')) p.add('Berkebinekaan Global');
    return p.join(', ');
  }

  String _generateDigitalUtilization(String topic) => "Video Pembelajaran dari YouTube terkait '$topic'.";

  String _buildPreliminaryActivities(String objective) {
    return '''
<ol>
    <li>Guru membuka pembelajaran dengan salam dan doa.</li>
    <li>Guru dan Murid merefleksikan kesepakatan kelas.</li>
    <li>Guru melakukan ice breaking singkat untuk meningkatkan fokus.</li>
    <li>Guru mengajukan pertanyaan pemantik yang relevan dengan tujuan.</li>
    <li>Guru melakukan asesmen awal singkat untuk mengetahui pemahaman dasar murid.</li>
    <li>Guru menyampaikan secara jelas tujuan pembelajaran: "<strong>$objective</strong>".</li>
</ol>
''';
  }

  String _buildCoreActivities(String topic, String model) {
    if (model.contains('Project-Based')) return _buildPjBLCore(topic);
    if (model.contains('Problem-Based')) return _buildPBLCore(topic);
    return _buildDiscoveryCore(topic);
  }

  String _buildPjBLCore(String topic) {
    return '''
<p><strong>Fase 1: Penentuan Pertanyaan Mendasar (Start With the Essential Question)</strong></p>
<ol>
    <li>Guru mengajukan pertanyaan esensial yang bersifat menantang dan terbuka terkait <strong>$topic</strong>. Contoh: "Bagaimana kita bisa merancang solusi inovatif untuk [masalah terkait topik] di lingkungan sekolah?"
    <li>Murid, dengan bimbingan, mengidentifikasi masalah dan merumuskan pertanyaan proyek yang akan diselesaikan secara kelompok.</li>
</ol>
<p><strong>Fase 2: Mendesain Perencanaan Proyek (Design a Plan for the Project)</strong></p>
<ol>
    <li>Secara kolaboratif, kelompok menyusun rencana proyek yang mencakup tujuan, linimasa (timeline), dan alokasi tugas.</li>
    <li>Murid menentukan sumber daya yang dibutuhkan dan kriteria penilaian untuk produk akhir proyek mereka.</li>
</ol>
<p><strong>Fase 3: Menyusun Jadwal (Create a Schedule)</strong></p>
<ol>
    <li>Guru dan murid menyepakati jadwal aktivitas, termasuk tenggat waktu untuk setiap tahapan proyek.</li>
    <li>Jadwal ini dipajang di kelas sebagai pengingat dan alat monitor kemajuan.</li>
</ol>
<p><strong>Fase 4: Memonitor Murid dan Kemajuan Proyek (Monitor the Students and the Progress of the Project)</strong></p>
<ol>
    <li>Guru berperan sebagai fasilitator, memantau aktivitas kelompok, dan memberikan umpan balik secara berkala.</li>
    <li>Murid melakukan pencatatan (log) kemajuan proyek dan mendokumentasikan setiap proses kerja mereka.</li>
</ol>
<p><strong>Fase 5: Menguji Hasil (Assess the Outcome)</strong></p>
<ol>
    <li>Murid mempresentasikan hasil proyek mereka dalam bentuk produk, laporan, atau presentasi.</li>
    <li>Guru melakukan asesmen formatif dan sumatif yang mengacu pada kriteria penilaian yang telah disepakati. Penilaian dapat melibatkan umpan balik dari rekan sejawat (peer feedback).</li>
</ol>
<p><strong>Fase 6: Mengevaluasi Pengalaman (Evaluate the Experience)</strong></p>
<ol>
    <li>Di akhir proyek, murid dan guru melakukan refleksi bersama mengenai tantangan, pembelajaran, dan pengalaman selama mengerjakan proyek.</li>
    <li>Murid diajak untuk mengidentifikasi apa yang berhasil dan apa yang bisa diperbaiki di proyek selanjutnya.</li>
</ol>
''';
  }

  String _buildPBLCore(String topic) {
    return '''
<p><strong>Fase 1: Orientasi Murid pada Masalah (Student Orientation to the Problem)</strong></p>
<ol>
    <li>Guru menyajikan masalah autentik dan relevan terkait <strong>$topic</strong> yang tidak memiliki jawaban tunggal.</li>
    <li>Murid melakukan identifikasi awal: apa yang mereka ketahui (prior knowledge), apa yang perlu mereka cari tahu, dan ide-ide awal untuk solusi.</li>
</ol>
<p><strong>Fase 2: Mengorganisasi Murid untuk Belajar (Organize Students for Study)</strong></p>
<ol>
    <li>Guru membantu murid mendefinisikan tugas belajar dan membentuk kelompok investigasi yang heterogen.</li>
    <li>Kelompok merumuskan pertanyaan-pertanyaan spesifik yang akan memandu penyelidikan mereka untuk memecahkan masalah.</li>
</ol>
<p><strong>Fase 3: Membimbing Penyelidikan Individual maupun Kelompok (Assist Independent and Group Investigation)</strong></p>
<ol>
    <li>Murid secara aktif mencari informasi dari berbagai sumber (buku, internet, wawancara) untuk menjawab pertanyaan investigasi.</li>
    <li>Guru bertindak sebagai pembimbing, mengajukan pertanyaan yang mendorong pemikiran kritis, dan memastikan semua anggota berkontribusi.</li>
</ol>
<p><strong>Fase 4: Mengembangkan dan Menyajikan Hasil Karya (Develop and Present Artifacts and Exhibits)</strong></p>
<ol>
    <li>Kelompok mensintesis informasi yang telah dikumpulkan dan merumuskan solusi untuk masalah yang disajikan.</li>
    <li>Hasil kerja disajikan kepada seluruh kelas dalam berbagai format (laporan, presentasi, model) untuk mendapatkan masukan.</li>
</ol>
<p><strong>Fase 5: Menganalisis dan Mengevaluasi Proses Pemecahan Masalah (Analyze and Evaluate the Problem-Solving Process)</strong></p>
<ol>
    <li>Setelah presentasi, guru memfasilitasi diskusi kelas untuk menganalisis setiap solusi yang diusulkan.</li>
    <li>Murid bersama guru melakukan refleksi terhadap efektivitas proses pemecahan masalah, baik secara individu maupun kelompok.</li>
</ol>
''';
  }

  String _buildDiscoveryCore(String topic) {
    return '''
<p><strong>Fase 1: Pemberian Rangsangan (Stimulation)</strong></p>
<ol>
    <li>Guru menyajikan fenomena, gambar, atau video yang kontradiktif atau menarik terkait <strong>$topic</strong> untuk membangkitkan rasa ingin tahu.</li>
    <li>Murid didorong untuk mengamati dan memberikan tanggapan awal tanpa arahan spesifik dari guru.</li>
</ol>
<p><strong>Fase 2: Identifikasi Masalah (Problem Statement)</strong></p>
<ol>
    <li>Dari hasil stimulasi, guru membimbing murid untuk merumuskan pertanyaan-pertanyaan atau masalah yang relevan.</li>
    <li>Murid memilih satu pertanyaan kunci atau hipotesis yang akan menjadi fokus investigasi mereka.</li>
</ol>
<p><strong>Fase 3: Pengumpulan Data (Data Collection)</strong></p>
<ol>
    <li>Murid secara aktif mencari informasi, melakukan percobaan sederhana, atau observasi untuk mengumpulkan data yang relevan dengan hipotesis.</li>
    <li>Guru menyediakan sumber belajar dan memastikan murid memahami cara mengumpulkan data yang valid.</li>
</ol>
<p><strong>Fase 4: Pengolahan Data (Data Processing)</strong></p>
<ol>
    <li>Murid mengolah dan menganalisis data yang telah dikumpulkan. Mereka mencari pola, hubungan, atau anomali.</li>
    <li>Data dapat disajikan dalam bentuk tabel, grafik, atau ringkasan untuk mempermudah interpretasi.</li>
</ol>
<p><strong>Fase 5: Pembuktian (Verification)</strong></p>
<ol>
    <li>Murid membandingkan hasil olahan data mereka dengan hipotesis awal. Apakah data mendukung atau menolak hipotesis?</li>
    <li>Mereka merumuskan kesimpulan berdasarkan bukti yang telah ditemukan.</li>
</ol>
<p><strong>Fase 6: Menarik Kesimpulan/Generalisasi (Generalization)</strong></p>
<ol>
    <li>Berdasarkan pembuktian, murid menarik kesimpulan atau generalisasi mengenai konsep <strong>$topic</strong> yang dipelajari.</li>
    <li>Guru membantu murid untuk mengartikulasikan temuan mereka dan menghubungkannya dengan konsep yang lebih luas.</li>
</ol>
''';
  }

  String _buildClosingActivities() {
    return '''
<ol>
    <li>Guru memberikan apresiasi kepada individu/kelompok yang menunjukkan kinerja terbaik.</li>
    <li>Guru bersama murid menyimpulkan materi ajar yang telah dipelajari.</li>
    <li>Guru meminta murid menyampaikan refleksi pembelajaran.</li>
    <li>Guru menyampaikan rencana kegiatan pada pembelajaran berikutnya.</li>
    <li>Guru menutup kegiatan pembelajaran dengan doa dan salam.</li>
</ol>
''';
  }

  String _generateDynamicLkpd(String topic, List<String> objectives, int rppNumber) {
    String lkpdActivities = "";
    for (var obj in objectives) {
      lkpdActivities += "<h4>Aktivitas untuk Tujuan: $obj</h4>${_getActivityModelForObjective(obj, topic, rppNumber)}";
    }
    return '<h3>LAMPIRAN: Lembar Kerja Peserta Didik (LKPD)</h3><hr>$lkpdActivities';
  }

  String _getActivityModelForObjective(String objective, String topic, int rppNumber) {
    objective = objective.toLowerCase();
    
    // Kategori Analisis
    if (objective.contains('menganalisis') || objective.contains('membandingkan') || objective.contains('mengevaluasi')) {
      final activities = [
        '''
<p><strong>Model Aktivitas: Analisis Studi Kasus</strong></p>
<p><strong>Petunjuk:</strong> Bacalah skenario singkat di bawah ini, lalu jawablah pertanyaan-pertanyaan berikut.</p>
<p><strong>Skenario:</strong> (Guru dapat menyediakan studi kasus singkat yang relevan dengan $topic)</p>
<p><em>...</em></p>
<p><strong>Pertanyaan Analisis:</strong></p>
<ol>
    <li>Apa masalah utama yang terjadi dalam skenario di atas?</li>
    <li>Bagaimana konsep <strong>$topic</strong> dapat diterapkan untuk memahami atau menyelesaikan masalah tersebut?</li>
</ol>
''',
        '''
<p><strong>Model Aktivitas: Debat Kritis</strong></p>
<p><strong>Petunjuk:</strong> Bentuklah dua kelompok (pro dan kontra) untuk mendebatkan mosi di bawah ini.</p>
<p><strong>Mosi Debat:</strong> "Penerapan [aspek kunci dari $topic] lebih banyak memberikan dampak positif daripada negatif."</p>
<p><strong>Tugas:</strong></p>
<ol>
    <li>Setiap kelompok menyusun 3-5 argumen utama untuk mendukung posisinya.</li>
    <li>Sajikan argumen secara bergantian dan berikan sanggahan terhadap argumen lawan.</li>
</ol>
''',
        '''
<p><strong>Model Aktivitas: Analisis SWOT</strong></p>
<p><strong>Petunjuk:</strong> Lakukan analisis SWOT (Strengths, Weaknesses, Opportunities, Threats) terhadap penerapan konsep <strong>$topic</strong>.</p>
<p><strong>Tugas:</strong></p>
<ol>
    <li>Identifikasi minimal 2 poin untuk setiap komponen SWOT.</li>
    <li>Jelaskan bagaimana Opportunities dapat mengatasi Weaknesses.</li>
</ol>
'''
      ];
      return activities[(rppNumber - 1) % activities.length];
    } 
    // Kategori Kreasi
    else if (objective.contains('membuat') || objective.contains('merancang') || objective.contains('mengembangkan')) {
      final activities = [
        '''
<p><strong>Model Aktivitas: Peta Konsep Kreatif</strong></p>
<p><strong>Petunjuk:</strong> Buatlah sebuah peta konsep (mind map) yang komprehensif tentang <strong>$topic</strong>.</p>
<p><strong>Kriteria Peta Konsep:</strong></p>
<ul>
    <li>Tujuan <strong>"$objective"</strong> menjadi pusat atau hasil akhir dari peta konsep.</li>
    <li>Cabang utama harus mencakup: Definisi Kunci, Komponen Penting, dan Contoh Nyata.</li>
</ul>
''',
        '''
<p><strong>Model Aktivitas: Desain Proyek Mini</strong></p>
<p><strong>Petunjuk:</strong> Rancanglah sebuah proyek sederhana yang menerapkan prinsip-prinsip dari <strong>$topic</strong>.</p>
<p><strong>Kerangka Rancangan:</strong></p>
<ol>
    <li><strong>Judul Proyek:</strong> Judul yang menarik dan relevan.</li>
    <li><strong>Tujuan Proyek:</strong> Apa yang ingin dicapai melalui proyek ini?</li>
    <li><strong>Langkah-langkah:</strong> Uraikan 3-5 langkah utama untuk menyelesaikan proyek.</li>
</ol>
''',
        '''
<p><strong>Model Aktivitas: Penulisan Infografis</strong></p>
<p><strong>Petunjuk:</strong> Buatlah draf konten untuk sebuah infografis yang menjelaskan <strong>$topic</strong> secara visual.</p>
<p><strong>Konten Infografis:</strong></p>
<ul>
    <li><strong>Judul Utama:</strong> Menarik dan informatif.</li>
    <li><strong>Poin Kunci:</strong> 3-4 poin paling penting tentang $topic, masing-masing dengan ikon visual sederhana.</li>
    <li><strong>Data/Fakta Menarik:</strong> Sertakan satu data atau fakta mengejutkan.</li>
</ul>
'''
      ];
      return activities[(rppNumber - 1) % activities.length];
    } 
    // Kategori Dasar/Pemahaman
    else {
      final activities = [
        '''
<p><strong>Model Aktivitas: Pertanyaan Terbuka</strong></p>
<p><strong>Petunjuk:</strong> Jawablah pertanyaan berikut dengan jelas dan ringkas.</p>
<ol>
    <li>Apa definisi dari <strong>$topic</strong> menurut pemahaman Anda?</li>
    <li>Berikan satu contoh nyata dari <strong>$topic</strong> dalam kehidupan sehari-hari.</li>
</ol>
''',
        '''
<p><strong>Model Aktivitas: Identifikasi Konsep</strong></p>
<p><strong>Petunjuk:</strong> Dari daftar istilah di bawah ini, lingkari 3 istilah yang paling relevan dengan <strong>$topic</strong> dan jelaskan alasannya.</p>
<p><em>(Guru menyediakan 5-7 istilah yang relevan dan tidak relevan)</em></p>
<p><strong>Alasan Pemilihan:</strong></p>
<ol>
    <li>Istilah 1: ...</li>
    <li>Istilah 2: ...</li>
    <li>Istilah 3: ...</li>
</ol>
''',
        '''
<p><strong>Model Aktivitas: Refleksi Singkat</strong></p>
<p><strong>Petunjuk:</strong> Tuliskan satu hal baru yang Anda pelajari tentang <strong>$topic</strong> dan satu pertanyaan yang masih Anda miliki.</p>
<p><strong>Hal Baru yang Dipelajari:</strong></p>
<p><em>...</em></p>
<p><strong>Pertanyaan Lanjutan:</strong></p>
<p><em>...</em></p>
'''
      ];
      return activities[(rppNumber - 1) % activities.length];
    }
  }

  String _generateSignatureBlock() {
    // Mengembalikan layout tabel untuk tanda tangan agar bersebelahan
    // sesuai permintaan, dan menambahkan placeholder tanggal.
    return '''
<br><br>
<table style="width: 100%; border-collapse: collapse;">
    <tr>
        <td style="width: 50%; text-align: center; vertical-align: top;">
            <p>Mengetahui,</p>
            <p>Kepala Sekolah</p>
            <br><br><br><br>
            <p><strong>(Nama Kepala Sekolah)</strong></p>
            <p>NIP. .........................................</p>
        </td>
        <td style="width: 50%; text-align: center; vertical-align: top;">
            <p>.................., .................................</p>
            <p>Guru Mata Pelajaran</p>
            <br><br><br><br>
            <p><strong>(Nama Guru)</strong></p>
            <p>NIP. .........................................</p>
        </td>
    </tr>
</table>
''';
  }

  
}

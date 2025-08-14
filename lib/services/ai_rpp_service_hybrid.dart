import 'package:asisten_guru/models/rpp_ai_request.dart';

class AiRppService {
  // Template dengan kerangka struktur tetap
  static const String rppTemplate = '''
<div class=\"rpp-container\">
  <div class=\"rpp-header\">
    <h1>RENCANA PELAKSANAAN PEMBELAJARAN (RPP)</h1>
  </div>
  
  <div class=\"rpp-identity\">
    <div class=\"identity-item\">
      <strong>Satuan Pendidikan</strong>: [DIISI GURU]
    </div>
    <div class=\"identity-item\">
      <strong>Kelas/Semester</strong>: {grade}
    </div>
    <div class=\"identity-item\">
      <strong>Mata Pelajaran</strong>: {subject}
    </div>
    <div class=\"identity-item\">
      <strong>Materi Pokok</strong>: {topic}
    </div>
    <div class=\"identity-item\">
      <strong>Alokasi Waktu</strong>: {duration}
    </div>
    <div class=\"identity-item\">
      <strong>Tahun Pelajaran</strong>: [DIISI GURU]
    </div>
  </div>

  <div class=\"rpp-section\">
    <h2>A. Kompetensi Inti</h2>
    <div class=\"ai-generated\">{coreCompetencies}</div>
  </div>

  <div class=\"rpp-section\">
    <h2>B. Kompetensi Dasar</h2>
    <div class=\"ai-generated\">{basicCompetencies}</div>
  </div>

  <div class=\"rpp-section\">
    <h2>C. Indikator Pencapaian Kompetensi</h2>
    <div class=\"ai-generated\">{indicators}</div>
  </div>

  <div class=\"rpp-section\">
    <h2>D. Tujuan Pembelajaran</h2>
    <div class=\"ai-generated\">{learningObjectives}</div>
  </div>

  <div class=\"rpp-section\">
    <h2>E. Materi Pembelajaran</h2>
    <div class=\"ai-generated\">{learningMaterials}</div>
  </div>

  <div class=\"rpp-section\">
    <h2>F. Pendekatan, Model, dan Metode</h2>
    <div class=\"subsection\">
      <strong>Pendekatan</strong>: <span class=\"ai-generated\">{approach}</span>
    </div>
    <div class=\"subsection\">
      <strong>Model Pembelajaran</strong>: <span class=\"ai-generated\">{learningModel}</span>
    </div>
    <div class=\"subsection\">
      <strong>Metode</strong>: <span class=\"ai-generated\">{methods}</span>
    </div>
  </div>

  <div class=\"rpp-section\">
    <h2>G. Kegiatan Pembelajaran</h2>
    
    <div class=\"activity-section\">
      <h3>1. Kegiatan Pendahuluan</h3>
      <div class=\"ai-generated\">{preliminaryActivities}</div>
    </div>
    
    <div class=\"activity-section\">
      <h3>2. Kegiatan Inti</h3>
      <div class=\"ai-generated\">{coreActivities}</div>
    </div>
    
    <div class=\"activity-section\">
      <h3>3. Kegiatan Penutup</h3>
      <div class=\"ai-generated\">{closingActivities}</div>
    </div>
  </div>

  <div class=\"rpp-section\">
    <h2>H. Penilaian</h2>
    <div class=\"subsection\">
      <strong>Teknik Penilaian</strong>: <span class=\"ai-generated\">{assessmentTechniques}</span>
    </div>
    <div class=\"subsection\">
      <strong>Bentuk Instrumen</strong>: <span class=\"ai-generated\">{assessmentForms}</span>
    </div>
    <div class=\"subsection\">
      <strong>Instrumen Penilaian</strong>: <span class=\"ai-generated\">{assessmentInstruments}</span>
    </div>
  </div>

  <div class=\"rpp-section\">
    <h2>I. Media, Alat, dan Sumber Belajar</h2>
    <div class=\"subsection\">
      <strong>Media Pembelajaran</strong>: <span class=\"ai-generated\">{learningMedia}</span>
    </div>
    <div class=\"subsection\">
      <strong>Alat dan Bahan</strong>: <span class=\"ai-generated\">{toolsAndMaterials}</span>
    </div>
    <div class=\"subsection\">
      <strong>Sumber Belajar</strong>: <span class=\"ai-generated\">{learningSources}</span>
    </div>
  </div>

  <div class=\"rpp-section\">
    <h2>J. Profil Pelajar Pancasila</h2>
    <div class=\"ai-generated\">{pancasilaProfiles}</div>
  </div>

  <div class=\"signature-section\">
    <div class=\"signature-item\">
      <p>Mengetahui,<br>Kepala Sekolah</p>
      <br><br><br>
      <p>_____________________<br>NIP.</p>
    </div>
    <div class=\"signature-item\">
      <p>_____________________<br>Guru Mata Pelajaran</p>
      <br><br><br>
      <p>_____________________<br>NIP.</p>
    </div>
  </div>
</div>
''';

  String generateRpp(RppAiRequest request) {
    // Gunakan template dengan kerangka tetap
    String rpp = rppTemplate;
    
    // Isi bagian identitas yang statis
    rpp = rpp.replaceAll('{subject}', request.subject);
    rpp = rpp.replaceAll('{grade}', request.grade);
    rpp = rpp.replaceAll('{topic}', request.topic);
    rpp = rpp.replaceAll('{duration}', request.duration ?? '2 x 45 menit');
    
    // Gunakan AI untuk mengisi konten dinamis
    rpp = rpp.replaceAll('{coreCompetencies}', _generateCoreCompetencies(request));
    rpp = rpp.replaceAll('{basicCompetencies}', _generateBasicCompetencies(request));
    rpp = rpp.replaceAll('{indicators}', _generateIndicators(request));
    rpp = rpp.replaceAll('{learningObjectives}', _generateLearningObjectives(request));
    rpp = rpp.replaceAll('{learningMaterials}', _generateLearningMaterials(request));
    rpp = rpp.replaceAll('{approach}', _generateApproach(request));
    rpp = rpp.replaceAll('{learningModel}', _generateLearningModel(request));
    rpp = rpp.replaceAll('{methods}', _generateMethods(request));
    rpp = rpp.replaceAll('{preliminaryActivities}', _generatePreliminaryActivities(request));
    rpp = rpp.replaceAll('{coreActivities}', _generateCoreActivities(request));
    rpp = rpp.replaceAll('{closingActivities}', _generateClosingActivities(request));
    rpp = rpp.replaceAll('{assessmentTechniques}', _generateAssessmentTechniques(request));
    rpp = rpp.replaceAll('{assessmentForms}', _generateAssessmentForms(request));
    rpp = rpp.replaceAll('{assessmentInstruments}', _generateAssessmentInstruments(request));
    rpp = rpp.replaceAll('{learningMedia}', _generateLearningMedia(request));
    rpp = rpp.replaceAll('{toolsAndMaterials}', _generateToolsAndMaterials(request));
    rpp = rpp.replaceAll('{learningSources}', _generateLearningSources(request));
    rpp = rpp.replaceAll('{pancasilaProfiles}', _generatePancasilaProfiles(request));
    
    return rpp;
  }
  
  // Method-method untuk menghasilkan konten dengan AI (simulasi)
  String _generateCoreCompetencies(RppAiRequest request) {
    // Dalam implementasi nyata, ini akan memanggil API AI
    return '''
    <p>1. Menghayati dan mengamalkan ajaran agama yang dianutnya.</p>
    <p>2. Menghayati dan mengamalkan perilaku jujur, disiplin, tanggung jawab, peduli (gotong royong, kerjasama, toleran, damai), santun, responsif dan proaktif serta menunjukkan sikap sebagai bagian dari solusi atas berbagai permasalahan dalam berinteraksi secara efektif dengan lingkungan sosial dan alam serta dalam menempatkan diri sebagai cerminan bangsa dalam pergaulan dunia.</p>
    <p>3. Memahami, menerapkan, menganalisis pengetahuan faktual, konseptual, prosedural berdasarkan rasa ingin tahunya tentang ilmu pengetahuan, teknologi, seni, budaya, dan humaniora dengan wawasan kemanusiaan, kebangsaan, kenegaraan, dan peradaban terkait penyebab fenomena dan kejadian, serta menerapkan pengetahuan prosedural pada bidang kajian yang spesifik sesuai dengan bakat dan minatnya untuk memecahkan masalah.</p>
    <p>4. Mengolah, menalar, dan menyaji dalam ranah konkret dan ranah abstrak terkait dengan pengembangan dari yang dipelajarinya di sekolah secara mandiri, dan mampu menggunakan metoda sesuai kaidah keilmuan.</p>
    ''';
  }
  
  String _generateBasicCompetencies(RppAiRequest request) {
    // Simulasi output AI berdasarkan topik
    if (request.topic.toLowerCase().contains('ekosistem')) {
      return '''
      <p>3.1 Menganalisis komponen ekosistem dan interaksinya dalam suatu lingkungan.</p>
      <p>4.1 Menyajikan hasil analisis tentang perubahan ekosistem akibat aktivitas manusia.</p>
      ''';
    } else if (request.topic.toLowerCase().contains('reaksi kimia')) {
      return '''
      <p>3.6 Menganalisis reaksi kimia dalam kehidupan sehari-hari.</p>
      <p>4.6 Merancang percobaan untuk menyelidiki faktor-faktor yang mempengaruhi laju reaksi.</p>
      ''';
    } else {
      return '''
      <p>3.X Menganalisis konsep {topic} dalam konteks kehidupan sehari-hari.</p>
      <p>4.X Menerapkan prinsip {topic} untuk memecahkan masalah.</p>
      '''.replaceAll('{topic}', request.topic);
    }
  }
  
  String _generateIndicators(RppAiRequest request) {
    // Simulasi output AI berdasarkan kompetensi dasar
    if (request.topic.toLowerCase().contains('ekosistem')) {
      return '''
      <p>1. Mengidentifikasi komponen biotik dan abiotik dalam ekosistem.</p>
      <p>2. Menjelaskan hubungan antara produsen, konsumen, dan pengurai.</p>
      <p>3. Menganalisis dampak aktivitas manusia terhadap keseimbangan ekosistem.</p>
      ''';
    } else {
      return '''
      <p>1. Mengidentifikasi konsep dasar {topic}.</p>
      <p>2. Menjelaskan prinsip-prinsip {topic}.</p>
      <p>3. Menganalisis penerapan {topic} dalam kehidupan sehari-hari.</p>
      '''.replaceAll('{topic}', request.topic);
    }
  }
  
  String _generateLearningObjectives(RppAiRequest request) {
    // Gunakan tujuan pembelajaran dari request jika tersedia
    if (request.learningObjectives.isNotEmpty) {
      return '<p>${request.learningObjectives.replaceAll('\n', '</p><p>')}</p>';
    }
    
    // Jika tidak, hasilkan dengan AI
    return '''
    <p>Siswa dapat mengidentifikasi komponen utama dari {topic}.</p>
    <p>Siswa dapat menjelaskan prinsip dasar {topic} dengan benar.</p>
    <p>Siswa dapat menganalisis penerapan {topic} dalam situasi nyata.</p>
    '''.replaceAll('{topic}', request.topic);
  }
  
  String _generateLearningMaterials(RppAiRequest request) {
    return '''
    <p>1. Pengertian dan konsep dasar {topic}</p>
    <p>2. Prinsip-prinsip {topic}</p>
    <p>3. Penerapan {topic} dalam kehidupan sehari-hari</p>
    <p>4. Studi kasus terkait {topic}</p>
    '''.replaceAll('{topic}', request.topic);
  }
  
  String _generateApproach(RppAiRequest request) {
    return 'Pendekatan Saintifik dan Pendekatan Kontekstual';
  }
  
  String _generateLearningModel(RppAiRequest request) {
    // Pilih model berdasarkan tujuan pembelajaran
    if (request.learningObjectives.toLowerCase().contains('membuat') || 
        request.learningObjectives.toLowerCase().contains('merancang')) {
      return 'Project Based Learning (PjBL)';
    } else if (request.learningObjectives.toLowerCase().contains('menganalisis') || 
               request.learningObjectives.toLowerCase().contains('memecahkan')) {
      return 'Problem Based Learning (PBL)';
    } else {
      return 'Discovery Learning';
    }
  }
  
  String _generateMethods(RppAiRequest request) {
    return 'Diskusi Kelompok, Presentasi, Tanya Jawab, Demonstrasi, Penugasan';
  }
  
  String _generatePreliminaryActivities(RppAiRequest request) {
    return '''
    <ol>
      <li>Guru memberikan salam dan mengecek kehadiran peserta didik.</li>
      <li>Guru mengkondisikan suasana kelas agar siap menerima pelajaran.</li>
      <li>Guru mereview materi pelajaran sebelumnya yang berkaitan dengan {topic}.</li>
      <li>Guru menyampaikan tujuan pembelajaran yang akan dicapai hari ini.</li>
      <li>Guru menyampaikan garis besar kegiatan pembelajaran hari ini.</li>
      <li>Guru memberikan motivasi kepada peserta didik.</li>
    </ol>
    '''.replaceAll('{topic}', request.topic);
  }
  
  String _generateCoreActivities(RppAiRequest request) {
    String model = _generateLearningModel(request);
    
    if (model.contains('Project Based')) {
      return '''
      <p><strong>Fase 1: Orientasi terhadap Masalah</strong></p>
      <ol>
        <li>Guru menyajikan masalah autentik terkait {topic}.</li>
        <li>Peserta didik mengidentifikasi masalah yang akan diselesaikan.</li>
      </ol>
      
      <p><strong>Fase 2: Mengorganisir Peserta Didik</strong></p>
      <ol>
        <li>Guru membentuk kelompok heterogen.</li>
        <li>Kelompok merumuskan rencana penyelesaian masalah.</li>
      </ol>
      
      <p><strong>Fase 3: Membimbing Penyelidikan</strong></p>
      <ol>
        <li>Peserta didik mengumpulkan informasi dari berbagai sumber.</li>
        <li>Guru membimbing peserta didik selama proses investigasi.</li>
      </ol>
      
      <p><strong>Fase 4: Mengembangkan dan Menyajikan Karya</strong></p>
      <ol>
        <li>Kelompok menyusun laporan hasil penyelesaian masalah.</li>
        <li>Peserta didik mempresentasikan hasil karyanya.</li>
      </ol>
      
      <p><strong>Fase 5: Menganalisis dan Mengevaluasi Proses Pemecahan Masalah</strong></p>
      <ol>
        <li>Guru dan peserta didik melakukan refleksi terhadap proses pembelajaran.</li>
        <li>Guru memberikan umpan balik terhadap hasil karya peserta didik.</li>
      </ol>
      '''.replaceAll('{topic}', request.topic);
    } else if (model.contains('Problem Based')) {
      return '''
      <p><strong>Fase 1: Orientasi Peserta Didik pada Masalah</strong></p>
      <ol>
        <li>Guru menyajikan masalah kompleks terkait {topic}.</li>
        <li>Peserta didik mengidentifikasi elemen-elemen penting dari masalah.</li>
      </ol>
      
      <p><strong>Fase 2: Mengorganisir Peserta Didik untuk Belajar</strong></p>
      <ol>
        <li>Guru membimbing peserta didik mendefinisikan tugas belajar.</li>
        <li>Peserta didik membentuk kelompok investigasi.</li>
      </ol>
      
      <p><strong>Fase 3: Membimbing Penyelidikan Individual dan Kelompok</strong></p>
      <ol>
        <li>Peserta didik mencari informasi dari berbagai sumber.</li>
        <li>Guru membimbing proses investigasi peserta didik.</li>
      </ol>
      
      <p><strong>Fase 4: Mengembangkan dan Menyajikan Hasil Karya</strong></p>
      <ol>
        <li>Peserta didik mensintesis informasi yang telah diperoleh.</li>
        <li>Kelompok menyajikan hasil karya kepada kelompok lain.</li>
      </ol>
      
      <p><strong>Fase 5: Menganalisis dan Mengevaluasi Proses Pemecahan Masalah</strong></p>
      <ol>
        <li>Guru memfasilitasi diskusi untuk menganalisis solusi yang diusulkan.</li>
        <li>Peserta didik dan guru melakukan refleksi terhadap proses pemecahan masalah.</li>
      </ol>
      '''.replaceAll('{topic}', request.topic);
    } else {
      return '''
      <p><strong>Fase 1: Stimulasi</strong></p>
      <ol>
        <li>Guru menunjukkan fenomena atau kasus yang berkaitan dengan {topic}.</li>
        <li>Peserta didik mengamati dan mencatat hal-hal yang menarik perhatian.</li>
      </ol>
      
      <p><strong>Fase 2: Identifikasi Masalah</strong></p>
      <ol>
        <li>Peserta didik merumuskan pertanyaan berdasarkan pengamatan.</li>
        <li>Guru membantu peserta didik merumuskan masalah yang akan diselidiki.</li>
      </ol>
      
      <p><strong>Fase 3: Pengumpulan Data</strong></p>
      <ol>
        <li>Peserta didik mengumpulkan informasi dari berbagai sumber.</li>
        <li>Guru membimbing peserta didik dalam teknik pengumpulan data.</li>
      </ol>
      
      <p><strong>Fase 4: Pengolahan Data</strong></p>
      <ol>
        <li>Peserta didik mengolah data yang telah dikumpulkan.</li>
        <li>Guru membantu peserta didik dalam teknik pengolahan data.</li>
      </ol>
      
      <p><strong>Fase 5: Verifikasi</strong></p>
      <ol>
        <li>Peserta didik memverifikasi hasil pengolahan data.</li>
        <li>Guru membimbing peserta didik dalam proses verifikasi.</li>
      </ol>
      
      <p><strong>Fase 6: Generalisasi</strong></p>
      <ol>
        <li>Peserta didik menarik kesimpulan dari hasil verifikasi.</li>
        <li>Guru membantu peserta didik dalam proses generalisasi.</li>
      </ol>
      '''.replaceAll('{topic}', request.topic);
    }
  }
  
  String _generateClosingActivities(RppAiRequest request) {
    return '''
    <ol>
      <li>Guru bersama peserta didik menyimpulkan materi pembelajaran hari ini.</li>
      <li>Peserta didik melakukan refleksi terhadap proses pembelajaran.</li>
      <li>Guru memberikan umpan balik terhadap kegiatan pembelajaran.</li>
      <li>Guru merencanakan kegiatan pembelajaran berikutnya.</li>
      <li>Guru mengakhiri pembelajaran dengan salam.</li>
    </ol>
    ''';
  }
  
  String _generateAssessmentTechniques(RppAiRequest request) {
    return 'Tes tertulis, observasi, dan penilaian kinerja';
  }
  
  String _generateAssessmentForms(RppAiRequest request) {
    return 'Soal uraian, lembar observasi, dan rubrik penilaian kinerja';
  }
  
  String _generateAssessmentInstruments(RppAiRequest request) {
    return '''
    <p><strong>Contoh Soal:</strong></p>
    <p>Jelaskan konsep {topic} dan berikan contoh penerapannya dalam kehidupan sehari-hari!</p>
    '''.replaceAll('{topic}', request.topic);
  }
  
  String _generateLearningMedia(RppAiRequest request) {
    return 'Laptop, LCD proyektor, video pembelajaran, dan modul';
  }
  
  String _generateToolsAndMaterials(RppAiRequest request) {
    return 'Whiteboard, spidol, laptop, dan akses internet';
  }
  
  String _generateLearningSources(RppAiRequest request) {
    return '''
    <p>1. Buku Siswa {subject} Kelas {grade}</p>
    <p>2. Buku Guru {subject} Kelas {grade}</p>
    <p>3. Artikel dan jurnal terkait {topic}</p>
    <p>4. Video pembelajaran dari YouTube</p>
    '''.replaceAll('{subject}', request.subject)
      .replaceAll('{grade}', request.grade)
      .replaceAll('{topic}', request.topic);
  }
  
  String _generatePancasilaProfiles(RppAiRequest request) {
    return '''
    <p><strong>Beriman, Bertakwa kepada Tuhan Yang Maha Esa, dan Berbudi Pekerti Luhur:</strong> 
    Peserta didik menunjukkan sikap tanggung jawab dalam menjalankan ajaran agamanya.</p>
    
    <p><strong>Mandiri:</strong> 
    Peserta didik menunjukkan sikap mandiri dalam menyelesaikan tugas kelompok.</p>
    
    <p><strong>Bernalar Kritis:</strong> 
    Peserta didik mampu menganalisis informasi dan membuat keputusan berdasarkan data.</p>
    
    <p><strong>Kreatif:</strong> 
    Peserta didik menunjukkan kreativitas dalam menyajikan hasil karya kelompok.</p>
    
    <p><strong>Gotong Royong:</strong> 
    Peserta didik menunjukkan sikap kerjasama dalam kegiatan kelompok.</p>
    ''';
  }
}
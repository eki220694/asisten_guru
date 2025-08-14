import 'dart:io';
import 'package:asisten_guru/models/rpp.dart';
import 'package:asisten_guru/models/rpp_ai_request.dart';
import 'package:asisten_guru/services/ai_rpp_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';

class RppAiResultScreen extends StatefulWidget {
  final RppAiRequest request;

  const RppAiResultScreen({Key? key, required this.request}) : super(key: key);

  @override
  _RppAiResultScreenState createState() => _RppAiResultScreenState();
}

class _RppAiResultScreenState extends State<RppAiResultScreen> {
  final AiRppService _aiRppService = AiRppService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late final String _rppContent;

  @override
  void initState() {
    super.initState();
    _rppContent = _aiRppService.generateRpp(widget.request);
  }

  Future<void> _saveRpp() async {
    final subjects = await _dbHelper.getSubjects();
    int? selectedSubjectId;

    if (!mounted) return;

    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus membuat mata pelajaran terlebih dahulu.')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        int? dialogSelectedSubjectId;
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: const Text('Pilih Mata Pelajaran'),
          content: Form(
            key: formKey,
            child: DropdownButtonFormField<int>(
              hint: const Text('Pilih...'),
              items: subjects.map((subject) {
                return DropdownMenuItem<int>(
                  value: subject.id,
                  child: Text(subject.name),
                );
              }).toList(),
              onChanged: (value) {
                dialogSelectedSubjectId = value;
              },
              validator: (value) => value == null ? 'Harus dipilih' : null,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Simpan'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  selectedSubjectId = dialogSelectedSubjectId;
                  if (selectedSubjectId != null) {
                    final newRpp = Rpp(
                      subjectId: selectedSubjectId!,
                      title: widget.request.topic,
                      content: _rppContent,
                    );
                    await _dbHelper.insertRpp(newRpp);

                    if (!mounted) return;
                    Navigator.of(context).pop(); // Tutup dialog
                    Navigator.of(context).pop(true); // Kembali dari result screen
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _copyRpp() async {
    final document = html_parser.parse(_rppContent);
    final String text = document.body?.text ?? '';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konten RPP disalin ke clipboard')),
      );
    }
  }

  Future<void> _shareRpp() async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/rpp.html';
    final file = File(filePath);
    await file.writeAsString(_rppContent);

    final xFile = XFile(filePath, mimeType: 'text/html');

    await Share.shareXFiles(
      [xFile],
      subject: 'RPP: ${widget.request.topic}',
      text: 'Berikut adalah file RPP yang dihasilkan.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil RPP (AI)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Salin Teks',
            onPressed: _copyRpp,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Bagikan/Unduh',
            onPressed: _shareRpp,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Simpan RPP',
            onPressed: _saveRpp,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Html(
          data: _rppContent,
          style: {
            "h3": Style(
              fontSize: FontSize.xLarge,
              fontWeight: FontWeight.bold,
              margin: Margins.only(top: 16, bottom: 8),
            ),
            "h4": Style(
              fontSize: FontSize.large,
              fontWeight: FontWeight.bold,
              margin: Margins.only(top: 12, bottom: 4),
            ),
            "p": Style(
              fontSize: FontSize.medium,
              lineHeight: LineHeight.em(1.5),
            ),
            "strong": Style(
              fontWeight: FontWeight.bold,
            ),
            "ol, ul": Style(
              margin: Margins.only(left: 20),
            ),
            "li": Style(
              lineHeight: LineHeight.em(1.5),
              padding: HtmlPaddings.only(left: 8),
            ),
            "hr": Style(
              border: Border(top: BorderSide(color: Colors.grey.shade400, width: 2)),
            ),
            "table, tr, td, th": Style(
              border: Border.all(color: Colors.black45),
              padding: HtmlPaddings.all(6),
              textAlign: TextAlign.center,
            ),
          },
        ),
      ),
    );
  }
}

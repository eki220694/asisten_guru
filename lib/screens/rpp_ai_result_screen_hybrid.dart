import 'package:flutter/material.dart';
import 'package:asisten_guru/models/rpp_ai_request.dart';
import 'package:asisten_guru/services/ai_rpp_service_hybrid.dart';
import 'package:flutter_html/flutter_html.dart';

class RppAiResultScreen extends StatefulWidget {
  final RppAiRequest request;

  const RppAiResultScreen({Key? key, required this.request}) : super(key: key);

  @override
  _RppAiResultScreenState createState() => _RppAiResultScreenState();
}

class _RppAiResultScreenState extends State<RppAiResultScreen> {
  final AiRppService _aiRppService = AiRppService();
  late final String _rppContent;

  @override
  void initState() {
    super.initState();
    _rppContent = _aiRppService.generateRpp(widget.request);
  }

  Future<void> _copyRpp() async {
    // Implementasi copy RPP
  }

  Future<void> _shareRpp() async {
    // Implementasi share RPP
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil RPP (AI Hybrid)'),
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
        ],
      ),
      body: SingleChildScrollView(
        child: Html(data: _rppContent),
      ),
    );
  }
}
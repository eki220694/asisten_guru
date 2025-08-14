import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../database/database_helper.dart';
import '../models/rpp.dart';
import '../models/subject.dart';
import 'rpp_detail_screen.dart';

class RppListScreen extends StatefulWidget {
  const RppListScreen({super.key});

  @override
  State<RppListScreen> createState() => _RppListScreenState();
}

class _RppListScreenState extends State<RppListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late Future<List<Rpp>> _rppFuture;
  late Future<List<Subject>> _subjectFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _rppFuture = _dbHelper.getRpps();
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
        future: Future.wait([_rppFuture, _subjectFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data![0].isEmpty) {
            return const Center(child: Text('Belum ada RPP. Tekan + untuk menambah.'));
          }

          final rpps = snapshot.data![0] as List<Rpp>;
          final subjects = snapshot.data![1] as List<Subject>;
          final groupedRpps = groupBy(rpps, (Rpp rpp) => rpp.subjectId);

          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              final rppsInSubject = groupedRpps[subject.id] ?? [];

              if (rppsInSubject.isEmpty) {
                return const SizedBox.shrink();
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ExpansionTile(
                  title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  initiallyExpanded: true,
                  children: rppsInSubject.map((rpp) {
                    return ListTile(
                      title: Text(rpp.title),
                      onTap: () => _navigateAndRefresh(context, RppDetailScreen(rpp: rpp)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () async {
                          await _dbHelper.deleteRpp(rpp.id!);
                          _loadData();
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(context, const RppDetailScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

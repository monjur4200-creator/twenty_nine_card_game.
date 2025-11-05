import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:twenty_nine_card_game/utils/csv_loader.dart';
import '../utils/latest_csv_loader.dart';
import 'package:twenty_nine_card_game/screens/bot_stats_dashboard.dart';

class BotStatsDashboardLoader extends StatefulWidget {
  const BotStatsDashboardLoader({super.key});
  
  @override
  State<BotStatsDashboardLoader> createState() => _BotStatsDashboardLoaderState();
}

class _BotStatsDashboardLoaderState extends State<BotStatsDashboardLoader> {
  File? _currentFile;
  List<Map<String, int>>? _runs;

  Future<void> _loadLatest() async {
    final file = await findLatestCsv();
    if (file != null) {
      final runs = await loadCsvFiles([file.path]);
      setState(() {
        _currentFile = file;
        _runs = runs;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final runs = await loadCsvFiles([file.path]);
      setState(() {
        _currentFile = file;
        _runs = runs;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLatest();
  }

  @override
  Widget build(BuildContext context) {
    if (_runs == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bot Stats Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadLatest,
            ),
          ],
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: _pickFile,
            child: const Text('Pick CSV File'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Bot Stats Dashboard (${_currentFile?.path.split('/').last})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLatest,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _pickFile,
          ),
        ],
      ),
      body: BotStatsDashboard(runs: _runs!),
    );
  }
}

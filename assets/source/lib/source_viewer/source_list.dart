import 'package:flutter/material.dart';
import 'code_viewer.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:async';

class SourceCodeBrowser extends StatefulWidget {
  const SourceCodeBrowser({super.key});

  @override
  State<SourceCodeBrowser> createState() => _SourceCodeBrowserState();
}

class _SourceCodeBrowserState extends State<SourceCodeBrowser> {
  List<String> _dartAssetFiles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _scanAssetDartFiles();
  }

  Future<void> _scanAssetDartFiles() async {
    // 读取AssetManifest.json，查找所有assets/source/lib/下的dart文件
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final dartFiles =
        manifestMap.keys.where((String key) => key.startsWith('assets/source/lib/') && key.endsWith('.dart')).toList();
    setState(() {
      _dartAssetFiles = dartFiles;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('源代码浏览器'),
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black87,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildCategoryTile(context, '项目文档', [
                  _CodeFile('项目说明', 'README.md', 'markdown'),
                ]),
                _buildCategoryTile(context, 'Dart源码（assets/source/lib/）',
                    _dartAssetFiles.map((path) => _CodeFile(_fileName(path), path, 'dart')).toList()),
              ],
            ),
    );
  }

  String _fileName(String path) {
    final parts = path.split('/');
    return parts.sublist(3).join('/'); // 去掉assets/source/lib/
  }

  Widget _buildCategoryTile(BuildContext context, String title, List<_CodeFile> files) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: files
          .map((file) => ListTile(
                leading: const Icon(Icons.code),
                title: Text(file.title),
                subtitle: Text(file.path, style: const TextStyle(fontSize: 12)),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CodeViewerPage(
                      title: '${file.title} (${file.path})',
                      filePath: file.path,
                      language: file.language,
                      useAsset: true,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _CodeFile {
  final String title;
  final String path;
  final String language;

  _CodeFile(this.title, this.path, this.language);
}

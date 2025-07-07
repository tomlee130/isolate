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
  Map<String, dynamic> _tree = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _scanAssetDartFiles();
  }

  Future<void> _scanAssetDartFiles() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final dartFiles =
        manifestMap.keys.where((String key) => key.startsWith('assets/source/lib/') && key.endsWith('.dart')).toList();
    // 构建目录树
    final Map<String, dynamic> tree = {};
    for (final path in dartFiles) {
      final relative = path.substring('assets/source/lib/'.length);
      final parts = relative.split('/');
      Map<String, dynamic> node = tree;
      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];
        if (i == parts.length - 1) {
          node[part] = path; // 文件节点存储完整asset路径
        } else {
          node = node.putIfAbsent(part, () => <String, dynamic>{});
        }
      }
    }
    setState(() {
      _tree = tree;
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
                  _CodeFile('项目说明', 'assets/README.md', 'markdown'),
                ]),
                ExpansionTile(
                  title: const Text('Dart源码（assets/source/lib/）', style: TextStyle(fontWeight: FontWeight.bold)),
                  children: [buildTree(context, _tree)],
                ),
              ],
            ),
    );
  }

  Widget buildTree(BuildContext context, Map<String, dynamic> node) {
    final entries = node.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries.map((entry) {
        if (entry.value is String) {
          // 文件节点
          final filePath = entry.value as String;
          return ListTile(
            leading: const Icon(Icons.code),
            title: Text(entry.key),
            subtitle: Text(filePath, style: const TextStyle(fontSize: 12)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CodeViewerPage(
                  title: '${entry.key} ($filePath)',
                  filePath: filePath,
                  language: 'dart',
                  useAsset: true,
                ),
              ),
            ),
          );
        } else {
          // 目录节点
          return ExpansionTile(
            leading: const Icon(Icons.folder),
            title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: [buildTree(context, entry.value as Map<String, dynamic>)],
          );
        }
      }).toList(),
    );
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

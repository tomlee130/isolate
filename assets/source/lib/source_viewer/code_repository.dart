import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class CodeRepository {
  /// 获取源代码内容
  static Future<String> getSourceCode(String filePath) async {
    try {
      // 优先支持assets模式
      if (filePath.startsWith('assets/source/lib/')) {
        return await rootBundle.loadString(filePath);
      }
      if (filePath.startsWith('lib/') || filePath.endsWith('.dart')) {
        final file = File(filePath);
        if (await file.exists()) {
          return await file.readAsString();
        }
      }
      // 读取assets或根目录文件
      return await rootBundle.loadString(filePath);
    } catch (e) {
      return '无法加载文件: $filePath\n$e';
    }
  }
}

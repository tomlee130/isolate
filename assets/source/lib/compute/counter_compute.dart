import 'dart:async';
import 'package:flutter/foundation.dart';

/// compute计数器实现
/// 使用Flutter提供的compute函数简化多线程操作
class ComputeCounter {
  int _count = 0;
  final StreamController<int> _countController = StreamController<int>.broadcast();
  final StreamController<String> _logController = StreamController<String>.broadcast();

  /// 当前计数值
  int get count => _count;

  /// 计数值变化流
  Stream<int> get countStream => _countController.stream;

  /// 日志流
  Stream<String> get logStream => _logController.stream;

  /// 计算偶数个数（同步）
  static int countEven(int num) {
    int count = 0;
    while (num >= 0) {
      if (num % 2 == 0) {
        count++;
      }
      num--;
    }
    return count;
  }

  /// 增加计数
  Future<void> increment() async {
    final stopwatch = Stopwatch()..start();
    _count = await compute(countEven, 1000000000);
    _countController.add(_count);
    stopwatch.stop();
    _logController.add('增加操作完成，耗时:  ${stopwatch.elapsedMilliseconds}ms (compute线程)');
  }

  /// 减少计数
  Future<void> decrement() async {
    final stopwatch = Stopwatch()..start();
    _count = await compute(countEven, 1000000000);
    _countController.add(_count);
    stopwatch.stop();
    _logController.add('减少操作完成，耗时: ${stopwatch.elapsedMilliseconds}ms (compute线程)');
  }

  /// 重置计数
  Future<void> reset() async {
    final stopwatch = Stopwatch()..start();
    _count = await compute(countEven, 1000000000);
    _countController.add(_count);
    stopwatch.stop();
    _logController.add('重置操作完成，耗时: ${stopwatch.elapsedMilliseconds}ms (compute线程)');
  }

  /// 获取线程信息
  String getThreadInfo() {
    return 'compute线程 (自动管理Isolate)';
  }

  /// 释放资源
  void dispose() {
    _countController.close();
    _logController.close();
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Isolate计数器实现
/// 使用compute函数进行并行处理，避免原生Isolate的资源冲突
class IsolateCounter {
  int _count = 0;
  final StreamController<int> _countController = StreamController<int>.broadcast();
  final StreamController<String> _logController = StreamController<String>.broadcast();

  bool _isDisposed = false;

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

  /// 初始化Isolate
  Future<void> initialize() async {
    if (_isDisposed) return;
    // compute函数会自动管理Isolate，无需手动初始化
  }

  /// 增加计数
  Future<void> increment() async {
    if (_isDisposed) return;
    final stopwatch = Stopwatch()..start();
    _count = await compute(countEven, 1000000000);
    _countController.add(_count);
    _logController.add('增加操作完成，耗时: ${stopwatch.elapsedMilliseconds}ms (Isolate线程)');
  }

  /// 减少计数
  Future<void> decrement() async {
    if (_isDisposed) return;
    final stopwatch = Stopwatch()..start();
    _count = await compute(countEven, 1000000000);
    _countController.add(_count);
    _logController.add('减少操作完成，耗时: ${stopwatch.elapsedMilliseconds}ms (Isolate线程)');
  }

  /// 重置计数
  Future<void> reset() async {
    if (_isDisposed) return;
    final stopwatch = Stopwatch()..start();
    _count = await compute(countEven, 1000000000);
    _countController.add(_count);
    _logController.add('重置操作完成，耗时: ${stopwatch.elapsedMilliseconds}ms (Isolate线程)');
  }

  /// 获取线程信息
  String getThreadInfo() {
    if (_isDisposed) return '已销毁';
    return 'Isolate线程 (使用compute函数)';
  }

  /// 释放资源
  void dispose() {
    _isDisposed = true;

    if (!_countController.isClosed) {
      _countController.close();
    }
    if (!_logController.isClosed) {
      _logController.close();
    }
  }
}

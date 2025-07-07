import 'dart:async';

/// 普通计数器实现
/// 使用单线程在主UI线程中执行计数操作
class NormalCounter {
  int _count = 0;
  final StreamController<int> _countController = StreamController<int>.broadcast();
  final StreamController<String> _logController = StreamController<String>.broadcast();

  /// 当前计数值
  int get count => _count;

  /// 计数值变化流
  Stream<int> get countStream => _countController.stream;

  /// 日志流
  Stream<String> get logStream => _logController.stream;

  /// 异步计算偶数个数
  static Future<int> asyncCountEven(int num) async {
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
    // 执行异步计算工作
    _count = await asyncCountEven(1000000000);
    _countController.add(_count);
    stopwatch.stop();
    _logController.add('增加操作完成，耗时: ${stopwatch.elapsedMilliseconds}ms (主线程)');
  }

  /// 减少计数
  Future<void> decrement() async {
    final stopwatch = Stopwatch()..start();
    // 执行异步计算工作
    _count = await asyncCountEven(1000000000);
    _countController.add(_count);
    stopwatch.stop();
    _logController.add('减少操作完成，耗时: ${stopwatch.elapsedMilliseconds}ms (主线程)');
  }

  /// 重置计数
  Future<void> reset() async {
    final stopwatch = Stopwatch()..start();
    // 执行异步计算工作
    _count = await asyncCountEven(1000000000);
    _countController.add(_count);
    stopwatch.stop();
    _logController.add('重置操作完成，耗时: ${stopwatch.elapsedMilliseconds}ms (主线程)');
  }

  /// 获取线程信息
  String getThreadInfo() {
    return '主UI线程 (单线程执行)';
  }

  /// 释放资源
  void dispose() {
    _countController.close();
    _logController.close();
  }
}

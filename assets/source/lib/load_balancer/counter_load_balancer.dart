import 'dart:async';
import 'dart:isolate';
import 'package:isolate/isolate.dart';

/// LoadBalancer计数器实现
/// 使用isolate包的LoadBalancer进行线程池管理
class LoadBalancerCounter {
  int _count = 0;
  final StreamController<int> _countController = StreamController<int>.broadcast();
  final StreamController<String> _logController = StreamController<String>.broadcast();

  LoadBalancer? _loadBalancer;
  bool _isInitialized = false;

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

  /// 初始化LoadBalancer
  Future<void> initialize() async {
    if (_isInitialized) return;

    _loadBalancer = await LoadBalancer.create(4, IsolateRunner.spawn);
    _isInitialized = true;
  }

  /// 增加计数
  Future<void> increment() async {
    if (!_isInitialized) await initialize();
    final stopwatch = Stopwatch()..start();
    _count = await _loadBalancer!.run(countEven, 1000000000);
    _countController.add(_count);
    _logController.add('增加操作完成，耗时: ${stopwatch.elapsedMilliseconds}ms (LoadBalancer线程)');
  }

  /// 减少计数
  Future<void> decrement() async {
    if (!_isInitialized) await initialize();
    final stopwatch = Stopwatch()..start();
    _count = await _loadBalancer!.run(countEven, 1000000000);
    _countController.add(_count);
    _logController.add('减少操作完成，耗时: ${stopwatch.elapsedMilliseconds}ms (LoadBalancer线程)');
  }

  /// 重置计数
  Future<void> reset() async {
    if (!_isInitialized) await initialize();
    final stopwatch = Stopwatch()..start();
    _count = await _loadBalancer!.run(countEven, 1000000000);
    _countController.add(_count);
    _logController.add('重置操作完成，耗时: ${stopwatch.elapsedMilliseconds}ms (LoadBalancer线程)');
  }

  /// 获取线程信息
  String getThreadInfo() {
    return _isInitialized ? 'LoadBalancer线程池 (4个Isolate，自动负载均衡)' : '未初始化';
  }

  /// 释放资源
  void dispose() {
    _loadBalancer?.close();
    _loadBalancer = null;
    _isInitialized = false;
    _countController.close();
    _logController.close();
  }
}

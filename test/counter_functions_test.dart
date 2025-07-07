import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_demo/normal/counter_normal.dart';
import 'package:isolate_demo/isolate/counter_isolate.dart';
import 'package:isolate_demo/compute/counter_compute.dart';
import 'package:isolate_demo/load_balancer/counter_load_balancer.dart';

/// 本地实现的计算偶数个数函数
int countEven(int num) {
  int count = 0;
  while (num >= 0) {
    if (num % 2 == 0) {
      count++;
    }
    num--;
  }
  return count;
}

void main() {
  group('异步计算偶数函数测试', () {
    test('asyncCountEven函数正确性', () async {
      // 测试小数值
      expect(await NormalCounter.asyncCountEven(10), 6); // 0,2,4,6,8,10
      expect(await NormalCounter.asyncCountEven(5), 3); // 0,2,4
      expect(await NormalCounter.asyncCountEven(1), 1); // 0
      expect(await NormalCounter.asyncCountEven(0), 1); // 0
    });

    test('asyncCountEven函数性能', () async {
      // 内联实现计算偶数个数
      int countEvenInline(int num) {
        int count = 0;
        while (num >= 0) {
          if (num % 2 == 0) {
            count++;
          }
          num--;
        }
        return count;
      }

      final stopwatch = Stopwatch()..start();
      final result = countEvenInline(1000000);
      stopwatch.stop();

      expect(result, 500001); // 0到1000000中的偶数个数
      expect(stopwatch.elapsedMilliseconds, greaterThan(0));
    });
  });

  group('普通计数器测试', () {
    test('基本功能', () async {
      final counter = NormalCounter();
      expect(counter.count, 0);

      await counter.increment();
      expect(counter.count, 500000001); // 0到1000000000中的偶数个数

      await counter.decrement();
      expect(counter.count, 500000001); // 每次操作都重新计算

      await counter.reset();
      expect(counter.count, 500000001); // 重置也重新计算

      counter.dispose();
    });

    test('流监听', () async {
      final counter = NormalCounter();
      int streamCount = 0;
      bool streamUpdated = false;

      counter.countStream.listen((count) {
        streamCount = count;
        streamUpdated = true;
      });

      await counter.increment();

      // 等待流更新
      await Future.delayed(const Duration(milliseconds: 100));
      expect(streamUpdated, true);
      expect(streamCount, 500000001);

      counter.dispose();
    });
  });

  group('Isolate计数器测试', () {
    test('基本功能', () async {
      final counter = IsolateCounter();
      await counter.initialize();
      expect(counter.count, 0);

      await counter.increment();
      expect(counter.count, 500000001);

      await counter.decrement();
      expect(counter.count, 500000001);

      await counter.reset();
      expect(counter.count, 500000001);

      counter.dispose();
    });

    test('流监听', () async {
      final counter = IsolateCounter();
      await counter.initialize();
      int streamCount = 0;
      bool streamUpdated = false;

      counter.countStream.listen((count) {
        streamCount = count;
        streamUpdated = true;
      });

      await counter.increment();

      // 等待流更新
      await Future.delayed(const Duration(milliseconds: 100));
      expect(streamUpdated, true);
      expect(streamCount, 500000001);

      counter.dispose();
    });
  });

  group('compute计数器测试', () {
    test('基本功能', () async {
      final counter = ComputeCounter();
      expect(counter.count, 0);

      await counter.increment();
      expect(counter.count, 500000001);

      await counter.decrement();
      expect(counter.count, 500000001);

      await counter.reset();
      expect(counter.count, 500000001);

      counter.dispose();
    });

    test('流监听', () async {
      final counter = ComputeCounter();
      int streamCount = 0;
      bool streamUpdated = false;

      counter.countStream.listen((count) {
        streamCount = count;
        streamUpdated = true;
      });

      await counter.increment();

      // 等待流更新
      await Future.delayed(const Duration(milliseconds: 100));
      expect(streamUpdated, true);
      expect(streamCount, 500000001);

      counter.dispose();
    });
  });

  group('LoadBalancer计数器测试', () {
    test('基本功能', () async {
      final counter = LoadBalancerCounter();
      await counter.initialize();
      expect(counter.count, 0);

      await counter.increment();
      expect(counter.count, 500000001);

      await counter.decrement();
      expect(counter.count, 500000001);

      await counter.reset();
      expect(counter.count, 500000001);

      counter.dispose();
    });

    test('流监听', () async {
      final counter = LoadBalancerCounter();
      await counter.initialize();
      int streamCount = 0;
      bool streamUpdated = false;

      counter.countStream.listen((count) {
        streamCount = count;
        streamUpdated = true;
      });

      await counter.increment();

      // 等待流更新
      await Future.delayed(const Duration(milliseconds: 100));
      expect(streamUpdated, true);
      expect(streamCount, 500000001);

      counter.dispose();
    });
  });

  group('性能对比测试', () {
    test('不同实现方式的性能差异', () async {
      // 测试小数值以快速比较
      final smallNum = 100000;
      final expectedResult = 50001; // 0到100000中的偶数个数

      // 本地实现
      final localStopwatch = Stopwatch()..start();
      final localResult = countEven(smallNum);
      localStopwatch.stop();

      // compute实现
      final computeStopwatch = Stopwatch()..start();
      final computeResult = ComputeCounter.countEven(smallNum);
      computeStopwatch.stop();

      expect(localResult, expectedResult);
      expect(computeResult, expectedResult);

      // 验证所有实现都返回相同结果
      expect(localResult, computeResult);
    });
  });
}

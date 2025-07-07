// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_demo/main.dart';

void main() {
  group('主页面测试', () {
    testWidgets('主页面展示和跳转 smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(const IsolateApp());

      // 检查主页面标题
      expect(find.text('Flutter Isolate 多线程计数器示例'), findsOneWidget);
      // 检查四种实现入口
      expect(find.text('普通实现'), findsOneWidget);
      expect(find.text('Isolate实现'), findsOneWidget);
      expect(find.text('compute实现'), findsOneWidget);
      expect(find.text('LoadBalancer实现'), findsOneWidget);
      // 检查代码浏览入口
      expect(find.byIcon(Icons.code), findsOneWidget);
    });

    testWidgets('实现方式卡片点击测试', (WidgetTester tester) async {
      await tester.pumpWidget(const IsolateApp());

      // 点击普通实现卡片
      await tester.tap(find.text('普通实现'));
      await tester.pumpAndSettle();

      // 验证跳转到普通计数器页面
      expect(find.text('普通计数器'), findsOneWidget);
      expect(find.text('当前计数'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'normal/view.dart';
import 'isolate/view.dart';
import 'compute/view.dart';
import 'load_balancer/view.dart';
import 'source_viewer/source_list.dart';

void main() {
  runApp(const IsolateApp());
}

class IsolateApp extends StatelessWidget {
  const IsolateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Isolate 多线程计数器示例',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Isolate 多线程计数器示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SourceCodeBrowser(),
                ),
              );
            },
            tooltip: '查看源代码',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildImplementationCards(context),
          const SizedBox(height: 24),
          _buildFeaturesSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '多线程计数器实现对比',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '本项目展示了Flutter中四种不同的计数器实现方式，包括单线程和多种多线程实现，'
              '以便于比较它们的异同和性能特点。每种实现都提供了相同的功能，但使用不同的技术方案。',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImplementationCards(BuildContext context) {
    final implementations = [
      {
        'title': '普通实现',
        'subtitle': '单线程计数器',
        'description': '使用主UI线程执行计数操作，实现简单直观',
        'icon': Icons.looks_one,
        'color': Colors.green,
        'route': const NormalCounterPage(),
      },
      {
        'title': 'Isolate实现',
        'subtitle': '原生Dart Isolate',
        'description': '使用Dart原生的Isolate进行真正的并行处理',
        'icon': Icons.device_hub,
        'color': Colors.blue,
        'route': const IsolateCounterPage(),
      },
      {
        'title': 'compute实现',
        'subtitle': 'Flutter compute函数',
        'description': '使用Flutter提供的compute函数简化多线程操作',
        'icon': Icons.functions,
        'color': Colors.orange,
        'route': const ComputeCounterPage(),
      },
      {
        'title': 'LoadBalancer实现',
        'subtitle': '负载均衡器',
        'description': '使用LoadBalancer进行任务分发和负载均衡',
        'icon': Icons.balance,
        'color': Colors.purple,
        'route': const LoadBalancerCounterPage(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '实现方式',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        ...implementations.map((impl) => _buildImplementationCard(context, impl)),
      ],
    );
  }

  Widget _buildImplementationCard(BuildContext context, Map<String, dynamic> impl) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => impl['route']),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: impl['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  impl['icon'],
                  color: impl['color'],
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      impl['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      impl['subtitle'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      impl['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '功能特性',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.add_circle, '计数器操作', '增加、减少、重置计数器'),
            _buildFeatureItem(Icons.speed, '实时显示', '实时显示当前计数值和操作耗时'),
            _buildFeatureItem(Icons.memory, '性能监控', '显示线程信息和性能数据'),
            _buildFeatureItem(Icons.code, '代码浏览', '查看所有实现的源代码和文档'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

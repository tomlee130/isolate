import 'package:flutter/material.dart';
import 'dart:async';
import 'counter_compute.dart';

class ComputeCounterPage extends StatefulWidget {
  const ComputeCounterPage({super.key});

  @override
  State<ComputeCounterPage> createState() => _ComputeCounterPageState();
}

class _ComputeCounterPageState extends State<ComputeCounterPage> {
  final ComputeCounter _counter = ComputeCounter();
  final List<String> _logs = [];
  bool _isIncrementLoading = false;
  bool _isDecrementLoading = false;
  bool _isResetLoading = false;

  @override
  void initState() {
    super.initState();
    _counter.countStream.listen((count) {
      if (mounted) {
        setState(() {});
      }
    });

    _counter.logStream.listen((log) {
      if (mounted) {
        setState(() {
          _logs.insert(0, '${DateTime.now().toString().substring(11, 19)} $log');
          if (_logs.length > 10) {
            _logs.removeLast();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('compute计数器'),
        backgroundColor: Colors.orange[100],
        foregroundColor: Colors.orange[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCounterDisplay(),
            const SizedBox(height: 24),
            _buildControlButtons(),
            const SizedBox(height: 24),
            _buildThreadInfo(),
            const SizedBox(height: 24),
            _buildLogsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterDisplay() {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              '当前计数',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_counter.count}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _isIncrementLoading ? null : _increment,
          icon: const Icon(Icons.add),
          label: const Text('增加'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isDecrementLoading ? null : _decrement,
          icon: const Icon(Icons.remove),
          label: const Text('减少'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isResetLoading ? null : _reset,
          icon: const Icon(Icons.refresh),
          label: const Text('重置'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildThreadInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  '线程信息',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _counter.getThreadInfo(),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '特点：使用Flutter的compute函数，自动管理Isolate生命周期，API简单易用。',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsSection() {
    return Expanded(
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  const Text(
                    '操作日志',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _logs.isEmpty
                  ? const Center(
                      child: Text(
                        '暂无操作日志',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            _logs[index],
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _increment() async {
    setState(() {
      _isIncrementLoading = true;
    });
    await _counter.increment();
    setState(() {
      _isIncrementLoading = false;
    });
  }

  Future<void> _decrement() async {
    setState(() {
      _isDecrementLoading = true;
    });
    await _counter.decrement();
    setState(() {
      _isDecrementLoading = false;
    });
  }

  Future<void> _reset() async {
    setState(() {
      _isResetLoading = true;
    });
    await _counter.reset();
    setState(() {
      _isResetLoading = false;
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cases/bloc_case.dart' as bloc;
import 'cases/riverpod_case.dart' as riverpod;
import 'cases/pipex_case.dart' as pipex;

void main() {
  runApp(const ProviderScope(child: BenchmarkApp()));
}

class BenchmarkApp extends StatelessWidget {
  const BenchmarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'State Management Benchmark',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const BenchmarkHomePage(),
    );
  }
}

class BenchmarkHomePage extends StatefulWidget {
  const BenchmarkHomePage({super.key});

  @override
  State<BenchmarkHomePage> createState() => _BenchmarkHomePageState();
}

class _BenchmarkHomePageState extends State<BenchmarkHomePage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Management Benchmark'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _buildBenchmarkContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTab('Simple Counter', 0),
            _buildTab('Multi-Counter', 1),
            _buildTab('Complex State', 2),
            _buildTab('Derived State', 3),
            _buildTab('Async Flow', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildBenchmarkContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selectedTab == 0) ..._buildSimpleCounterBenchmarks(),
          if (_selectedTab == 1) ..._buildMultiCounterBenchmarks(),
          if (_selectedTab == 2) ..._buildComplexStateBenchmarks(),
          if (_selectedTab == 3) ..._buildDerivedStateBenchmarks(),
          if (_selectedTab == 4) ..._buildAsyncFlowBenchmarks(),
        ],
      ),
    );
  }

  List<Widget> _buildSimpleCounterBenchmarks() {
    return [
      const Text(
        'Simple Counter Benchmark',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      const Text(
        'Tests basic increment/decrement operations with single value state.',
        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
      ),
      const SizedBox(height: 24),
      const Card(
        color: Colors.blue,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '💡 How to Benchmark',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('Run automated tests with:'),
              SizedBox(height: 4),
              SelectableText(
                'flutter test integration_test/ui_benchmark_test.dart',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 8),
              Text('Or manually test by clicking buttons below:'),
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),
      _buildBenchmarkCard(
        'BLoC',
        Colors.blue,
        const bloc.BlocCounterWidget(),
      ),
      const SizedBox(height: 16),
      _buildBenchmarkCard(
        'Riverpod',
        Colors.green,
        const riverpod.RiverpodCounterWidget(),
      ),
      const SizedBox(height: 16),
      _buildBenchmarkCard(
        'PipeX',
        Colors.purple,
        const pipex.PipeXCounterWidget(),
      ),
    ];
  }

  List<Widget> _buildMultiCounterBenchmarks() {
    const counterCount = 50;
    return [
      const Text(
        'Multi-Counter Benchmark',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        'Tests performance with $counterCount independent counters.',
        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
      ),
      const SizedBox(height: 24),
      _buildBenchmarkCard(
        'BLoC',
        Colors.blue,
        const bloc.BlocMultiCounterWidget(count: counterCount),
      ),
      const SizedBox(height: 16),
      _buildBenchmarkCard(
        'Riverpod',
        Colors.green,
        const riverpod.RiverpodMultiCounterWidget(count: counterCount),
      ),
      const SizedBox(height: 16),
      _buildBenchmarkCard(
        'PipeX',
        Colors.purple,
        const pipex.PipeXMultiCounterWidget(count: counterCount),
      ),
      const SizedBox(height: 24),
      const Card(
        color: Colors.amber,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚖️ Fair Comparison Notes:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                  '• Riverpod: NOW USES ISOLATED PROVIDERS - Each counter is independent (family providers)'),
              Text(
                  '• PipeX: Independent pipes per counter - Perfect isolation'),
              Text('• BLoC: Map-based state - Updates may trigger all widgets'),
              SizedBox(height: 8),
              Text(
                'With isolated providers, Riverpod and PipeX have equivalent architectures for this test.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildComplexStateBenchmarks() {
    return [
      const Text(
        'Complex State Benchmark',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      const Text(
        'Tests performance with large, nested state objects.',
        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
      ),
      const SizedBox(height: 24),
      _buildBenchmarkCard(
        'BLoC',
        Colors.blue,
        const bloc.BlocComplexWidget(),
      ),
      const SizedBox(height: 16),
      _buildBenchmarkCard(
        'Riverpod',
        Colors.green,
        const riverpod.RiverpodComplexWidget(),
      ),
      const SizedBox(height: 16),
      _buildBenchmarkCard(
        'PipeX',
        Colors.purple,
        const pipex.PipeXComplexWidget(),
      ),
    ];
  }

  List<Widget> _buildDerivedStateBenchmarks() {
    return [
      const Text(
        'Derived/Computed State Benchmark',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      const Text(
        'Tests automatic recomputation of derived values from base state. '
        'Showcases Riverpod\'s strength vs manual updates.',
        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
      ),
      const SizedBox(height: 24),
      _buildBenchmarkCard(
        'BLoC',
        Colors.blue,
        const bloc.BlocDerivedStateWidget(),
      ),
      const SizedBox(height: 16),
      _buildBenchmarkCard(
        'Riverpod',
        Colors.green,
        const riverpod.RiverpodDerivedStateWidget(),
      ),
      const SizedBox(height: 16),
      _buildBenchmarkCard(
        'PipeX',
        Colors.purple,
        const pipex.PipeXDerivedStateWidget(),
      ),
      const SizedBox(height: 24),
      const Card(
        color: Colors.amber,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚖️ Fair Comparison Notes:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                  '• Riverpod: Automatic dependency tracking - computed values update automatically'),
              Text('• PipeX: Manual listeners - requires explicit wiring'),
              Text('• BLoC: Recomputed on state emission - bundled approach'),
              SizedBox(height: 8),
              Text(
                'Riverpod excels here with zero boilerplate for computed state.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildAsyncFlowBenchmarks() {
    return [
      const Text(
        'Complex Async Flow Benchmark',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      const Text(
        'Tests complex async operations with debouncing, error handling, and loading states. '
        'Showcases BLoC\'s strength in async event processing.',
        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
      ),
      const SizedBox(height: 24),
      _buildBenchmarkCard(
        'BLoC',
        Colors.blue,
        const bloc.BlocAsyncSearchWidget(),
      ),
      const SizedBox(height: 24),
      const Card(
        color: Colors.amber,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚖️ Fair Comparison Notes:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                  '• BLoC: Built-in stream transformers for debouncing, throttling, etc.'),
              Text(
                  '• Riverpod: AsyncNotifier handles async, but needs manual debouncing'),
              Text('• PipeX: Manual async handling with listeners'),
              SizedBox(height: 8),
              Text(
                'BLoC excels here with its event-driven architecture and stream operators.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildBenchmarkCard(String title, Color color, Widget child) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  color: color,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

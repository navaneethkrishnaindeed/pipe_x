import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ============================================================================
// BLOC Case: Counter with rapid updates
// ============================================================================

class CounterEvent {}

class IncrementEvent extends CounterEvent {}

class DecrementEvent extends CounterEvent {}

class SetValueEvent extends CounterEvent {
  final int value;
  SetValueEvent(this.value);
}

class CounterState {
  final int value;
  const CounterState(this.value);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState(0)) {
    on<IncrementEvent>((event, emit) => emit(CounterState(state.value + 1)));
    on<DecrementEvent>((event, emit) => emit(CounterState(state.value - 1)));
    on<SetValueEvent>((event, emit) => emit(CounterState(event.value)));
  }
}

// ============================================================================
// BLOC Case: Multi-Counter (Many independent counters)
// ============================================================================

class MultiCounterState {
  final Map<int, int> counters;
  const MultiCounterState(this.counters);

  MultiCounterState copyWith({Map<int, int>? counters}) {
    return MultiCounterState(counters ?? this.counters);
  }
}

class UpdateCounterEvent extends CounterEvent {
  final int id;
  final int value;
  UpdateCounterEvent(this.id, this.value);
}

class MultiCounterBloc extends Bloc<CounterEvent, MultiCounterState> {
  MultiCounterBloc(int count)
      : super(MultiCounterState(Map.fromIterable(List.generate(count, (i) => i),
            key: (i) => i, value: (_) => 0))) {
    on<UpdateCounterEvent>((event, emit) {
      final newCounters = Map<int, int>.from(state.counters);
      newCounters[event.id] = event.value;
      emit(MultiCounterState(newCounters));
    });
  }

  void increment(int id) {
    add(UpdateCounterEvent(id, (state.counters[id] ?? 0) + 1));
  }
}

// ============================================================================
// BLOC Case: Complex State (Large object with nested data)
// ============================================================================

class ComplexData {
  final String text;
  final int number;
  final double percentage;
  final bool flag;
  final List<String> items;
  final Map<String, dynamic> metadata;

  const ComplexData({
    required this.text,
    required this.number,
    required this.percentage,
    required this.flag,
    required this.items,
    required this.metadata,
  });

  ComplexData copyWith({
    String? text,
    int? number,
    double? percentage,
    bool? flag,
    List<String>? items,
    Map<String, dynamic>? metadata,
  }) {
    return ComplexData(
      text: text ?? this.text,
      number: number ?? this.number,
      percentage: percentage ?? this.percentage,
      flag: flag ?? this.flag,
      items: items ?? this.items,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ComplexState {
  final ComplexData data;
  const ComplexState(this.data);
}

class UpdateTextEvent extends CounterEvent {
  final String text;
  UpdateTextEvent(this.text);
}

class UpdateNumberEvent extends CounterEvent {
  final int number;
  UpdateNumberEvent(this.number);
}

class UpdatePercentageEvent extends CounterEvent {
  final double percentage;
  UpdatePercentageEvent(this.percentage);
}

class ComplexBloc extends Bloc<CounterEvent, ComplexState> {
  ComplexBloc()
      : super(ComplexState(ComplexData(
          text: 'Initial',
          number: 0,
          percentage: 0.0,
          flag: false,
          items: [],
          metadata: {},
        ))) {
    on<UpdateTextEvent>((event, emit) =>
        emit(ComplexState(state.data.copyWith(text: event.text))));
    on<UpdateNumberEvent>((event, emit) =>
        emit(ComplexState(state.data.copyWith(number: event.number))));
    on<UpdatePercentageEvent>((event, emit) =>
        emit(ComplexState(state.data.copyWith(percentage: event.percentage))));
  }
}

// ============================================================================
// BLOC Case: Async Stream (Simulates rapid async updates)
// ============================================================================

class AsyncCounterBloc extends Bloc<CounterEvent, CounterState> {
  AsyncCounterBloc() : super(const CounterState(0)) {
    on<IncrementEvent>((event, emit) async {
      await Future.delayed(const Duration(microseconds: 100));
      emit(CounterState(state.value + 1));
    });
  }

  Stream<int> rapidStream(int count) async* {
    for (int i = 0; i < count; i++) {
      await Future.delayed(const Duration(microseconds: 100));
      yield i;
    }
  }
}

// ============================================================================
// BLoC Case: Derived State (Manual computation in state)
// ============================================================================

class DerivedState {
  final int baseCount;
  final int doubleCount;
  final int squareCount;
  final bool isEven;
  final int factorial;
  final String summary;

  DerivedState({
    required this.baseCount,
    required this.doubleCount,
    required this.squareCount,
    required this.isEven,
    required this.factorial,
    required this.summary,
  });

  factory DerivedState.fromBase(int base) {
    final double = base * 2;
    final square = base * base;
    final isEven = base % 2 == 0;

    int factorial = 1;
    if (base > 0) {
      for (int i = 1; i <= base && i <= 20; i++) {
        factorial *= i;
      }
    }

    final summary = 'Count: $base, Double: $double, ${isEven ? "Even" : "Odd"}';

    return DerivedState(
      baseCount: base,
      doubleCount: double,
      squareCount: square,
      isEven: isEven,
      factorial: factorial,
      summary: summary,
    );
  }
}

class IncrementDerivedEvent extends CounterEvent {}

class ResetDerivedEvent extends CounterEvent {}

class DerivedStateBloc extends Bloc<CounterEvent, DerivedState> {
  DerivedStateBloc() : super(DerivedState.fromBase(0)) {
    on<IncrementDerivedEvent>((event, emit) {
      emit(DerivedState.fromBase(state.baseCount + 1));
    });

    on<ResetDerivedEvent>((event, emit) {
      emit(DerivedState.fromBase(0));
    });
  }
}

// ============================================================================
// BLoC Case: Complex Async Flows (BLoC's STRENGTH)
// ============================================================================

class SearchEvent extends CounterEvent {
  final String query;
  SearchEvent(this.query);
}

class SearchResultEvent extends CounterEvent {
  final List<String> results;
  SearchResultEvent(this.results);
}

class SearchState {
  final String query;
  final List<String> results;
  final bool isLoading;
  final String? error;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<String>? results,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SearchBloc extends Bloc<CounterEvent, SearchState> {
  SearchBloc() : super(const SearchState()) {
    // Complex async flow with debounce and error handling
    on<SearchEvent>(
      (event, emit) async {
        emit(state.copyWith(query: event.query, isLoading: true, error: null));

        try {
          // Simulate API call with variable latency
          await Future.delayed(
              Duration(milliseconds: 100 + (event.query.length * 10)));

          // Simulate search results
          final results = List.generate(
            10,
            (i) => '${event.query} - Result ${i + 1}',
          );

          emit(state.copyWith(results: results, isLoading: false));
        } catch (e) {
          emit(state.copyWith(error: e.toString(), isLoading: false));
        }
      },
      // BLoC's built-in transformer for debouncing
      transformer: (events, mapper) {
        return events.distinct().asyncExpand(mapper);
      },
    );
  }
}

// ============================================================================
// BLOC UI Components
// ============================================================================

class BlocCounterWidget extends StatelessWidget {
  const BlocCounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterBloc, CounterState>(
      builder: (context, state) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('BLoC: ${state.value}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () =>
                        context.read<CounterBloc>().add(DecrementEvent()),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () =>
                        context.read<CounterBloc>().add(IncrementEvent()),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class BlocMultiCounterWidget extends StatelessWidget {
  final int count;
  final bool useOptimized;

  const BlocMultiCounterWidget({
    super.key,
    required this.count,
    this.useOptimized = true, // Default to fair/optimized implementation
  });

  @override
  Widget build(BuildContext context) {
    if (useOptimized) {
      // FAIR: Each counter uses BlocSelector (isolated rebuilds like Riverpod/PipeX)
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('BLoC Multi-Counter ($count) [Optimized]',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(
                  count,
                  (i) => BlocSelector<MultiCounterBloc, MultiCounterState, int>(
                    selector: (state) => state.counters[i] ?? 0,
                    builder: (context, value) {
                      return Chip(
                        label: Text('$value'),
                        onDeleted: () =>
                            context.read<MultiCounterBloc>().increment(i),
                        deleteIcon: const Icon(Icons.add, size: 16),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // LEGACY: BlocBuilder rebuilds ALL counters (unfair vs Riverpod/PipeX)
      return BlocBuilder<MultiCounterBloc, MultiCounterState>(
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('BLoC Multi-Counter ($count) [Legacy]',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: List.generate(
                      count,
                      (i) => Chip(
                        label: Text('${state.counters[i]}'),
                        onDeleted: () =>
                            context.read<MultiCounterBloc>().increment(i),
                        deleteIcon: const Icon(Icons.add, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}

class BlocComplexWidget extends StatelessWidget {
  const BlocComplexWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComplexBloc, ComplexState>(
      builder: (context, state) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('BLoC Complex: ${state.data.text}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Number: ${state.data.number}'),
                    const SizedBox(height: 4),
                    Text(
                        'Percentage: ${state.data.percentage.toStringAsFixed(2)}%'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.update, size: 18),
                      onPressed: () => context
                          .read<ComplexBloc>()
                          .add(UpdateNumberEvent(state.data.number + 1)),
                      label: const Text('Update'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BlocDerivedStateWidget extends StatelessWidget {
  const BlocDerivedStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DerivedStateBloc, DerivedState>(
      builder: (context, state) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'BLoC Derived State (Computed in State)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                            'Base', '${state.baseCount}', Icons.looks_one),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                            'Double', '${state.doubleCount}', Icons.looks_two),
                        const SizedBox(height: 8),
                        _buildInfoRow('Square', '${state.squareCount}',
                            Icons.crop_square),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                            'Is Even', '${state.isEven}', Icons.check_circle),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                            'Factorial', '${state.factorial}', Icons.calculate),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Icon(Icons.summarize,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(state.summary,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => context
                          .read<DerivedStateBloc>()
                          .add(IncrementDerivedEvent()),
                      label: const Text('Increment'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh, size: 18),
                      onPressed: () => context
                          .read<DerivedStateBloc>()
                          .add(ResetDerivedEvent()),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class BlocAsyncSearchWidget extends StatelessWidget {
  const BlocAsyncSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'BLoC Complex Async Flow (Debounced Search)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search',
                    hintText: 'Type to search...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) =>
                      context.read<SearchBloc>().add(SearchEvent(value)),
                ),
                const SizedBox(height: 16),
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  )
                else if (state.error != null)
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Error: ${state.error}',
                                style: TextStyle(color: Colors.red[700])),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state.results.isNotEmpty)
                  Card(
                    elevation: 4,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        itemCount: state.results.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text('${index + 1}'),
                            ),
                            title: Text(state.results[index]),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                          );
                        },
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(Icons.search, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text('Type to search...',
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

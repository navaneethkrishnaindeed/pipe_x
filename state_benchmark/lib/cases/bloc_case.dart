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
    return BlocProvider(
      create: (_) => CounterBloc(),
      child: BlocBuilder<CounterBloc, CounterState>(
        builder: (context, state) {
          return Column(
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
          );
        },
      ),
    );
  }
}

class BlocMultiCounterWidget extends StatelessWidget {
  final int count;
  const BlocMultiCounterWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MultiCounterBloc(count),
      child: BlocBuilder<MultiCounterBloc, MultiCounterState>(
        builder: (context, state) {
          return Column(
            children: [
              Text('BLoC Multi-Counter ($count)',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
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
          );
        },
      ),
    );
  }
}

class BlocComplexWidget extends StatelessWidget {
  const BlocComplexWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ComplexBloc(),
      child: BlocBuilder<ComplexBloc, ComplexState>(
        builder: (context, state) {
          return Column(
            children: [
              Text('BLoC Complex: ${state.data.text}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Number: ${state.data.number}'),
              Text('Percentage: ${state.data.percentage.toStringAsFixed(2)}%'),
              ElevatedButton(
                onPressed: () => context
                    .read<ComplexBloc>()
                    .add(UpdateNumberEvent(state.data.number + 1)),
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class BlocDerivedStateWidget extends StatelessWidget {
  const BlocDerivedStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DerivedStateBloc(),
      child: BlocBuilder<DerivedStateBloc, DerivedState>(
        builder: (context, state) {
          return Column(
            children: [
              const Text(
                'BLoC Derived State (Computed in State)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Base: ${state.baseCount}',
                          style: const TextStyle(fontSize: 14)),
                      Text('Double: ${state.doubleCount}',
                          style: const TextStyle(fontSize: 14)),
                      Text('Square: ${state.squareCount}',
                          style: const TextStyle(fontSize: 14)),
                      Text('Is Even: ${state.isEven}',
                          style: const TextStyle(fontSize: 14)),
                      Text('Factorial: ${state.factorial}',
                          style: const TextStyle(fontSize: 14)),
                      const Divider(),
                      Text('Summary: ${state.summary}',
                          style: const TextStyle(
                              fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => context
                        .read<DerivedStateBloc>()
                        .add(IncrementDerivedEvent()),
                    child: const Text('Increment Base'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => context
                        .read<DerivedStateBloc>()
                        .add(ResetDerivedEvent()),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class BlocAsyncSearchWidget extends StatelessWidget {
  const BlocAsyncSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchBloc(),
      child: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          return Column(
            children: [
              const Text(
                'BLoC Complex Async Flow (Debounced Search)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) =>
                    context.read<SearchBloc>().add(SearchEvent(value)),
              ),
              const SizedBox(height: 12),
              if (state.isLoading)
                const CircularProgressIndicator()
              else if (state.error != null)
                Text('Error: ${state.error}',
                    style: const TextStyle(color: Colors.red))
              else if (state.results.isNotEmpty)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: state.results.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        title: Text(state.results[index]),
                      );
                    },
                  ),
                )
              else
                const Text('Type to search...'),
            ],
          );
        },
      ),
    );
  }
}

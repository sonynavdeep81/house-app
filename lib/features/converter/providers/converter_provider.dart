import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/conversion_data.dart';

enum ConverterMode { area, lengthBreadth }

class ConverterState {
  final ConverterMode mode;
  final String fromUnit;
  final String toUnit;
  final String lengthUnit;
  final String breadthUnit;
  final double? result;

  const ConverterState({
    this.mode = ConverterMode.area,
    this.fromUnit = 'Small Marla',
    this.toUnit = 'Sq Ft',
    this.lengthUnit = 'Feet',
    this.breadthUnit = 'Feet',
    this.result,
  });

  ConverterState copyWith({
    ConverterMode? mode,
    String? fromUnit,
    String? toUnit,
    String? lengthUnit,
    String? breadthUnit,
    double? result,
  }) =>
      ConverterState(
        mode: mode ?? this.mode,
        fromUnit: fromUnit ?? this.fromUnit,
        toUnit: toUnit ?? this.toUnit,
        lengthUnit: lengthUnit ?? this.lengthUnit,
        breadthUnit: breadthUnit ?? this.breadthUnit,
        result: result ?? this.result,
      );
}

class ConverterNotifier extends StateNotifier<ConverterState> {
  ConverterNotifier() : super(const ConverterState());

  void setMode(ConverterMode mode) => state = state.copyWith(mode: mode);
  void setFromUnit(String u) => state = state.copyWith(fromUnit: u);
  void setToUnit(String u) => state = state.copyWith(toUnit: u);
  void setLengthUnit(String u) => state = state.copyWith(lengthUnit: u);
  void setBreadthUnit(String u) => state = state.copyWith(breadthUnit: u);

  void calculateArea(double value) {
    final r = convertArea(value, state.fromUnit, state.toUnit);
    state = state.copyWith(result: r);
  }

  void calculateFromLengthBreadth(double length, double breadth) {
    final r = lengthBreadthToArea(
      length, state.lengthUnit,
      breadth, state.breadthUnit,
      state.toUnit,
    );
    state = state.copyWith(result: r);
  }

  void clearResult() => state = ConverterState(
        mode: state.mode,
        fromUnit: state.fromUnit,
        toUnit: state.toUnit,
        lengthUnit: state.lengthUnit,
        breadthUnit: state.breadthUnit,
      );
}

final converterProvider =
    StateNotifierProvider<ConverterNotifier, ConverterState>(
  (ref) => ConverterNotifier(),
);

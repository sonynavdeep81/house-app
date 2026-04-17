import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../converter/data/conversion_data.dart';

const Map<String, double> brickSizeUnitToFeet = {
  'in': 1 / 12.0,
  'cm': 1 / 30.48,
  'mm': 1 / 304.8,
};

const Map<String, double> wallHeightUnitToFeet = {
  'Feet': 1.0,
  'Inches': 1 / 12.0,
  'Meters': 3.28084,
  'cm': 1 / 30.48,
};

enum WallInputMode { layers, height }

class BrickState {
  final String plotLengthUnit;
  final String brickSizeUnit;
  final double brickLength;
  final double brickWidth;
  final double brickHeight;
  final WallInputMode wallInputMode;
  final String wallHeightUnit;
  final int? totalBricks;
  final double? totalCost;
  final double? wallHeightFt;
  final int? computedLayers;

  const BrickState({
    this.plotLengthUnit = 'Feet',
    this.brickSizeUnit = 'in',
    this.brickLength = 9.0,
    this.brickWidth = 4.0,
    this.brickHeight = 4.0,
    this.wallInputMode = WallInputMode.layers,
    this.wallHeightUnit = 'Feet',
    this.totalBricks,
    this.totalCost,
    this.wallHeightFt,
    this.computedLayers,
  });

  BrickState copyWith({
    String? plotLengthUnit,
    String? brickSizeUnit,
    double? brickLength,
    double? brickWidth,
    double? brickHeight,
    WallInputMode? wallInputMode,
    String? wallHeightUnit,
    int? totalBricks,
    double? totalCost,
    double? wallHeightFt,
    int? computedLayers,
    bool clearResult = false,
  }) =>
      BrickState(
        plotLengthUnit: plotLengthUnit ?? this.plotLengthUnit,
        brickSizeUnit: brickSizeUnit ?? this.brickSizeUnit,
        brickLength: brickLength ?? this.brickLength,
        brickWidth: brickWidth ?? this.brickWidth,
        brickHeight: brickHeight ?? this.brickHeight,
        wallInputMode: wallInputMode ?? this.wallInputMode,
        wallHeightUnit: wallHeightUnit ?? this.wallHeightUnit,
        totalBricks: clearResult ? null : (totalBricks ?? this.totalBricks),
        totalCost: clearResult ? null : (totalCost ?? this.totalCost),
        wallHeightFt: clearResult ? null : (wallHeightFt ?? this.wallHeightFt),
        computedLayers: clearResult ? null : (computedLayers ?? this.computedLayers),
      );
}

class BrickNotifier extends StateNotifier<BrickState> {
  BrickNotifier() : super(const BrickState());

  void setPlotLengthUnit(String u) => state = state.copyWith(plotLengthUnit: u, clearResult: true);
  void setBrickSizeUnit(String u) => state = state.copyWith(brickSizeUnit: u, clearResult: true);
  void setBrickLength(double v) => state = state.copyWith(brickLength: v, clearResult: true);
  void setBrickWidth(double v) => state = state.copyWith(brickWidth: v, clearResult: true);
  void setBrickHeight(double v) => state = state.copyWith(brickHeight: v, clearResult: true);
  void setWallInputMode(WallInputMode m) => state = state.copyWith(wallInputMode: m, clearResult: true);
  void setWallHeightUnit(String u) => state = state.copyWith(wallHeightUnit: u, clearResult: true);

  void _compute(double lFt, double bFt, int layers, double? costPer1000) {
    final brickLengthFt = state.brickLength * brickSizeUnitToFeet[state.brickSizeUnit]!;
    final brickHeightFt = state.brickHeight * brickSizeUnitToFeet[state.brickSizeUnit]!;

    final bricksPerLayer =
        ((lFt / brickLengthFt).ceil() * 2 + (bFt / brickLengthFt).ceil() * 2) * 2;
    final total = bricksPerLayer * layers;
    final wallHeight = layers * brickHeightFt;

    double? cost;
    if (costPer1000 != null && costPer1000 > 0) {
      cost = (total / 1000) * costPer1000;
    }

    state = state.copyWith(
      totalBricks: total,
      totalCost: cost,
      wallHeightFt: wallHeight,
      computedLayers: layers,
    );
  }

  void calculateFromLayers({
    required double length,
    required double breadth,
    required int layers,
    double? costPer1000,
  }) {
    final lFt = length * lengthToFeet[state.plotLengthUnit]!;
    final bFt = breadth * lengthToFeet[state.plotLengthUnit]!;
    _compute(lFt, bFt, layers, costPer1000);
  }

  void calculateFromHeight({
    required double length,
    required double breadth,
    required double wallHeight,
    double? costPer1000,
  }) {
    final lFt = length * lengthToFeet[state.plotLengthUnit]!;
    final bFt = breadth * lengthToFeet[state.plotLengthUnit]!;
    final wallHeightFt = wallHeight * wallHeightUnitToFeet[state.wallHeightUnit]!;
    final brickHeightFt = state.brickHeight * brickSizeUnitToFeet[state.brickSizeUnit]!;
    final layers = (wallHeightFt / brickHeightFt).ceil();
    _compute(lFt, bFt, layers, costPer1000);
  }

  void clear() => state = BrickState(
        plotLengthUnit: state.plotLengthUnit,
        brickSizeUnit: state.brickSizeUnit,
        brickLength: state.brickLength,
        brickWidth: state.brickWidth,
        brickHeight: state.brickHeight,
        wallInputMode: state.wallInputMode,
        wallHeightUnit: state.wallHeightUnit,
      );
}

final brickProvider = StateNotifierProvider<BrickNotifier, BrickState>(
  (ref) => BrickNotifier(),
);

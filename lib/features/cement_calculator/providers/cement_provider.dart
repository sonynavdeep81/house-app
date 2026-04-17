import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../converter/data/conversion_data.dart';
import '../../brick_calculator/providers/brick_provider.dart';

class CementState {
  final String plotLengthUnit;
  final String brickSizeUnit;
  final double brickLength;
  final double brickWidth;
  final double brickHeight;
  final WallInputMode wallInputMode;
  final String wallHeightUnit;
  final int mortarRatio;
  final double bagWeightKg;
  final int? cementBags;
  final double? sandCft;
  final double? cementCost;
  final double? sandCost;
  final double? wallHeightFt;
  final int? computedLayers;

  const CementState({
    this.plotLengthUnit = 'Feet',
    this.brickSizeUnit = 'in',
    this.brickLength = 9.0,
    this.brickWidth = 4.0,
    this.brickHeight = 4.0,
    this.wallInputMode = WallInputMode.layers,
    this.wallHeightUnit = 'Feet',
    this.mortarRatio = 6,
    this.bagWeightKg = 50.0,
    this.cementBags,
    this.sandCft,
    this.cementCost,
    this.sandCost,
    this.wallHeightFt,
    this.computedLayers,
  });

  CementState copyWith({
    String? plotLengthUnit,
    String? brickSizeUnit,
    double? brickLength,
    double? brickWidth,
    double? brickHeight,
    WallInputMode? wallInputMode,
    String? wallHeightUnit,
    int? mortarRatio,
    double? bagWeightKg,
    int? cementBags,
    double? sandCft,
    double? cementCost,
    double? sandCost,
    double? wallHeightFt,
    int? computedLayers,
    bool clearResult = false,
  }) =>
      CementState(
        plotLengthUnit: plotLengthUnit ?? this.plotLengthUnit,
        brickSizeUnit: brickSizeUnit ?? this.brickSizeUnit,
        brickLength: brickLength ?? this.brickLength,
        brickWidth: brickWidth ?? this.brickWidth,
        brickHeight: brickHeight ?? this.brickHeight,
        wallInputMode: wallInputMode ?? this.wallInputMode,
        wallHeightUnit: wallHeightUnit ?? this.wallHeightUnit,
        mortarRatio: mortarRatio ?? this.mortarRatio,
        bagWeightKg: bagWeightKg ?? this.bagWeightKg,
        cementBags: clearResult ? null : (cementBags ?? this.cementBags),
        sandCft: clearResult ? null : (sandCft ?? this.sandCft),
        cementCost: clearResult ? null : (cementCost ?? this.cementCost),
        sandCost: clearResult ? null : (sandCost ?? this.sandCost),
        wallHeightFt: clearResult ? null : (wallHeightFt ?? this.wallHeightFt),
        computedLayers: clearResult ? null : (computedLayers ?? this.computedLayers),
      );
}

class CementNotifier extends StateNotifier<CementState> {
  CementNotifier() : super(const CementState());

  void setPlotLengthUnit(String u) => state = state.copyWith(plotLengthUnit: u, clearResult: true);
  void setBrickSizeUnit(String u) => state = state.copyWith(brickSizeUnit: u, clearResult: true);
  void setBrickLength(double v) => state = state.copyWith(brickLength: v, clearResult: true);
  void setBrickWidth(double v) => state = state.copyWith(brickWidth: v, clearResult: true);
  void setBrickHeight(double v) => state = state.copyWith(brickHeight: v, clearResult: true);
  void setWallInputMode(WallInputMode m) => state = state.copyWith(wallInputMode: m, clearResult: true);
  void setWallHeightUnit(String u) => state = state.copyWith(wallHeightUnit: u, clearResult: true);
  void setMortarRatio(int r) => state = state.copyWith(mortarRatio: r, clearResult: true);
  void setBagWeight(double v) => state = state.copyWith(bagWeightKg: v, clearResult: true);

  void _compute(double lFt, double bFt, int layers, double? cementCostPerBag, double? sandCostPerCft) {
    final bLFt = state.brickLength * brickSizeUnitToFeet[state.brickSizeUnit]!;
    final bWFt = state.brickWidth * brickSizeUnitToFeet[state.brickSizeUnit]!;
    final bHFt = state.brickHeight * brickSizeUnitToFeet[state.brickSizeUnit]!;

    final wallHeightFt = layers * bHFt;

    // Bricks per layer: same formula as brick calculator
    final bricksPerLayer = ((lFt / bLFt).ceil() * 2 + (bFt / bLFt).ceil() * 2) * 2;
    final numBricks = bricksPerLayer * layers;

    // Wall thickness = brick length (9 in) — two bricks placed width-to-width with mortar = 9 in total
    final wallThicknessFt = bLFt;
    final perimeter = 2 * (lFt + bFt);
    final wallVolumeCft = perimeter * wallHeightFt * wallThicknessFt;
    final brickVolumeCft = numBricks * bLFt * bWFt * bHFt;

    final mortarWet = (wallVolumeCft - brickVolumeCft) * 1.20; // +20% wastage
    final mortarDry = mortarWet * 1.33; // dry volume factor
    final N = state.mortarRatio;
    final cementCft = mortarDry / (1 + N);
    final sandCft = mortarDry * N / (1 + N);

    // kg ÷ 40 = cft  (50 kg bag = 1.25 cft)
    final cftPerBag = state.bagWeightKg / 40.0;
    final cementBags = (cementCft / cftPerBag).ceil();

    final cc = (cementCostPerBag != null && cementCostPerBag > 0) ? cementBags * cementCostPerBag : null;
    final sc = (sandCostPerCft != null && sandCostPerCft > 0) ? sandCft * sandCostPerCft : null;

    state = state.copyWith(
      cementBags: cementBags,
      sandCft: sandCft,
      cementCost: cc,
      sandCost: sc,
      wallHeightFt: wallHeightFt,
      computedLayers: layers,
    );
  }

  void calculateFromLayers({
    required double length,
    required double breadth,
    required int layers,
    double? cementCost,
    double? sandCost,
  }) {
    final lFt = length * lengthToFeet[state.plotLengthUnit]!;
    final bFt = breadth * lengthToFeet[state.plotLengthUnit]!;
    _compute(lFt, bFt, layers, cementCost, sandCost);
  }

  void calculateFromHeight({
    required double length,
    required double breadth,
    required double wallHeight,
    double? cementCost,
    double? sandCost,
  }) {
    final lFt = length * lengthToFeet[state.plotLengthUnit]!;
    final bFt = breadth * lengthToFeet[state.plotLengthUnit]!;
    final wHFt = wallHeight * wallHeightUnitToFeet[state.wallHeightUnit]!;
    final bHFt = state.brickHeight * brickSizeUnitToFeet[state.brickSizeUnit]!;
    final layers = (wHFt / bHFt).ceil();
    _compute(lFt, bFt, layers, cementCost, sandCost);
  }

  void clear() => state = CementState(
        plotLengthUnit: state.plotLengthUnit,
        brickSizeUnit: state.brickSizeUnit,
        brickLength: state.brickLength,
        brickWidth: state.brickWidth,
        brickHeight: state.brickHeight,
        wallInputMode: state.wallInputMode,
        wallHeightUnit: state.wallHeightUnit,
        mortarRatio: state.mortarRatio,
        bagWeightKg: state.bagWeightKg,
      );
}

final cementProvider = StateNotifierProvider<CementNotifier, CementState>(
  (ref) => CementNotifier(),
);

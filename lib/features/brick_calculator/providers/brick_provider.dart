import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../converter/data/conversion_data.dart';

// Brick size unit → conversion factor to feet
const Map<String, double> brickSizeUnitToFeet = {
  'in': 1 / 12.0,
  'cm': 1 / 30.48,
  'mm': 1 / 304.8,
};

class BrickState {
  final String plotLengthUnit;
  final String brickSizeUnit;
  final double brickLength;
  final double brickWidth;
  final double brickHeight;
  final int? totalBricks;
  final double? totalCost;
  final double? wallHeightFt;

  const BrickState({
    this.plotLengthUnit = 'Feet',
    this.brickSizeUnit = 'in',
    this.brickLength = 9.0,
    this.brickWidth = 4.0,
    this.brickHeight = 4.0,
    this.totalBricks,
    this.totalCost,
    this.wallHeightFt,
  });

  BrickState copyWith({
    String? plotLengthUnit,
    String? brickSizeUnit,
    double? brickLength,
    double? brickWidth,
    double? brickHeight,
    int? totalBricks,
    double? totalCost,
    double? wallHeightFt,
    bool clearResult = false,
  }) =>
      BrickState(
        plotLengthUnit: plotLengthUnit ?? this.plotLengthUnit,
        brickSizeUnit: brickSizeUnit ?? this.brickSizeUnit,
        brickLength: brickLength ?? this.brickLength,
        brickWidth: brickWidth ?? this.brickWidth,
        brickHeight: brickHeight ?? this.brickHeight,
        totalBricks: clearResult ? null : (totalBricks ?? this.totalBricks),
        totalCost: clearResult ? null : (totalCost ?? this.totalCost),
        wallHeightFt: clearResult ? null : (wallHeightFt ?? this.wallHeightFt),
      );
}

class BrickNotifier extends StateNotifier<BrickState> {
  BrickNotifier() : super(const BrickState());

  void setPlotLengthUnit(String u) => state = state.copyWith(plotLengthUnit: u, clearResult: true);
  void setBrickSizeUnit(String u) => state = state.copyWith(brickSizeUnit: u, clearResult: true);
  void setBrickLength(double v) => state = state.copyWith(brickLength: v, clearResult: true);
  void setBrickWidth(double v) => state = state.copyWith(brickWidth: v, clearResult: true);
  void setBrickHeight(double v) => state = state.copyWith(brickHeight: v, clearResult: true);

  void calculate({
    required double length,
    required double breadth,
    required int layers,
    double? costPer1000,
  }) {
    final toFt = brickSizeUnitToFeet[state.brickSizeUnit]!;
    final lFt = length * lengthToFeet[state.plotLengthUnit]!;
    final bFt = breadth * lengthToFeet[state.plotLengthUnit]!;

    final brickLengthFt = state.brickLength * toFt;
    final brickHeightFt = state.brickHeight * toFt;

    final bricksPerLengthWall = (lFt / brickLengthFt).ceil() * 2;
    final bricksPerBreadthWall = (bFt / brickLengthFt).ceil() * 2;
    final bricksPerLayer = (bricksPerLengthWall + bricksPerBreadthWall) * 2;
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
    );
  }

  void clear() => state = BrickState(
        plotLengthUnit: state.plotLengthUnit,
        brickSizeUnit: state.brickSizeUnit,
        brickLength: state.brickLength,
        brickWidth: state.brickWidth,
        brickHeight: state.brickHeight,
      );
}

final brickProvider = StateNotifierProvider<BrickNotifier, BrickState>(
  (ref) => BrickNotifier(),
);

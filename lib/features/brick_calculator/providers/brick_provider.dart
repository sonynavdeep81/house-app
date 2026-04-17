import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../converter/data/conversion_data.dart';

class BrickState {
  final String lengthUnit;
  final String breadthUnit;
  final double brickLengthIn;
  final double brickWidthIn;
  final double brickHeightIn;
  final int? totalBricks;
  final double? totalCost;
  final double? wallHeightFt;

  const BrickState({
    this.lengthUnit = 'Feet',
    this.breadthUnit = 'Feet',
    this.brickLengthIn = 9.0,
    this.brickWidthIn = 4.0,
    this.brickHeightIn = 4.0,
    this.totalBricks,
    this.totalCost,
    this.wallHeightFt,
  });

  BrickState copyWith({
    String? lengthUnit,
    String? breadthUnit,
    double? brickLengthIn,
    double? brickWidthIn,
    double? brickHeightIn,
    int? totalBricks,
    double? totalCost,
    double? wallHeightFt,
    bool clearResult = false,
  }) =>
      BrickState(
        lengthUnit: lengthUnit ?? this.lengthUnit,
        breadthUnit: breadthUnit ?? this.breadthUnit,
        brickLengthIn: brickLengthIn ?? this.brickLengthIn,
        brickWidthIn: brickWidthIn ?? this.brickWidthIn,
        brickHeightIn: brickHeightIn ?? this.brickHeightIn,
        totalBricks: clearResult ? null : (totalBricks ?? this.totalBricks),
        totalCost: clearResult ? null : (totalCost ?? this.totalCost),
        wallHeightFt: clearResult ? null : (wallHeightFt ?? this.wallHeightFt),
      );
}

class BrickNotifier extends StateNotifier<BrickState> {
  BrickNotifier() : super(const BrickState());

  void setLengthUnit(String u) => state = state.copyWith(lengthUnit: u, clearResult: true);
  void setBreadthUnit(String u) => state = state.copyWith(breadthUnit: u, clearResult: true);
  void setBrickLength(double v) => state = state.copyWith(brickLengthIn: v, clearResult: true);
  void setBrickWidth(double v) => state = state.copyWith(brickWidthIn: v, clearResult: true);
  void setBrickHeight(double v) => state = state.copyWith(brickHeightIn: v, clearResult: true);

  void calculate({
    required double length,
    required double breadth,
    required int layers,
    double? costPer1000,
  }) {
    final lFt = length * lengthToFeet[state.lengthUnit]!;
    final bFt = breadth * lengthToFeet[state.breadthUnit]!;

    final brickLengthFt = state.brickLengthIn / 12.0;
    final brickHeightFt = state.brickHeightIn / 12.0;

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
        lengthUnit: state.lengthUnit,
        breadthUnit: state.breadthUnit,
        brickLengthIn: state.brickLengthIn,
        brickWidthIn: state.brickWidthIn,
        brickHeightIn: state.brickHeightIn,
      );
}

final brickProvider = StateNotifierProvider<BrickNotifier, BrickState>(
  (ref) => BrickNotifier(),
);

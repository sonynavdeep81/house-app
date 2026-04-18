import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../converter/data/conversion_data.dart';
import '../../brick_calculator/providers/brick_provider.dart';

class CostResult {
  final int totalBricks;
  final int cementBags;
  final double sandCft;
  final double? brickCost;
  final double? cementCost;
  final double? sandCost;
  final double laborCost;
  final double wallHeightFt;
  final int computedLayers;

  const CostResult({
    required this.totalBricks,
    required this.cementBags,
    required this.sandCft,
    required this.laborCost,
    required this.wallHeightFt,
    required this.computedLayers,
    this.brickCost,
    this.cementCost,
    this.sandCost,
  });

  double get totalMaterialCost => (brickCost ?? 0) + (cementCost ?? 0) + (sandCost ?? 0);
  double get grandTotal => totalMaterialCost + laborCost;
}

class CostNotifier extends StateNotifier<CostResult?> {
  CostNotifier() : super(null);

  void calculate({
    required double length,
    required double breadth,
    required String plotLengthUnit,
    required int layers,
    required double brickLength,
    required double brickWidth,
    required double brickHeight,
    required String brickSizeUnit,
    required int mortarRatio,
    required double bagWeightKg,
    required double masonDayRate,
    required double laborerDayRate,
    required List<({int masons, int laborers})> workDays,
    double? costPer1000Bricks,
    double? costPerCementBag,
    double? costPerSandCft,
  }) {
    final lFt = length * lengthToFeet[plotLengthUnit]!;
    final bFt = breadth * lengthToFeet[plotLengthUnit]!;
    final bLFt = brickLength * brickSizeUnitToFeet[brickSizeUnit]!;
    final bWFt = brickWidth * brickSizeUnitToFeet[brickSizeUnit]!;
    final bHFt = brickHeight * brickSizeUnitToFeet[brickSizeUnit]!;

    // Bricks
    final bricksPerLayer = ((lFt / bLFt).ceil() * 2 + (bFt / bLFt).ceil() * 2) * 2;
    final totalBricks = bricksPerLayer * layers;
    final wallHeightFt = layers * bHFt;

    // Cement & sand (wall-volume minus brick-volume)
    final perimeter = 2 * (lFt + bFt);
    final wallVolume = perimeter * wallHeightFt * bLFt; // wall thickness = brick length
    final brickVolume = totalBricks * bLFt * bWFt * bHFt;
    final mortarDry = (wallVolume - brickVolume) * 1.20 * 1.33;
    final N = mortarRatio;
    final cementCft = mortarDry / (1 + N);
    final sandCft = mortarDry * N / (1 + N);
    final cftPerBag = bagWeightKg / 40.0;
    final cementBags = (cementCft / cftPerBag).ceil();

    // Material costs
    final bc = (costPer1000Bricks != null && costPer1000Bricks > 0)
        ? (totalBricks / 1000) * costPer1000Bricks : null;
    final cc = (costPerCementBag != null && costPerCementBag > 0)
        ? cementBags * costPerCementBag : null;
    final sc = (costPerSandCft != null && costPerSandCft > 0)
        ? sandCft * costPerSandCft : null;

    // Labor cost
    final laborCost = workDays.fold<double>(0, (sum, day) =>
        sum + day.masons * masonDayRate + day.laborers * laborerDayRate);

    state = CostResult(
      totalBricks: totalBricks,
      cementBags: cementBags,
      sandCft: sandCft,
      brickCost: bc,
      cementCost: cc,
      sandCost: sc,
      laborCost: laborCost,
      wallHeightFt: wallHeightFt,
      computedLayers: layers,
    );
  }

  void clear() => state = null;
}

final costProvider = StateNotifierProvider<CostNotifier, CostResult?>(
  (ref) => CostNotifier(),
);

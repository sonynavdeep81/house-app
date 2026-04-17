// All area units anchored to sq ft as base (Punjab/Haryana standard)
const Map<String, double> areaToSqFt = {
  'Sq Ft': 1.0,
  'Sq Meter': 10.7639,
  'Gaj (Sq Yard)': 9.0,
  'Biswansi': 27.225,
  'Marla': 272.25,
  'Biswa': 544.5,
  'Kanal': 5445.0,
  'Bigha': 10890.0,
  'Acre': 43560.0,
  'Murabba': 1089000.0,
};

// Length units anchored to feet as base
const Map<String, double> lengthToFeet = {
  'Feet': 1.0,
  'Meters': 3.28084,
  'Gaj (Yard)': 3.0,
  'Karam': 5.5,
};

double convertArea(double value, String from, String to) {
  final inSqFt = value * areaToSqFt[from]!;
  return inSqFt / areaToSqFt[to]!;
}

double lengthBreadthToArea(
  double length, String lengthUnit,
  double breadth, String breadthUnit,
  String outputUnit,
) {
  final lengthInFt = length * lengthToFeet[lengthUnit]!;
  final breadthInFt = breadth * lengthToFeet[breadthUnit]!;
  final areaInSqFt = lengthInFt * breadthInFt;
  return areaInSqFt / areaToSqFt[outputUnit]!;
}

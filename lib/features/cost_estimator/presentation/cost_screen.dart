import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../converter/data/conversion_data.dart';
import '../../brick_calculator/providers/brick_provider.dart';
import '../providers/cost_provider.dart';

class _WorkDayRow {
  final TextEditingController masons;
  final TextEditingController laborers;
  _WorkDayRow()
      : masons = TextEditingController(text: '0'),
        laborers = TextEditingController(text: '0');
  void dispose() {
    masons.dispose();
    laborers.dispose();
  }
}

class CostScreen extends ConsumerStatefulWidget {
  const CostScreen({super.key});

  @override
  ConsumerState<CostScreen> createState() => _CostScreenState();
}

class _CostScreenState extends ConsumerState<CostScreen> {
  final _formKey = GlobalKey<FormState>();

  // Brick size
  final _brickLCtrl = TextEditingController(text: '9');
  final _brickWCtrl = TextEditingController(text: '4');
  final _brickHCtrl = TextEditingController(text: '4');
  String _brickSizeUnit = 'in';

  // Plot
  final _lengthCtrl = TextEditingController();
  final _breadthCtrl = TextEditingController();
  String _plotLengthUnit = 'Feet';

  // Wall
  WallInputMode _wallInputMode = WallInputMode.layers;
  final _layersCtrl = TextEditingController();
  final _wallHeightCtrl = TextEditingController();
  String _wallHeightUnit = 'Feet';

  // Mortar & bag
  int _mortarRatio = 6;
  final _bagWeightCtrl = TextEditingController(text: '50');

  // Material costs
  final _brickCostCtrl = TextEditingController();
  final _cementCostCtrl = TextEditingController();
  final _sandCostCtrl = TextEditingController();

  // Labor rates
  final _masonRateCtrl = TextEditingController();
  final _laborerRateCtrl = TextEditingController();

  // Work days (dynamic)
  final List<_WorkDayRow> _workDays = [_WorkDayRow()];

  @override
  void dispose() {
    _brickLCtrl.dispose(); _brickWCtrl.dispose(); _brickHCtrl.dispose();
    _lengthCtrl.dispose(); _breadthCtrl.dispose();
    _layersCtrl.dispose(); _wallHeightCtrl.dispose();
    _bagWeightCtrl.dispose();
    _brickCostCtrl.dispose(); _cementCostCtrl.dispose(); _sandCostCtrl.dispose();
    _masonRateCtrl.dispose(); _laborerRateCtrl.dispose();
    for (final r in _workDays) r.dispose();
    super.dispose();
  }

  void _addDay() => setState(() => _workDays.add(_WorkDayRow()));

  void _removeDay(int index) {
    if (_workDays.length == 1) return;
    setState(() {
      _workDays[index].dispose();
      _workDays.removeAt(index);
    });
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final layers = _wallInputMode == WallInputMode.layers
        ? int.parse(_layersCtrl.text)
        : () {
            final wHFt = double.parse(_wallHeightCtrl.text) *
                wallHeightUnitToFeet[_wallHeightUnit]!;
            final bHFt = double.parse(_brickHCtrl.text) *
                brickSizeUnitToFeet[_brickSizeUnit]!;
            return (wHFt / bHFt).ceil();
          }();

    final workDays = _workDays.map((r) => (
          masons: int.tryParse(r.masons.text) ?? 0,
          laborers: int.tryParse(r.laborers.text) ?? 0,
        )).toList();

    ref.read(costProvider.notifier).calculate(
      length: double.parse(_lengthCtrl.text),
      breadth: double.parse(_breadthCtrl.text),
      plotLengthUnit: _plotLengthUnit,
      layers: layers,
      brickLength: double.parse(_brickLCtrl.text),
      brickWidth: double.parse(_brickWCtrl.text),
      brickHeight: double.parse(_brickHCtrl.text),
      brickSizeUnit: _brickSizeUnit,
      mortarRatio: _mortarRatio,
      bagWeightKg: double.parse(_bagWeightCtrl.text),
      masonDayRate: double.tryParse(_masonRateCtrl.text) ?? 0,
      laborerDayRate: double.tryParse(_laborerRateCtrl.text) ?? 0,
      workDays: workDays,
      costPer1000Bricks: double.tryParse(_brickCostCtrl.text),
      costPerCementBag: double.tryParse(_cementCostCtrl.text),
      costPerSandCft: double.tryParse(_sandCostCtrl.text),
    );
  }

  void _clear() {
    _brickLCtrl.text = '9'; _brickWCtrl.text = '4'; _brickHCtrl.text = '4';
    _lengthCtrl.clear(); _breadthCtrl.clear();
    _layersCtrl.clear(); _wallHeightCtrl.clear();
    _bagWeightCtrl.text = '50';
    _brickCostCtrl.clear(); _cementCostCtrl.clear(); _sandCostCtrl.clear();
    _masonRateCtrl.clear(); _laborerRateCtrl.clear();
    for (final r in _workDays) r.dispose();
    setState(() {
      _workDays.clear();
      _workDays.add(_WorkDayRow());
    });
    ref.read(costProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(costProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ਖਰਚਾ ਅੰਦਾਜ਼ਾ / Cost Estimator'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Brick Size
              _sectionLabel(context, 'Brick Size'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _brickSizeUnit,
                decoration: const InputDecoration(
                  labelText: 'Unit (for all brick dimensions)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: brickSizeUnitToFeet.keys
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() => _brickSizeUnit = v!),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _DimField(controller: _brickLCtrl, label: 'Length')),
                const SizedBox(width: 8),
                Expanded(child: _DimField(controller: _brickWCtrl, label: 'Width')),
                const SizedBox(width: 8),
                Expanded(child: _DimField(controller: _brickHCtrl, label: 'Height')),
              ]),
              const SizedBox(height: 16),

              // Plot Dimensions
              _sectionLabel(context, 'Plot Dimensions'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _plotLengthUnit,
                decoration: const InputDecoration(
                  labelText: 'Unit (for both dimensions)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: lengthToFeet.keys
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() => _plotLengthUnit = v!),
              ),
              const SizedBox(height: 12),
              _NumField(controller: _lengthCtrl, label: 'Length', hint: 'e.g. 60'),
              const SizedBox(height: 12),
              _NumField(controller: _breadthCtrl, label: 'Breadth', hint: 'e.g. 30'),
              const SizedBox(height: 16),

              // Wall Details
              _sectionLabel(context, 'Wall Details'),
              const SizedBox(height: 8),
              SegmentedButton<WallInputMode>(
                segments: const [
                  ButtonSegment(value: WallInputMode.layers, label: Text('No. of Layers'), icon: Icon(Icons.layers)),
                  ButtonSegment(value: WallInputMode.height, label: Text('Wall Height'), icon: Icon(Icons.height)),
                ],
                selected: {_wallInputMode},
                onSelectionChanged: (s) => setState(() {
                  _wallInputMode = s.first;
                  _layersCtrl.clear(); _wallHeightCtrl.clear();
                }),
              ),
              const SizedBox(height: 12),
              if (_wallInputMode == WallInputMode.layers)
                _NumField(controller: _layersCtrl, label: 'Number of Layers', hint: 'e.g. 10', isInt: true)
              else ...[
                DropdownButtonFormField<String>(
                  value: _wallHeightUnit,
                  decoration: const InputDecoration(
                    labelText: 'Wall Height Unit',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: wallHeightUnitToFeet.keys
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => setState(() => _wallHeightUnit = v!),
                ),
                const SizedBox(height: 12),
                _NumField(controller: _wallHeightCtrl, label: 'Desired Wall Height', hint: 'e.g. 10'),
              ],
              const SizedBox(height: 16),

              // Mortar
              _sectionLabel(context, 'Mortar Mix Ratio (Cement : Sand)'),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 3, label: Text('1:3\nStrong'), icon: Icon(Icons.looks_3)),
                  ButtonSegment(value: 4, label: Text('1:4\nStandard'), icon: Icon(Icons.looks_4)),
                  ButtonSegment(value: 6, label: Text('1:6\nLean'), icon: Icon(Icons.looks_6)),
                ],
                selected: {_mortarRatio},
                onSelectionChanged: (s) => setState(() => _mortarRatio = s.first),
              ),
              const SizedBox(height: 12),
              _NumField(
                controller: _bagWeightCtrl,
                label: 'Cement Bag Weight (kg)',
                hint: 'e.g. 50',
                helperText: 'kg ÷ 40 = cft  (50 kg = 1.25 cft)',
              ),
              const SizedBox(height: 16),

              // Material Costs
              _sectionLabel(context, 'Material Costs (optional)'),
              const SizedBox(height: 8),
              _NumField(controller: _brickCostCtrl, label: 'Cost per 1000 Bricks (₹)', hint: 'e.g. 8000', required: false),
              const SizedBox(height: 12),
              _NumField(controller: _cementCostCtrl, label: 'Cost per Cement Bag (₹)', hint: 'e.g. 400', required: false),
              const SizedBox(height: 12),
              _NumField(controller: _sandCostCtrl, label: 'Cost per Cubic Foot of Sand (₹)', hint: 'e.g. 50', required: false),
              const SizedBox(height: 16),

              // Labor Rates
              _sectionLabel(context, 'Labor Rates (₹ per day)'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _NumField(controller: _masonRateCtrl, label: 'Mason', hint: 'e.g. 800', required: false)),
                const SizedBox(width: 12),
                Expanded(child: _NumField(controller: _laborerRateCtrl, label: 'Laborer', hint: 'e.g. 500', required: false)),
              ]),
              const SizedBox(height: 16),

              // Work Days
              _sectionLabel(context, 'Work Days'),
              const SizedBox(height: 8),
              ...List.generate(_workDays.length, (i) => _WorkDayRowWidget(
                index: i,
                row: _workDays[i],
                canRemove: _workDays.length > 1,
                onRemove: () => _removeDay(i),
              )),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _addDay,
                icon: const Icon(Icons.add),
                label: const Text('Add Day'),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: _clear, child: const Text('Clear')),

              if (result != null) ...[
                const SizedBox(height: 24),
                _ResultCard(result: result),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      );
}

class _WorkDayRowWidget extends StatelessWidget {
  final int index;
  final _WorkDayRow row;
  final bool canRemove;
  final VoidCallback onRemove;

  const _WorkDayRowWidget({
    required this.index,
    required this.row,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text('Day ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: _IntField(controller: row.masons, label: 'Masons')),
          const SizedBox(width: 8),
          Expanded(child: _IntField(controller: row.laborers, label: 'Laborers')),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: canRemove ? onRemove : null,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

class _IntField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _IntField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Req';
        if (int.tryParse(v) == null || int.parse(v) < 0) return 'Invalid';
        return null;
      },
    );
  }
}

class _DimField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _DimField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Req';
        final n = double.tryParse(v);
        if (n == null || n <= 0) return 'Invalid';
        return null;
      },
    );
  }
}

class _NumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isInt;
  final bool required;
  final String? helperText;

  const _NumField({
    required this.controller,
    required this.label,
    required this.hint,
    this.isInt = false,
    this.required = true,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: isInt ? TextInputType.number : const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (!required && (v == null || v.isEmpty)) return null;
        if (required && (v == null || v.isEmpty)) return 'Required';
        if (isInt) {
          final n = int.tryParse(v!);
          if (n == null || n <= 0) return 'Enter a whole number > 0';
        } else {
          final n = double.tryParse(v!);
          if (n == null || n <= 0) return 'Enter a number > 0';
        }
        return null;
      },
    );
  }
}

class _ResultCard extends StatelessWidget {
  final CostResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionHead(context, 'Materials Required'),
            const SizedBox(height: 12),
            _row(context, 'Bricks', _fmtInt(result.totalBricks),
                sub: result.brickCost != null ? '₹ ${_fmtCost(result.brickCost!)}' : null),
            _row(context, 'Cement', '${result.cementBags} bags',
                sub: result.cementCost != null ? '₹ ${_fmtCost(result.cementCost!)}' : null),
            _row(context, 'Sand', '${result.sandCft.toStringAsFixed(1)} cft',
                sub: result.sandCost != null ? '₹ ${_fmtCost(result.sandCost!)}' : null),
            if (result.totalMaterialCost > 0) ...[
              const Divider(height: 20),
              _row(context, 'Total Material', '₹ ${_fmtCost(result.totalMaterialCost)}', bold: true),
            ],
            const Divider(height: 20),
            _sectionHead(context, 'Labor'),
            const SizedBox(height: 8),
            _row(context, 'Total Labor Cost', '₹ ${_fmtCost(result.laborCost)}', bold: true),
            if (result.totalMaterialCost > 0) ...[
              const Divider(height: 20),
              _row(context, 'Grand Total', '₹ ${_fmtCost(result.grandTotal)}',
                  bold: true, large: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionHead(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      );

  Widget _row(BuildContext context, String label, String value,
      {String? sub, bool bold = false, bool large = false}) {
    final theme = Theme.of(context);
    final style = large
        ? theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)
        : bold
            ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)
            : theme.textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: theme.textTheme.labelLarge),
            if (sub != null) Text(sub, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary)),
          ]),
          Text(value, style: style),
        ],
      ),
    );
  }

  String _fmtInt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write(',');
      buf.write(s[i]);
      c++;
    }
    return buf.toString().split('').reversed.join('');
  }

  String _fmtCost(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(2)} Lakh';
    return v.toStringAsFixed(2);
  }
}

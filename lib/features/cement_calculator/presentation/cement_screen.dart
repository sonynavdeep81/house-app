import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../converter/data/conversion_data.dart';
import '../../brick_calculator/providers/brick_provider.dart';
import '../providers/cement_provider.dart';

class CementScreen extends ConsumerStatefulWidget {
  const CementScreen({super.key});

  @override
  ConsumerState<CementScreen> createState() => _CementScreenState();
}

class _CementScreenState extends ConsumerState<CementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lengthCtrl = TextEditingController();
  final _breadthCtrl = TextEditingController();
  final _layersCtrl = TextEditingController();
  final _wallHeightCtrl = TextEditingController();
  final _cementCostCtrl = TextEditingController();
  final _sandCostCtrl = TextEditingController();
  final _brickLCtrl = TextEditingController(text: '9');
  final _brickWCtrl = TextEditingController(text: '4');
  final _brickHCtrl = TextEditingController(text: '4');
  final _bagWeightCtrl = TextEditingController(text: '50');

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _breadthCtrl.dispose();
    _layersCtrl.dispose();
    _wallHeightCtrl.dispose();
    _cementCostCtrl.dispose();
    _sandCostCtrl.dispose();
    _brickLCtrl.dispose();
    _brickWCtrl.dispose();
    _brickHCtrl.dispose();
    _bagWeightCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(cementProvider.notifier);
    notifier.setBrickLength(double.parse(_brickLCtrl.text));
    notifier.setBrickWidth(double.parse(_brickWCtrl.text));
    notifier.setBrickHeight(double.parse(_brickHCtrl.text));
    notifier.setBagWeight(double.parse(_bagWeightCtrl.text));
    final cc = _cementCostCtrl.text.isNotEmpty ? double.tryParse(_cementCostCtrl.text) : null;
    final sc = _sandCostCtrl.text.isNotEmpty ? double.tryParse(_sandCostCtrl.text) : null;
    final state = ref.read(cementProvider);

    if (state.wallInputMode == WallInputMode.layers) {
      notifier.calculateFromLayers(
        length: double.parse(_lengthCtrl.text),
        breadth: double.parse(_breadthCtrl.text),
        layers: int.parse(_layersCtrl.text),
        cementCost: cc,
        sandCost: sc,
      );
    } else {
      notifier.calculateFromHeight(
        length: double.parse(_lengthCtrl.text),
        breadth: double.parse(_breadthCtrl.text),
        wallHeight: double.parse(_wallHeightCtrl.text),
        cementCost: cc,
        sandCost: sc,
      );
    }
  }

  void _clear() {
    _lengthCtrl.clear();
    _breadthCtrl.clear();
    _layersCtrl.clear();
    _wallHeightCtrl.clear();
    _cementCostCtrl.clear();
    _sandCostCtrl.clear();
    _brickLCtrl.text = '9';
    _brickWCtrl.text = '4';
    _brickHCtrl.text = '4';
    _bagWeightCtrl.text = '50';
    ref.read(cementProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cementProvider);
    final notifier = ref.read(cementProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ਸੀਮਿੰਟ & ਰੇਤਾ / Cement & Sand'),
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
              _sectionLabel(context, 'Brick Size'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: state.brickSizeUnit,
                decoration: const InputDecoration(
                  labelText: 'Unit (for all brick dimensions)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: brickSizeUnitToFeet.keys
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) { notifier.setBrickSizeUnit(v!); notifier.clear(); },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _DimField(controller: _brickLCtrl, label: 'Length')),
                  const SizedBox(width: 8),
                  Expanded(child: _DimField(controller: _brickWCtrl, label: 'Width')),
                  const SizedBox(width: 8),
                  Expanded(child: _DimField(controller: _brickHCtrl, label: 'Height')),
                ],
              ),
              const SizedBox(height: 16),

              _sectionLabel(context, 'Plot Dimensions'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: state.plotLengthUnit,
                decoration: const InputDecoration(
                  labelText: 'Unit (for both dimensions)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: lengthToFeet.keys
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => notifier.setPlotLengthUnit(v!),
              ),
              const SizedBox(height: 12),
              _NumField(controller: _lengthCtrl, label: 'Length', hint: 'e.g. 60'),
              const SizedBox(height: 12),
              _NumField(controller: _breadthCtrl, label: 'Breadth', hint: 'e.g. 30'),
              const SizedBox(height: 16),

              _sectionLabel(context, 'Wall Details'),
              const SizedBox(height: 8),
              SegmentedButton<WallInputMode>(
                segments: const [
                  ButtonSegment(
                    value: WallInputMode.layers,
                    label: Text('No. of Layers'),
                    icon: Icon(Icons.layers),
                  ),
                  ButtonSegment(
                    value: WallInputMode.height,
                    label: Text('Wall Height'),
                    icon: Icon(Icons.height),
                  ),
                ],
                selected: {state.wallInputMode},
                onSelectionChanged: (s) {
                  notifier.setWallInputMode(s.first);
                  _layersCtrl.clear();
                  _wallHeightCtrl.clear();
                  notifier.clear();
                },
              ),
              const SizedBox(height: 12),
              if (state.wallInputMode == WallInputMode.layers)
                _NumField(
                  controller: _layersCtrl,
                  label: 'Number of Layers',
                  hint: 'e.g. 4',
                  isInt: true,
                )
              else ...[
                DropdownButtonFormField<String>(
                  value: state.wallHeightUnit,
                  decoration: const InputDecoration(
                    labelText: 'Wall Height Unit',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: wallHeightUnitToFeet.keys
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) { notifier.setWallHeightUnit(v!); notifier.clear(); },
                ),
                const SizedBox(height: 12),
                _NumField(
                  controller: _wallHeightCtrl,
                  label: 'Desired Wall Height',
                  hint: 'e.g. 10',
                ),
              ],
              const SizedBox(height: 16),

              _sectionLabel(context, 'Mortar Mix Ratio (Cement : Sand)'),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 3, label: Text('1:3\nStrong'), icon: Icon(Icons.looks_3)),
                  ButtonSegment(value: 4, label: Text('1:4\nStandard'), icon: Icon(Icons.looks_4)),
                  ButtonSegment(value: 6, label: Text('1:6\nLean'), icon: Icon(Icons.looks_6)),
                ],
                selected: {state.mortarRatio},
                onSelectionChanged: (s) => notifier.setMortarRatio(s.first),
              ),
              const SizedBox(height: 16),

              _sectionLabel(context, 'Cement Bag Weight'),
              const SizedBox(height: 8),
              _NumField(
                controller: _bagWeightCtrl,
                label: 'Bag Weight (kg)',
                hint: 'e.g. 50',
                helperText: 'kg ÷ 40 = cft  (50 kg = 1.25 cft)',
              ),
              const SizedBox(height: 16),

              _sectionLabel(context, 'Cost (optional)'),
              const SizedBox(height: 8),
              _NumField(
                controller: _cementCostCtrl,
                label: 'Cost per Cement Bag (₹)',
                hint: 'e.g. 400',
                required: false,
              ),
              const SizedBox(height: 12),
              _NumField(
                controller: _sandCostCtrl,
                label: 'Cost per Cubic Foot of Sand (₹)',
                hint: 'e.g. 50',
                required: false,
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

              if (state.cementBags != null) ...[
                const SizedBox(height: 24),
                _ResultCard(state: state),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      );
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
        if (v == null || v.isEmpty) return 'Required';
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
      keyboardType: isInt
          ? TextInputType.number
          : const TextInputType.numberWithOptions(decimal: true),
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
  final CementState state;
  const _ResultCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCost = (state.cementCost != null || state.sandCost != null)
        ? (state.cementCost ?? 0) + (state.sandCost ?? 0)
        : null;

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _row(context, 'Cement Required', '${state.cementBags} bags'),
            const Divider(height: 24),
            _row(context, 'Sand Required', '${state.sandCft!.toStringAsFixed(2)} cft'),
            if (state.cementCost != null) ...[
              const Divider(height: 24),
              _row(context, 'Cement Cost', '₹ ${_fmt(state.cementCost!)}'),
            ],
            if (state.sandCost != null) ...[
              const Divider(height: 24),
              _row(context, 'Sand Cost', '₹ ${_fmt(state.sandCost!)}'),
            ],
            if (totalCost != null) ...[
              const Divider(height: 24),
              _row(context, 'Total Cost', '₹ ${_fmt(totalCost)}', headline: true),
            ],
            const SizedBox(height: 8),
            Text(
              'Mortar ratio 1:${state.mortarRatio}  •  Includes 20% wastage',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value, {bool headline = false}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        Text(
          value,
          style: (headline ? theme.textTheme.headlineSmall : theme.textTheme.headlineSmall)
              ?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(2)} Lakh';
    return v.toStringAsFixed(2);
  }
}

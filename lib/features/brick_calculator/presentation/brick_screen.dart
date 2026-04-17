import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../converter/data/conversion_data.dart';
import '../providers/brick_provider.dart';

class BrickScreen extends ConsumerStatefulWidget {
  const BrickScreen({super.key});

  @override
  ConsumerState<BrickScreen> createState() => _BrickScreenState();
}

class _BrickScreenState extends ConsumerState<BrickScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lengthCtrl = TextEditingController();
  final _breadthCtrl = TextEditingController();
  final _layersCtrl = TextEditingController();
  final _wallHeightCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _brickLCtrl = TextEditingController(text: '9');
  final _brickWCtrl = TextEditingController(text: '4');
  final _brickHCtrl = TextEditingController(text: '4');

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _breadthCtrl.dispose();
    _layersCtrl.dispose();
    _wallHeightCtrl.dispose();
    _costCtrl.dispose();
    _brickLCtrl.dispose();
    _brickWCtrl.dispose();
    _brickHCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(brickProvider.notifier);
    notifier.setBrickLength(double.parse(_brickLCtrl.text));
    notifier.setBrickWidth(double.parse(_brickWCtrl.text));
    notifier.setBrickHeight(double.parse(_brickHCtrl.text));
    final cost = _costCtrl.text.isNotEmpty ? double.tryParse(_costCtrl.text) : null;
    final state = ref.read(brickProvider);

    if (state.wallInputMode == WallInputMode.layers) {
      notifier.calculateFromLayers(
        length: double.parse(_lengthCtrl.text),
        breadth: double.parse(_breadthCtrl.text),
        layers: int.parse(_layersCtrl.text),
        costPer1000: cost,
      );
    } else {
      notifier.calculateFromHeight(
        length: double.parse(_lengthCtrl.text),
        breadth: double.parse(_breadthCtrl.text),
        wallHeight: double.parse(_wallHeightCtrl.text),
        costPer1000: cost,
      );
    }
  }

  void _clear() {
    _lengthCtrl.clear();
    _breadthCtrl.clear();
    _layersCtrl.clear();
    _wallHeightCtrl.clear();
    _costCtrl.clear();
    _brickLCtrl.text = '9';
    _brickWCtrl.text = '4';
    _brickHCtrl.text = '4';
    ref.read(brickProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(brickProvider);
    final notifier = ref.read(brickProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ਇੱਟਾਂ ਕੈਲਕੁਲੇਟਰ / Brick Calculator'),
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

              // Plot Dimensions
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

              // Wall Details with mode toggle
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
              const SizedBox(height: 12),
              _NumField(
                controller: _costCtrl,
                label: 'Cost per 1000 Bricks (₹) — optional',
                hint: 'e.g. 8000',
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
              if (state.totalBricks != null) ...[
                const SizedBox(height: 24),
                _ResultCard(
                  totalBricks: state.totalBricks!,
                  totalCost: state.totalCost,
                  wallHeightFt: state.wallHeightFt!,
                  computedLayers: state.computedLayers!,
                  requestedHeightFt: state.wallInputMode == WallInputMode.height
                      ? _requestedHeightFt(state)
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double? _requestedHeightFt(BrickState state) {
    final v = double.tryParse(_wallHeightCtrl.text);
    if (v == null) return null;
    return v * wallHeightUnitToFeet[state.wallHeightUnit]!;
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

  const _NumField({
    required this.controller,
    required this.label,
    required this.hint,
    this.isInt = false,
    this.required = true,
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
  final int totalBricks;
  final double? totalCost;
  final double wallHeightFt;
  final int computedLayers;
  final double? requestedHeightFt;

  const _ResultCard({
    required this.totalBricks,
    required this.wallHeightFt,
    required this.computedLayers,
    this.totalCost,
    this.requestedHeightFt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Total Bricks Required', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(
              _fmt(totalBricks),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const Divider(height: 24),
            Text('Layers', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(
              '$computedLayers',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const Divider(height: 24),
            Text('Wall Height (achieved)', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(
              _fmtHeight(wallHeightFt),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            if (requestedHeightFt != null &&
                (wallHeightFt - requestedHeightFt!).abs() > 0.001) ...[
              const SizedBox(height: 4),
              Text(
                'Requested: ${_fmtHeight(requestedHeightFt!)}  •  Rounded up to fit full bricks',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (totalCost != null) ...[
              const Divider(height: 24),
              Text('Estimated Cost', style: theme.textTheme.labelLarge),
              const SizedBox(height: 6),
              Text(
                '₹ ${_fmtCost(totalCost!)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmtHeight(double ft) {
    final totalInches = (ft * 12).round();
    final f = totalInches ~/ 12;
    final i = totalInches % 12;
    return i == 0 ? '$f ft' : '$f ft $i in';
  }

  String _fmt(int n) {
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

  String _fmtCost(double cost) {
    if (cost >= 100000) return '${(cost / 100000).toStringAsFixed(2)} Lakh';
    return cost.toStringAsFixed(2);
  }
}

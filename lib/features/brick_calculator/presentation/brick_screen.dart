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
  final _costCtrl = TextEditingController();
  final _brickLCtrl = TextEditingController(text: '9');
  final _brickWCtrl = TextEditingController(text: '4');
  final _brickHCtrl = TextEditingController(text: '4');

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _breadthCtrl.dispose();
    _layersCtrl.dispose();
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
    notifier.calculate(
      length: double.parse(_lengthCtrl.text),
      breadth: double.parse(_breadthCtrl.text),
      layers: int.parse(_layersCtrl.text),
      costPer1000: _costCtrl.text.isNotEmpty ? double.tryParse(_costCtrl.text) : null,
    );
  }

  void _clear() {
    _lengthCtrl.clear();
    _breadthCtrl.clear();
    _layersCtrl.clear();
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
    final units = lengthToFeet.keys.toList();

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
              _sectionLabel(context, 'Brick Size (inches)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _InchField(controller: _brickLCtrl, label: 'Length')),
                  const SizedBox(width: 8),
                  Expanded(child: _InchField(controller: _brickWCtrl, label: 'Width')),
                  const SizedBox(width: 8),
                  Expanded(child: _InchField(controller: _brickHCtrl, label: 'Height')),
                ],
              ),
              const SizedBox(height: 16),
              _sectionLabel(context, 'Plot Dimensions'),
              const SizedBox(height: 8),
              _DimRow(
                label: 'Length',
                controller: _lengthCtrl,
                unit: state.lengthUnit,
                units: units,
                onUnitChanged: (v) => notifier.setLengthUnit(v!),
              ),
              const SizedBox(height: 12),
              _DimRow(
                label: 'Breadth',
                controller: _breadthCtrl,
                unit: state.breadthUnit,
                units: units,
                onUnitChanged: (v) => notifier.setBreadthUnit(v!),
              ),
              const SizedBox(height: 16),
              _sectionLabel(context, 'Wall Details'),
              const SizedBox(height: 8),
              _NumField(
                controller: _layersCtrl,
                label: 'Number of Layers',
                hint: 'e.g. 4',
                isInt: true,
              ),
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
                ),
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

class _InchField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _InchField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'in',
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

class _DimRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String unit;
  final List<String> units;
  final ValueChanged<String?> onUnitChanged;

  const _DimRow({
    required this.label,
    required this.controller,
    required this.unit,
    required this.units,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _NumField(controller: controller, label: label, hint: 'e.g. 60')),
        const SizedBox(width: 8),
        SizedBox(
          width: 140,
          child: DropdownButtonFormField<String>(
            value: unit,
            decoration: const InputDecoration(
              labelText: 'Unit',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
            onChanged: onUnitChanged,
          ),
        ),
      ],
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

  const _ResultCard({
    required this.totalBricks,
    required this.wallHeightFt,
    this.totalCost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalInches = (wallHeightFt * 12).round();
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    final heightStr = inches == 0 ? '$feet ft' : '$feet ft $inches in';

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
            Text('Wall Height', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(
              heightStr,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
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

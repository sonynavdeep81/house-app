import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/conversion_data.dart';
import '../providers/converter_provider.dart';

class ConverterScreen extends ConsumerStatefulWidget {
  const ConverterScreen({super.key});

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen> {
  final _valueCtrl = TextEditingController();
  final _lengthCtrl = TextEditingController();
  final _breadthCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _valueCtrl.dispose();
    _lengthCtrl.dispose();
    _breadthCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(converterProvider.notifier);
    final state = ref.read(converterProvider);
    if (state.mode == ConverterMode.area) {
      notifier.calculateArea(double.parse(_valueCtrl.text));
    } else {
      notifier.calculateFromLengthBreadth(
        double.parse(_lengthCtrl.text),
        double.parse(_breadthCtrl.text),
      );
    }
  }

  void _clear() {
    _valueCtrl.clear();
    _lengthCtrl.clear();
    _breadthCtrl.clear();
    ref.read(converterProvider.notifier).clearResult();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(converterProvider);
    final notifier = ref.read(converterProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ਜ਼ਮੀਨ ਮਾਪ / Land Converter'),
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
              _ModeToggle(
                mode: state.mode,
                onChanged: (m) {
                  notifier.setMode(m);
                  _clear();
                },
              ),
              const SizedBox(height: 20),
              if (state.mode == ConverterMode.area) ...[
                _UnitDropdown(
                  label: 'From Unit',
                  value: state.fromUnit,
                  items: areaToSqFt.keys.toList(),
                  onChanged: (v) {
                    notifier.setFromUnit(v!);
                    notifier.clearResult();
                  },
                ),
                const SizedBox(height: 12),
                _NumField(
                  controller: _valueCtrl,
                  label: 'Value',
                  hint: 'Enter area in ${state.fromUnit}',
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: _NumField(
                        controller: _lengthCtrl,
                        label: 'Length',
                        hint: 'e.g. 50',
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 140,
                      child: _UnitDropdown(
                        label: 'Unit',
                        value: state.lengthUnit,
                        items: lengthToFeet.keys.toList(),
                        onChanged: (v) {
                          notifier.setLengthUnit(v!);
                          notifier.clearResult();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _NumField(
                        controller: _breadthCtrl,
                        label: 'Breadth',
                        hint: 'e.g. 30',
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 140,
                      child: _UnitDropdown(
                        label: 'Unit',
                        value: state.breadthUnit,
                        items: lengthToFeet.keys.toList(),
                        onChanged: (v) {
                          notifier.setBreadthUnit(v!);
                          notifier.clearResult();
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              _UnitDropdown(
                label: 'To Unit (Result)',
                value: state.toUnit,
                items: areaToSqFt.keys.toList(),
                onChanged: (v) {
                  notifier.setToUnit(v!);
                  notifier.clearResult();
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('Convert'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: _clear, child: const Text('Clear')),
              if (state.result != null) ...[
                const SizedBox(height: 24),
                _ResultCard(
                  result: state.result!,
                  unit: state.toUnit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final ConverterMode mode;
  final ValueChanged<ConverterMode> onChanged;

  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ConverterMode>(
      segments: const [
        ButtonSegment(
          value: ConverterMode.area,
          label: Text('Area'),
          icon: Icon(Icons.crop_square),
        ),
        ButtonSegment(
          value: ConverterMode.lengthBreadth,
          label: Text('L × B'),
          icon: Icon(Icons.straighten),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _UnitDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _UnitDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items
          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _NumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const _NumField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        if (double.tryParse(v) == null) return 'Invalid number';
        if (double.parse(v) <= 0) return 'Must be > 0';
        return null;
      },
    );
  }
}

class _ResultCard extends StatelessWidget {
  final double result;
  final String unit;

  const _ResultCard({required this.result, required this.unit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Result', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(
              _format(result),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            Text(unit, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  String _format(double v) {
    if (v >= 1000) return v.toStringAsFixed(2);
    if (v >= 1) return v.toStringAsFixed(4);
    return v.toStringAsFixed(6);
  }
}

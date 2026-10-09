import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/data/repositories/parameter_repository.dart';
import 'package:fuselage_kpp/features/params/param_rules.dart';
import 'package:fuselage_kpp/features/params/param_write.dart';

/// One editable parameter row: label, live value, editor and help text.
///
/// Stateful because the text field keeps the user's unsaved edit and the
/// "writing…" flag between rebuilds.
class ParamField extends ConsumerStatefulWidget {
  const ParamField({super.key, required this.spec});

  final ParamSpec spec;

  @override
  ConsumerState<ParamField> createState() => _ParamFieldState();
}

class _ParamFieldState extends ConsumerState<ParamField> {
  final TextEditingController _text = TextEditingController();
  double? _shownValue;
  String? _error;
  bool _writing = false;

  ParamSpec get _spec => widget.spec;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _write(double value) async {
    final error = _spec.validate(value) ?? crossParamError(_spec.id, value, ref.read(paramValuesProvider));
    setState(() => _error = error);
    if (error != null) {
      return;
    }
    setState(() => _writing = true);
    await writeParamFromUi(context, ref, id: _spec.id, value: value, format: _spec.formatValue);
    if (mounted) {
      setState(() {
        _writing = false;
        _shownValue = null;
      });
    }
  }

  void _submitText() {
    final parsed = double.tryParse(_text.text.trim());
    if (parsed == null) {
      setState(() => _error = 'Enter a number');
      return;
    }
    _write(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(paramValuesProvider.select((values) => values[_spec.id]));
    if (value != null && value != _shownValue && !_writing) {
      _shownValue = value;
      _text.text = _spec.formatValue(value);
    }
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_spec.label, style: theme.textTheme.bodyLarge),
                    Text(_spec.id, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: _editor(value)),
              SizedBox(
                width: 32,
                child: _writing
                    ? const Padding(padding: EdgeInsets.all(6), child: CircularProgressIndicator(strokeWidth: 2))
                    : null,
              ),
            ],
          ),
          if (_error != null)
            Text(_error!, style: TextStyle(color: theme.colorScheme.error))
          else if (value == null)
            Text('Not reported by this flight controller', style: theme.textTheme.bodySmall)
          else if (_spec.help != null)
            Text(_spec.help!, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _editor(double? value) {
    final enabled = value != null && !_spec.readOnly && !_writing;
    final options = _spec.options;
    if (options != null) {
      final current = value?.round();
      return DropdownButtonFormField<int>(
        key: ValueKey(current),
        initialValue: options.containsKey(current) ? current : null,
        isDense: true,
        hint: Text(current == null ? '—' : 'Unknown ($current)'),
        decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
        items: [
          for (final entry in options.entries)
            DropdownMenuItem(value: entry.key, child: Text('${entry.value} (${entry.key})')),
        ],
        onChanged: enabled ? (choice) => choice == null ? null : _write(choice.toDouble()) : null,
      );
    }
    return TextField(
      controller: _text,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]'))],
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        isDense: true,
        suffixText: _spec.unit,
        suffixIcon: _spec.readOnly ? const Icon(Icons.lock_outline, size: 16) : null,
      ),
      onSubmitted: (_) => _submitText(),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
    );
  }
}

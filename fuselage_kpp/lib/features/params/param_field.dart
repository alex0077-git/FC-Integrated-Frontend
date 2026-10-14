import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/data/repositories/parameter_repository.dart';
import 'package:fuselage_kpp/features/params/param_rules.dart';
import 'package:fuselage_kpp/features/params/param_write.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';
import 'package:fuselage_kpp/l10n/param_l10n.dart';

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

  void _submitText() {
    final parsed = double.tryParse(_text.text.trim());
    if (parsed == null) {
      setState(() => _error = KppLocalizations.of(context).enterNumber);
      return;
    }
    _write(parsed);
  }

  String? _localizedValidate(KppLocalizations l10n, double value) {
    final spec = _spec;
    if (spec.min != null && value < spec.min!) {
      return l10n.validateMinimum(spec.formatValue(spec.min!));
    }
    if (spec.max != null && value > spec.max!) {
      return l10n.validateMaximum(spec.formatValue(spec.max!));
    }
    if (spec.options != null && !spec.options!.containsKey(value.round())) {
      return l10n.validateChooseOption;
    }
    return null;
  }

  Future<void> _writeLocalized(double value) async {
    final l10n = KppLocalizations.of(context);
    final error = _localizedValidate(l10n, value) ??
        crossParamError(_spec.id, value, ref.read(paramValuesProvider));
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

  @override
  Widget build(BuildContext context) {
    final l10n = KppLocalizations.of(context);
    final value = ref.watch(paramValuesProvider.select((values) => values[_spec.id]));
    if (value != null && value != _shownValue && !_writing) {
      _shownValue = value;
      _text.text = _spec.formatValue(value);
    }
    final theme = Theme.of(context);
    final help = ParamL10n.help(l10n, _spec);

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
                    Text(ParamL10n.label(l10n, _spec), style: theme.textTheme.bodyLarge),
                    Text(_spec.id, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: _editor(value, l10n)),
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
            Text(l10n.paramNotReported, style: theme.textTheme.bodySmall)
          else if (help != null)
            Text(help, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _editor(double? value, KppLocalizations l10n) {
    final enabled = value != null && !_spec.readOnly && !_writing;
    final options = _spec.options;
    if (options != null) {
      final current = value?.round();
      return DropdownButtonFormField<int>(
        key: ValueKey('${current}_${Localizations.localeOf(context)}'),
        initialValue: options.containsKey(current) ? current : null,
        isDense: true,
        hint: Text(
          current == null ? '—' : l10n.paramUnknownOption('$current'),
        ),
        decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
        items: [
          for (final entry in options.entries)
            DropdownMenuItem(
              value: entry.key,
              child: Text('${ParamL10n.option(l10n, entry.value)} (${entry.key})'),
            ),
        ],
        onChanged: enabled ? (choice) => choice == null ? null : _writeLocalized(choice.toDouble()) : null,
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

  // Text field path uses the same localized write helper.
  Future<void> _write(double value) => _writeLocalized(value);
}

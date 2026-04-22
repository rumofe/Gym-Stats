import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// Input numérico con botones +/– y teclado optimizado.
/// Usado para peso (decimales) y reps/RIR (enteros).
class NumericInput extends StatefulWidget {
  final double value;
  final double step;
  final double min;
  final double max;
  final int decimalPlaces;
  final String? unit;
  final ValueChanged<double> onChanged;
  final double width;
  final bool compact;

  const NumericInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.step = 1.0,
    this.min = 0,
    this.max = 999,
    this.decimalPlaces = 0,
    this.unit,
    this.width = 120,
    this.compact = false,
  });

  @override
  State<NumericInput> createState() => _NumericInputState();
}

class _NumericInputState extends State<NumericInput> {
  late TextEditingController _ctrl;
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _format(widget.value));
    _focus = FocusNode();
    _focus.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(NumericInput old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !_focus.hasFocus) {
      _ctrl.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  String _format(double v) => widget.decimalPlaces == 0
      ? v.toInt().toString()
      : v.toStringAsFixed(widget.decimalPlaces);

  void _onFocusChange() {
    if (!_focus.hasFocus) {
      final parsed = double.tryParse(_ctrl.text.replaceAll(',', '.'));
      if (parsed != null) {
        _emit(parsed);
      } else {
        _ctrl.text = _format(widget.value);
      }
    }
  }

  void _emit(double raw) {
    final clamped = raw.clamp(widget.min, widget.max);
    final rounded = widget.decimalPlaces == 0
        ? clamped.roundToDouble()
        : double.parse(clamped.toStringAsFixed(widget.decimalPlaces));
    if (rounded != widget.value) widget.onChanged(rounded);
    _ctrl.text = _format(rounded);
    _ctrl.selection =
        TextSelection.collapsed(offset: _ctrl.text.length);
  }

  void _increment() {
    HapticFeedback.selectionClick();
    _emit(widget.value + widget.step);
  }

  void _decrement() {
    HapticFeedback.selectionClick();
    _emit(widget.value - widget.step);
  }

  double get _btnSize => widget.compact ? 32 : 38;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            size: _btnSize,
            onTap: widget.value > widget.min ? _decrement : null,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                textAlign: TextAlign.center,
                keyboardType: widget.decimalPlaces > 0
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[\d.,]')),
                ],
                style: TextStyle(
                  fontSize: widget.compact ? 15 : 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: widget.compact ? 6 : 10,
                    horizontal: 4,
                  ),
                  suffix: widget.unit != null
                      ? Text(widget.unit!,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.darkMuted))
                      : null,
                ),
                onSubmitted: (v) {
                  final p = double.tryParse(v.replaceAll(',', '.'));
                  if (p != null) _emit(p);
                },
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            size: _btnSize,
            onTap: widget.value < widget.max ? _increment : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback? onTap;

  const _StepButton(
      {required this.icon, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppTheme.primary.withValues(alpha: 0.18)
              : Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: size * 0.55,
            color: onTap != null ? AppTheme.primary : Colors.white24),
      ),
    );
  }
}

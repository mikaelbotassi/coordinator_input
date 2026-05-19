import './toggle_button.dart';
import 'package:flutter/material.dart';

/// Describes a selectable option inside [ToggleButtonGroup].
class ToggleButtonOption<T extends Object> {
  const ToggleButtonOption({
    required this.value,
    this.icon,
    this.text,
  });

  final IconData? icon;
  final String? text;
  final T value;
}

/// Generic segmented selector built with the package toggle button style.
class ToggleButtonGroup<T extends Object> extends StatefulWidget {
  const ToggleButtonGroup({
    required this.onChanged,
    required this.options,
    this.initialValue,
    super.key,
  });

  final List<ToggleButtonOption<T>> options;
  final T? initialValue;
  final ValueChanged<T> onChanged;

  @override
  State<ToggleButtonGroup<T>> createState() => _ToggleButtonGroupState<T>();
}

class _ToggleButtonGroupState<T extends Object>
    extends State<ToggleButtonGroup<T>> {
  late T? _value;

  @override
  void initState() {
    _value = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: BorderDirectional(
          top: BorderSide(color: colors.primary),
          bottom: BorderSide(color: colors.primary),
          start: BorderSide(color: colors.primary),
          end: BorderSide(color: colors.primary),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: buttons,
      ),
    );
  }

  List<Widget> get buttons => widget.options.indexed.map((entry) {
    final (index, option) = entry;

    return Expanded(
      child: SizedBox(
        height: double.infinity,
        child: ToggleButton(
          onPressed: () {
            setState(() {
              _value = option.value;
            });
            widget.onChanged(option.value);
          },
          active: _value == option.value,
          icon: option.icon,
          text: option.text,
          showEndBorder: index < widget.options.length - 1,
          key: Key('${option.value} - ${option.text}'),
        ),
      ),
    );
  }).toList();
}

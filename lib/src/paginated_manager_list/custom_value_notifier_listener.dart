import 'package:flutter/material.dart';

class CustomValueNotifierListener<T> extends StatefulWidget {
  final ValueNotifier<T> valueNotifier;
  final void Function(T value)? onValueChanged;
  final Widget child;

  const CustomValueNotifierListener({
    super.key,
    required this.child,
    required this.valueNotifier,
    this.onValueChanged,
  });

  @override
  State<CustomValueNotifierListener<T>> createState() =>
      _CustomValueNotifierListenerState<T>();
}

class _CustomValueNotifierListenerState<T>
    extends State<CustomValueNotifierListener<T>> {
  late T previousValue;

  @override
  void initState() {
    super.initState();
    previousValue = widget.valueNotifier.value;

    // Add listener
    widget.valueNotifier.addListener(_onValueChanged);
  }

  @override
  void didUpdateWidget(covariant CustomValueNotifierListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update listener if the notifier changes
    if (widget.valueNotifier != oldWidget.valueNotifier) {
      oldWidget.valueNotifier.removeListener(_onValueChanged);
      widget.valueNotifier.addListener(_onValueChanged);
    }
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    widget.valueNotifier.removeListener(_onValueChanged);
    super.dispose();
  }

  void _onValueChanged() {
    final newValue = widget.valueNotifier.value;

    // Only trigger the callback if the value changes
    if (newValue != previousValue) {
      previousValue = newValue;
      widget.onValueChanged?.call(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Just return the child as it does not rebuild
    return widget.child;
  }
}

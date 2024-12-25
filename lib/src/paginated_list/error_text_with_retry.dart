import 'package:flutter/material.dart';

class ErrorTextWithRetry extends StatelessWidget {
  const ErrorTextWithRetry({
    super.key,
    required this.errorText,
    this.retryText = 'Retry',
    this.onRetry,
    this.errorTextStyle,
    this.retryTextStyle,
    this.retryButtonStyle,
  });

  final String errorText;
  final String retryText;
  final void Function()? onRetry;
  final TextStyle? errorTextStyle, retryTextStyle;
  final ButtonStyle? retryButtonStyle;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorText,
            style: errorTextStyle,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: retryButtonStyle,
              child: Text(
                retryText,
                style: retryTextStyle,
              ),
            ),
          ]
        ],
      ),
    );
  }
}

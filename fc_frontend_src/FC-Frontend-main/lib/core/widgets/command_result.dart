import 'package:flutter/material.dart';

/// Shows a short result after a flight-command attempt on the live K++.
void showCommandResult(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
}

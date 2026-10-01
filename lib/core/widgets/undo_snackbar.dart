import 'dart:async';

import 'package:flutter/material.dart';

/// Shows [message] with an Undo action for a few seconds. [onUndo] runs if
/// the action is tapped; otherwise [onExpired] runs once the snackbar closes
/// for any other reason (timeout, swipe, or replaced by another snackbar).
void showUndoSnackBar(
  ScaffoldMessengerState messenger, {
  required String message,
  required String undoLabel,
  required VoidCallback onUndo,
  required VoidCallback onExpired,
  Duration duration = const Duration(seconds: 4),
}) {
  var undone = false;
  final closed = messenger
      .showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          // A SnackBar with an action persists by default; the undo window
          // must end on its own so the delete actually happens.
          persist: false,
          action: SnackBarAction(
            label: undoLabel,
            onPressed: () {
              undone = true;
              onUndo();
            },
          ),
        ),
      )
      .closed;
  unawaited(
    closed.then((_) {
      if (!undone) onExpired();
    }),
  );
}

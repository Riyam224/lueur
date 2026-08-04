import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lueur/features/response/presentation/utils/response_share_card.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

/// Renders Luna's response as a shareable PNG card and opens the native
/// share sheet. `isMounted` is checked between the two awaits since the
/// screen may be popped while the screenshot is being captured.
Future<void> shareResponseCard(
  BuildContext context, {
  required ScreenshotController screenshotController,
  required String aiResponse,
  required bool Function() isMounted,
}) async {
  if (aiResponse.trim().isEmpty) return;

  // Capture render box and build share card before any awaits.
  final box = context.findRenderObject() as RenderBox?;
  final origin =
      box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
  final shareCard = buildResponseShareCard(context, aiResponse);

  final bytes = await screenshotController.captureFromWidget(
    shareCard,
    pixelRatio: 3.0,
  );

  if (!isMounted()) return;

  final file = File(
    '${Directory.systemTemp.path}/luna_share_${DateTime.now().millisecondsSinceEpoch}.png',
  );
  await file.writeAsBytes(bytes);

  if (!isMounted()) return;

  await Share.shareXFiles(
    [XFile(file.path)],
    sharePositionOrigin: origin,
  );
}

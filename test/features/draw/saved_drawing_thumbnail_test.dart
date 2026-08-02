import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';
import 'package:lueur/features/draw/presentation/widgets/draw_painter.dart';
import 'package:lueur/features/draw/presentation/widgets/saved_drawing_thumbnail.dart';

void main() {
  group('SavedDrawingThumbnail', () {
    testWidgets(
      'rescales strokes drawn far outside a 400x400 frame to fit inside it',
      (tester) async {
        // Mimics a drawing made on a tall, real device canvas (well past the
        // fixed 400x400 reference frame the thumbnail used to assume).
        final drawing = SavedDrawingEntity(
          id: '1',
          createdAt: DateTime(2024),
          paths: [
            const SavedDrawingPathEntity(
              colorArgb: 0xFF000000,
              points: [(100, 200), (1800, 200), (1800, 2600), (100, 2600)],
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 96,
                height: 96,
                child: SavedDrawingThumbnail(drawing: drawing),
              ),
            ),
          ),
        );

        final painter = tester
            .widget<CustomPaint>(find.byWidgetPredicate((w) => w is CustomPaint && w.painter is DrawPainter))
            .painter as DrawPainter;
        final points = painter.paths.expand((p) => p.points);

        expect(points, isNotEmpty);
        for (final point in points) {
          expect(point.dx, inInclusiveRange(0, 400));
          expect(point.dy, inInclusiveRange(0, 400));
        }
      },
    );

    testWidgets('renders without error when the drawing has no points', (tester) async {
      final drawing = SavedDrawingEntity(id: '1', createdAt: DateTime(2024), paths: const []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 96,
              height: 96,
              child: SavedDrawingThumbnail(drawing: drawing),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/theme/calm_mode_colors.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_cubit.dart';

void main() {
  group('DrawCubit', () {
    test('initial state has no paths and the default lavender color', () {
      final cubit = DrawCubit();
      expect(cubit.state.paths, isEmpty);
      expect(cubit.state.currentColor, CalmModeColors.lavenderGlow);
      cubit.close();
    });

    test('startStroke adds a new path with the current color', () {
      final cubit = DrawCubit();
      cubit.startStroke(const Offset(10, 10));

      expect(cubit.state.paths.length, 1);
      expect(cubit.state.paths.first.points, [const Offset(10, 10)]);
      expect(cubit.state.paths.first.color, CalmModeColors.lavenderGlow);
      cubit.close();
    });

    test('extendStroke appends points to the last path only', () {
      final cubit = DrawCubit();
      cubit.startStroke(const Offset(0, 0));
      cubit.extendStroke(const Offset(3, 0));
      cubit.extendStroke(const Offset(6, 0));

      expect(cubit.state.paths.length, 1);
      expect(cubit.state.paths.first.points, [
        const Offset(0, 0),
        const Offset(3, 0),
        const Offset(6, 0),
      ]);
      cubit.close();
    });

    test('extendStroke ignores pointer noise too close to the last point', () {
      final cubit = DrawCubit();
      cubit.startStroke(const Offset(10, 10));

      cubit.extendStroke(const Offset(10.5, 10.5));

      expect(cubit.state.paths.single.points, [const Offset(10, 10)]);
      cubit.close();
    });

    test('extendStroke is a no-op when no stroke has started', () {
      final cubit = DrawCubit();
      cubit.extendStroke(const Offset(1, 1));

      expect(cubit.state.paths, isEmpty);
      cubit.close();
    });

    test('selectColor updates the current color for the next stroke', () {
      final cubit = DrawCubit();
      cubit.selectColor(CalmModeColors.peachGlow);
      cubit.startStroke(const Offset(5, 5));

      expect(cubit.state.currentColor, CalmModeColors.peachGlow);
      expect(cubit.state.paths.first.color, CalmModeColors.peachGlow);
      cubit.close();
    });

    test('undoLastStroke removes only the most recent path', () {
      final cubit = DrawCubit();
      cubit.startStroke(const Offset(0, 0));
      cubit.startStroke(const Offset(5, 5));
      expect(cubit.state.paths.length, 2);

      cubit.undoLastStroke();

      expect(cubit.state.paths.length, 1);
      expect(cubit.state.paths.first.points, [const Offset(0, 0)]);
      cubit.close();
    });

    test('undoLastStroke is a no-op when there are no strokes', () {
      final cubit = DrawCubit();

      cubit.undoLastStroke();

      expect(cubit.state.paths, isEmpty);
      cubit.close();
    });

    test('clear resets paths back to empty', () {
      final cubit = DrawCubit();
      cubit.startStroke(const Offset(0, 0));
      cubit.extendStroke(const Offset(1, 1));
      expect(cubit.state.paths, isNotEmpty);

      cubit.clear();

      expect(cubit.state.paths, isEmpty);
      cubit.close();
    });

    test('methods are no-ops after the cubit is closed', () async {
      final cubit = DrawCubit();
      await cubit.close();

      cubit.startStroke(const Offset(0, 0));
      cubit.extendStroke(const Offset(1, 1));
      cubit.selectColor(CalmModeColors.peachGlow);
      cubit.undoLastStroke();
      cubit.clear();

      expect(cubit.isClosed, isTrue);
    });
  });
}

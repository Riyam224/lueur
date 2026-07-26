/// A single freehand stroke, kept Flutter-free (plain doubles/ints instead
/// of [Offset]/[Color]) so the domain layer stays pure Dart.
class SavedDrawingPathEntity {
  final int colorArgb;
  final List<(double, double)> points;

  const SavedDrawingPathEntity({required this.colorArgb, required this.points});
}

class SavedDrawingEntity {
  final String id;
  final List<SavedDrawingPathEntity> paths;
  final DateTime createdAt;

  const SavedDrawingEntity({
    required this.id,
    required this.paths,
    required this.createdAt,
  });
}

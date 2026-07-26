import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';

class SavedDrawingPathModel {
  final int colorArgb;
  final List<(double, double)> points;

  const SavedDrawingPathModel({required this.colorArgb, required this.points});

  factory SavedDrawingPathModel.fromJson(Map<String, dynamic> json) {
    return SavedDrawingPathModel(
      colorArgb: json['color'] as int,
      points: (json['points'] as List<dynamic>)
          .map(
            (p) => (
              (p as Map<String, dynamic>)['dx'] as double,
              p['dy'] as double,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'color': colorArgb,
    'points': points.map((p) => {'dx': p.$1, 'dy': p.$2}).toList(),
  };

  SavedDrawingPathEntity toEntity() =>
      SavedDrawingPathEntity(colorArgb: colorArgb, points: points);
}

class SavedDrawingModel {
  final String id;
  final List<SavedDrawingPathModel> paths;
  final DateTime createdAt;

  const SavedDrawingModel({
    required this.id,
    required this.paths,
    required this.createdAt,
  });

  factory SavedDrawingModel.fromJson(Map<String, dynamic> json) {
    return SavedDrawingModel(
      id: json['id'] as String,
      paths: (json['paths'] as List<dynamic>)
          .map((p) => SavedDrawingPathModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'paths': paths.map((p) => p.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
  };

  SavedDrawingEntity toEntity() => SavedDrawingEntity(
    id: id,
    paths: paths.map((p) => p.toEntity()).toList(),
    createdAt: createdAt,
  );
}

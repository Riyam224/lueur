import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur_app/features/home/data/datasources/mood_remote_datasource.dart';
import 'package:lueur_app/features/home/data/models/weekly_letter_model.dart';

// ── States ─────────────────────────────────────────────────────────────────

abstract class WeeklyLetterState extends Equatable {
  const WeeklyLetterState();

  @override
  List<Object?> get props => [];
}

class WeeklyLetterInitial extends WeeklyLetterState {
  const WeeklyLetterInitial();
}

class WeeklyLetterLoading extends WeeklyLetterState {
  const WeeklyLetterLoading();
}

class WeeklyLetterLoaded extends WeeklyLetterState {
  final WeeklyLetterModel data;
  const WeeklyLetterLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class WeeklyLetterError extends WeeklyLetterState {
  const WeeklyLetterError();
}

// ── Cubit ──────────────────────────────────────────────────────────────────

class WeeklyLetterCubit extends Cubit<WeeklyLetterState> {
  final MoodRemoteDatasource _remote;

  WeeklyLetterCubit(this._remote) : super(const WeeklyLetterInitial());

  Future<void> load() async {
    emit(const WeeklyLetterLoading());
    try {
      final data = await _remote.getWeeklyLetter();
      emit(WeeklyLetterLoaded(data));
    } catch (_) {
      emit(const WeeklyLetterError());
    }
  }
}
